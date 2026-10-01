import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 令牌持久化抽象（裁决 **D-B**）。
///
/// ## 为什么必须有这一层
///
/// Careerly 的产品核心是「**看见自己的变化**」——成长是相邻两次能力快照的
/// diff，足迹要求「同一个人被持续识别」。而 D52（token 仅内存）的直接后果是：
///
/// ```text
/// 今天登录 → 分析 → 记录成长
/// 明天打开 App → 变成新用户 → 「我的足迹」失去连续性
/// ```
///
/// 所以 D-B 的裁决不是「要不要持久化」，而是「**如何安全地**持久化」。
///
/// ## 为什么用 secure storage 而不是 shared_preferences
///
/// refresh token 是长期有效的身份凭据，落在明文 SharedPreferences 里等于
/// 把账号交给任何能读 /data/data 的人（root、备份导出、ADB backup）。
/// 本实现走 Android Keystore / iOS Keychain —— 凭据由系统密钥加密，
/// 应用进程读到的已是解密后的值，磁盘上没有明文。
///
/// ## 为什么保留内存实现
///
/// 单测跑在 Dart VM 上，没有平台通道；[InMemoryTokenStore] 让测试无需
/// mock 插件即可验证「保存 / 恢复 / 清除」的语义。
abstract class TokenStore {
  /// 写入令牌对。`refreshToken` 为 null 时保留既有值。
  Future<void> save({required String accessToken, String? refreshToken});

  /// 读取已保存的令牌；从未保存过则返回 null。
  Future<Tokens?> read();

  /// 清除（登出 / refresh 失效时调用）。
  Future<void> clear();
}

/// 一次会话的令牌对。
class Tokens {
  const Tokens({required this.accessToken, this.refreshToken});

  final String accessToken;
  final String? refreshToken;

  bool get isValid => accessToken.isNotEmpty;
}

/// Android Keystore / iOS Keychain 支撑的持久化实现。
class SecureTokenStore implements TokenStore {
  /// `storage` 仅供测试注入；生产代码用默认构造。
  SecureTokenStore([FlutterSecureStorage? storage]) : _storage = storage ?? _default();

  /// v11 起 Android 端不再有 `encryptedSharedPreferences` 开关：
  /// 存储一律是 AES-GCM/NoPadding，密钥由 Keystore 用
  /// RSA/ECB/OAEPWithSHA-256AndMGF1Padding 包装（API 23+）。
  /// 因此**不做**自定义即是最强配置；这里只显式声明命名空间，避免与其它
  /// 使用 secure storage 的依赖在同一份 SharedPreferences 里撞 key。
  ///
  /// 刻意**不启用** biometric / requireBiometricsPerOperation：
  /// 冷启动恢复 session 是静默行为，弹指纹框会让「打开 App 即已登录」失效。
  static FlutterSecureStorage _default() => const FlutterSecureStorage(
        aOptions: AndroidOptions(storageNamespace: 'careerly.auth'),
        mOptions: MacOsOptions(),
      );

  static const String _accessKey = 'careerly.auth.access_token';
  static const String _refreshKey = 'careerly.auth.refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<void> save({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  @override
  Future<Tokens?> read() async {
    final String? access = await _storage.read(key: _accessKey);
    if (access == null || access.isEmpty) return null;
    return Tokens(
      accessToken: access,
      refreshToken: await _storage.read(key: _refreshKey),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

/// 内存实现：D52 的旧行为，也是单元测试的默认选择。
///
/// 进程内有效、重启即失 —— 仅用于测试和「明确不要持久化」的场景。
class InMemoryTokenStore implements TokenStore {
  Tokens? _tokens;

  @override
  Future<void> save({
    required String accessToken,
    String? refreshToken,
  }) async {
    _tokens = Tokens(
      accessToken: accessToken,
      refreshToken: refreshToken ?? _tokens?.refreshToken,
    );
  }

  @override
  Future<Tokens?> read() async => _tokens;

  @override
  Future<void> clear() async => _tokens = null;
}
