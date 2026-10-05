import '../models/ai_chat.dart';
import '../repositories/ai_repository.dart';
import 'mock_config.dart';

/// AI Repository 的 Mock 实现。
///
/// 不读取简历、岗位或 Career Context，避免在 Context 阶段之前伪造个性化结论。
///
/// ⚠️ 与真实实现一样**分帧**下发（先 `start`、再若干 `delta`、最后 `done`），
/// 不是一次性返回。否则「逐字显示」只有接了真后端才看得见，
/// Mock 下的 Loading / 流式渲染无从验证（CLAUDE.md §7）。
class MockAIRepository implements AIRepository {
  MockAIRepository({MockConfig? config, Duration? chunkInterval})
    : _config = config ?? MockSettings.config,
      _chunkInterval = chunkInterval ?? const Duration(milliseconds: 24);

  final MockConfig _config;

  /// 每个 delta 之间的间隔。测试传 `Duration.zero` 以免拖慢用例。
  final Duration _chunkInterval;

  static const String _reply =
      '这是 Mock 回复。接入职业上下文后，我会结合你的简历、目标岗位和能力 Gap 给出更具体的建议。';

  /// 每个 delta 携带的字数。
  static const int _chunkSize = 2;

  @override
  Stream<AIStreamEvent> sendMessage(AIRequest request) async* {
    // 延迟 / 失败开关（MockConfig）在这里生效 ——
    // 抛出即等同真实实现的「开流前失败」，调用方的错误分支因此可达。
    await _config.simulate();

    yield const AIStreamStarted();

    for (int i = 0; i < _reply.length; i += _chunkSize) {
      await Future<void>.delayed(_chunkInterval);
      final int end = (i + _chunkSize).clamp(0, _reply.length);
      yield AIStreamDelta(_reply.substring(i, end));
    }

    yield const AIStreamDone();
  }
}
