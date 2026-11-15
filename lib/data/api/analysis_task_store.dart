import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 进行中分析任务的本地句柄存储。
///
/// ## 为什么需要它
///
/// 产品要求：**杀掉 App 再进入时，必须恢复真实的分析进度**，不能从 0
/// 重来。后端已经按 `taskId` 提供实时状态，客户端只需要把**当前任务的
/// id** 持久化到磁盘，重启后重新轮询同一个任务即可。
///
/// 只存一个不敏感的 `taskId`，但复用 [FlutterSecureStorage] 而不是新增
/// `shared_preferences` 依赖 —— `CLAUDE.md` §6.5 要求新增依赖必须
/// 「明确必要且当前实际使用」，而这个键一次只存一个字符串，安全存储
/// 已经存在，没必要为它引入第二套本地 KV。
abstract interface class ActiveAnalysisTaskStore {
  /// 读取当前进行中的任务 id；没有则 `null`。
  Future<String?> read();

  /// 记录进行中的任务 id（覆盖旧值）。
  Future<void> write(String taskId);

  /// 清除（任务终态 / 用户退出 / 数据源不支持时）。
  Future<void> clear();
}

/// 内存实现：单测与「明确不持久化」的场景使用。
class InMemoryActiveAnalysisTaskStore implements ActiveAnalysisTaskStore {
  String? _taskId;

  @override
  Future<String?> read() async => _taskId;

  @override
  Future<void> write(String taskId) async => _taskId = taskId;

  @override
  Future<void> clear() async => _taskId = null;
}

/// 生产实现：Secure Storage，命名空间与 auth token 隔离。
class SecureActiveAnalysisTaskStore implements ActiveAnalysisTaskStore {
  SecureActiveAnalysisTaskStore([FlutterSecureStorage? storage])
      : _storage = storage ?? _default();

  static FlutterSecureStorage _default() => const FlutterSecureStorage(
        aOptions: AndroidOptions(storageNamespace: 'careerly.analysis'),
        mOptions: MacOsOptions(),
      );

  static const String _key = 'careerly.analysis.active_task_id';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String taskId) => _storage.write(key: _key, value: taskId);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
