import 'dart:async';

import 'package:careerly/data/api/analysis_task_store.dart';
import 'package:careerly/data/models/analysis_job_input.dart';
import 'package:careerly/data/models/analysis_project.dart';
import 'package:careerly/data/models/analysis_result.dart';
import 'package:careerly/data/models/analysis_task.dart';
import 'package:careerly/data/models/job.dart';
import 'package:careerly/data/models/parsed_job.dart';
import 'package:careerly/data/models/quota_state.dart';
import 'package:careerly/data/repositories/analysis_repository.dart';
import 'package:careerly/features/analysis/state/analysis_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// P1-02 —— 异步任务句柄竞态。
///
/// 不变式：
///
/// 1. `POST /analysis/tasks` 返回后，**先落盘 `taskId`**，再判断本次运行
///    是否已被退出 / 取代。用户退出不能丢掉已创建服务器任务的恢复句柄。
/// 2. 旧任务不得覆盖新任务的句柄（代际号守卫）。
/// 3. 落盘失败不允许静默丢失：保留进程内句柄并上报错误。

// ---------------------------------------------------------------------------
// 桩
// ---------------------------------------------------------------------------

class _RecordingTaskStore implements ActiveAnalysisTaskStore {
  _RecordingTaskStore({this.failWrites = false});

  bool failWrites;
  String? value;
  final List<String> writes = <String>[];
  int clears = 0;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String taskId) async {
    if (failWrites) {
      throw StateError('secure storage unavailable');
    }
    writes.add(taskId);
    value = taskId;
  }

  @override
  Future<void> clear() async {
    clears++;
    value = null;
  }
}

/// 每次 `startAnalysisTask` 都挂起，由测试决定何时「后端返回」。
class _RaceRepository implements AnalysisRepository, AnalysisProgressSource {
  final List<Completer<AnalysisTask>> _starts = <Completer<AnalysisTask>>[];
  final List<String> fetchedTaskIds = <String>[];

  /// `fetchAnalysisTask` 的返回值（恢复场景）。
  AnalysisTask fetchResult = const AnalysisTask(
    taskId: 'task-fetch',
    status: AnalysisTask.statusCompleted,
  );

  int get startCount => _starts.length;

  void completeStart(int index, AnalysisTask task) {
    _starts[index].complete(task);
  }

  AnalysisProject get _project => AnalysisProject(
    id: 'project-1',
    name: '测试项目',
    jobs: const <Job>[Job(id: 'job-a', title: '岗位 A', rawJd: 'JD')],
    results: const <AnalysisResult>[
      AnalysisResult(
        id: 'result-1',
        projectId: 'project-1',
        version: 1,
        matches: <JobMatch>[
          JobMatch(jobId: 'job-a', score: 70, rank: 1),
        ],
      ),
    ],
  );

  @override
  Future<AnalysisTask> startAnalysisTask({
    required String title,
    required String rawJd,
    String company = '',
    String source = 'paste',
    String? sourceUrl,
    List<AnalysisJobInput>? jobs,
    String? projectId,
    String? resumeVersionId,
  }) {
    final Completer<AnalysisTask> completer = Completer<AnalysisTask>();
    _starts.add(completer);
    return completer.future;
  }

  @override
  Future<AnalysisTask> fetchAnalysisTask(String taskId) async {
    fetchedTaskIds.add(taskId);
    return fetchResult;
  }

  @override
  Future<AnalysisTask> cancelAnalysisTask(String taskId) async => fetchResult;

  @override
  Future<List<AnalysisProject>> fetchProjects() async => <AnalysisProject>[
    _project,
  ];

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async => _project;

  @override
  Future<List<Job>> fetchJobLibrary() async => const <Job>[];

  @override
  Future<QuotaState> fetchQuota() async => QuotaState.free;

  @override
  Future<ParsedJob> parseJobUrl(String url) async =>
      throw UnimplementedError('本测试不覆盖岗位链接抓取');

  @override
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
    String company = '',
    String source = 'paste',
    String? sourceUrl,
    List<AnalysisJobInput>? jobs,
  }) async => _project;
}

AnalysisTask _processing(String taskId) =>
    AnalysisTask(taskId: taskId, status: AnalysisTask.statusProcessing);

AnalysisTask _completed(String taskId) => AnalysisTask(
  taskId: taskId,
  status: AnalysisTask.statusCompleted,
  projectId: 'project-1',
);

Future<AnalysisProvider> _providerWithQuota(
  _RaceRepository repo,
  _RecordingTaskStore store,
) async {
  final AnalysisProvider provider = AnalysisProvider(repo, taskStore: store);
  await provider.loadQuota();
  return provider;
}

void main() {
  final List<FlutterErrorDetails> reportedErrors = <FlutterErrorDetails>[];
  FlutterExceptionHandler? previousOnError;

  setUp(() {
    reportedErrors.clear();
    previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      reportedErrors.add(details);
    };
  });

  tearDown(() {
    FlutterError.onError = previousOnError;
  });

  test('任务创建后用户立即退出：句柄仍先落盘（不丢服务器任务）', () async {
    final _RaceRepository repo = _RaceRepository();
    final _RecordingTaskStore store = _RecordingTaskStore();
    final AnalysisProvider provider = await _providerWithQuota(repo, store);

    final Future<void> run = provider.startAnalysis(
      title: '岗位 A',
      rawJd: 'JD 文本',
    );
    expect(repo.startCount, 1, reason: '发起分析应当已经在等后端返回 taskId');

    // 后端还没返回，用户先退出。
    provider.exitAnalysis();
    repo.completeStart(0, _processing('task-A'));
    await run;

    expect(
      store.writes,
      <String>['task-A'],
      reason: '退出不撤销服务器任务，恢复句柄必须落盘',
    );
    expect(store.value, 'task-A');
  });

  test('旧任务晚到不得覆盖新任务句柄', () async {
    final _RaceRepository repo = _RaceRepository();
    final _RecordingTaskStore store = _RecordingTaskStore();
    final AnalysisProvider provider = await _providerWithQuota(repo, store);

    final Future<void> first = provider.startAnalysis(
      title: '岗位 A',
      rawJd: 'JD A',
    );
    // 用户不等第一次返回，又发起了一次分析（更新后的任务）。
    final Future<void> second = provider.startAnalysis(
      title: '岗位 A',
      rawJd: 'JD A',
    );
    expect(repo.startCount, 2);

    // 旧任务先返回 —— 代际已被取代，不得写盘。
    repo.completeStart(0, _processing('task-old'));
    await first;
    expect(store.writes, isEmpty, reason: '旧任务不得抢先写入句柄');

    // 新任务返回并完成。
    repo.completeStart(1, _completed('task-new'));
    await second;

    expect(store.writes, <String>['task-new']);
  });

  test('落盘失败不静默：保留进程内句柄，恢复仍能接上', () async {
    final _RaceRepository repo = _RaceRepository();
    final _RecordingTaskStore store = _RecordingTaskStore(failWrites: true);
    final AnalysisProvider provider = await _providerWithQuota(repo, store);

    final Future<void> run = provider.startAnalysis(
      title: '岗位 A',
      rawJd: 'JD 文本',
    );
    provider.exitAnalysis();
    repo.completeStart(0, _processing('task-A'));
    await run;

    expect(store.writes, isEmpty);
    expect(provider.hasUnpersistedTaskHandle, isTrue);
    expect(
      reportedErrors,
      isNotEmpty,
      reason: '写盘失败必须上报，不能静默吞掉',
    );

    // Secure Storage 不可用，但本次进程内仍能用同一 taskId 恢复。
    repo.fetchResult = _completed('task-A');
    await provider.restoreActiveTask();

    expect(repo.fetchedTaskIds, <String>['task-A']);
  });

  test('任务终态后清除句柄（磁盘 + 进程内）', () async {
    final _RaceRepository repo = _RaceRepository();
    final _RecordingTaskStore store = _RecordingTaskStore();
    final AnalysisProvider provider = await _providerWithQuota(repo, store);

    final Future<void> run = provider.startAnalysis(
      title: '岗位 A',
      rawJd: 'JD 文本',
    );
    repo.completeStart(0, _completed('task-A'));
    await run;

    expect(store.writes, <String>['task-A']);
    expect(store.clears, greaterThanOrEqualTo(1));
    expect(provider.hasUnpersistedTaskHandle, isFalse);
    expect(store.value, isNull);
  });
}
