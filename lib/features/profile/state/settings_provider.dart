import 'package:flutter/foundation.dart';

import '../../../data/local/settings_store.dart';
import '../../../data/models/assistant_settings.dart';

/// 设置页的状态。
///
/// ## 职责边界
///
/// 只管理**本机偏好**：开关与 AI 回答风格。退出登录 / 删除数据这些
/// 不可逆动作仍由 `AuthProvider` 负责，不在这里重复实现。
///
/// ## 恢复与写入
///
/// 构造时异步读取本地值；用户改动立即更新内存状态并 `notifyListeners()`，
/// 写入串行排队（[Future] 链），避免快速连点时后写的旧值覆盖新值。
///
/// ⚠️ 恢复完成前用户就已经改动过 → **不**用本地旧值覆盖用户的新选择
/// （见 [_hasUserChange]）。安全存储读写通常很快，但这是真实存在的竞态。
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._store) {
    _ready = _restore();
  }

  final SettingsStore _store;
  late final Future<void> _ready;

  AssistantSettings _settings = AssistantSettings.defaults;
  bool _isRestoring = true;
  bool _hasUserChange = false;
  Object? _lastWriteError;
  Future<void> _writeChain = Future<void>.value();
  bool _disposed = false;

  /// 本地恢复完成。
  ///
  /// 测试用它拿到确定性的时序；页面不需要等待 —— 开关先显示默认值，
  /// 恢复完成后自动刷新。
  Future<void> get ready => _ready;

  AssistantSettings get settings => _settings;

  bool get isRestoring => _isRestoring;

  /// 最近一次写入失败的原因；成功一次后清空。
  Object? get lastWriteError => _lastWriteError;

  bool get proactiveAdvice => _settings.proactiveAdvice;
  bool get dailyBriefing => _settings.dailyBriefing;
  bool get matchAlert => _settings.matchAlert;
  AiAnswerStyle get answerStyle => _settings.answerStyle;

  Future<void> _restore() async {
    try {
      final AssistantSettings? stored = await _store.read();
      if (!_hasUserChange && stored != null) {
        _settings = stored;
      }
    } catch (error) {
      // 读取失败按「没有保存过」处理，不阻塞页面。
      _lastWriteError = error;
    } finally {
      _isRestoring = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> setProactiveAdvice(bool value) {
    return _update(_settings.copyWith(proactiveAdvice: value));
  }

  Future<void> setDailyBriefing(bool value) {
    return _update(_settings.copyWith(dailyBriefing: value));
  }

  Future<void> setMatchAlert(bool value) {
    return _update(_settings.copyWith(matchAlert: value));
  }

  Future<void> setAnswerStyle(AiAnswerStyle style) {
    return _update(_settings.copyWith(answerStyle: style));
  }

  Future<void> _update(AssistantSettings next) async {
    if (next == _settings) return;

    _hasUserChange = true;
    _settings = next;
    if (!_disposed) notifyListeners();

    // 串行写入：保证磁盘上的值等于**最后一次**用户选择，
    // 而不是「哪个 Future 先完成算哪个」。
    _writeChain = _writeChain.then<void>((_) async {
      try {
        await _store.write(next);
        _lastWriteError = null;
      } catch (error) {
        _lastWriteError = error;
      }
    });
    await _writeChain;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
