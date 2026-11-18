import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/assistant_settings.dart';

/// 设置偏好的本地存储。
///
/// ## 为什么不用 `shared_preferences`
///
/// 项目里已经有 [FlutterSecureStorage]（登录令牌、分析任务句柄），
/// 而本次要存的是**一小段 JSON**。为一个键引入第二套本地 KV
/// 不满足 `CLAUDE.md` §6.5「新增依赖必须明确必要且当前实际使用」。
///
/// 用安全存储不是因为这些偏好敏感，而是**复用已有的本地持久化通道** ——
/// 与 `SecureActiveAnalysisTaskStore` 同一处置。
abstract interface class SettingsStore {
  /// 读取已保存的偏好；从未保存过（或内容损坏）时返回 `null`。
  Future<AssistantSettings?> read();

  /// 覆盖写入偏好。
  Future<void> write(AssistantSettings settings);
}

/// 内存实现：单元测试 / Widget 测试的默认选择。
class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore([AssistantSettings? initial]) : _value = initial;

  AssistantSettings? _value;

  /// 当前值（测试断言用）。
  AssistantSettings? get value => _value;

  @override
  Future<AssistantSettings?> read() async => _value;

  @override
  Future<void> write(AssistantSettings settings) async => _value = settings;
}

/// 生产实现：Secure Storage，命名空间与 auth / analysis 隔离。
class SecureSettingsStore implements SettingsStore {
  SecureSettingsStore([FlutterSecureStorage? storage])
    : _storage = storage ?? _default();

  static FlutterSecureStorage _default() => const FlutterSecureStorage(
    aOptions: AndroidOptions(storageNamespace: 'careerly.settings'),
    mOptions: MacOsOptions(),
  );

  static const String _key = 'careerly.settings.assistant';

  final FlutterSecureStorage _storage;

  @override
  Future<AssistantSettings?> read() async {
    final String? raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return AssistantSettings.fromJson(decoded.cast<String, Object?>());
    } on FormatException {
      // 本地内容损坏时按「没有保存过」处理，让默认值生效。
      return null;
    }
  }

  @override
  Future<void> write(AssistantSettings settings) {
    return _storage.write(key: _key, value: jsonEncode(settings.toJson()));
  }
}
