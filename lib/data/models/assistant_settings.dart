import 'package:flutter/foundation.dart';

/// AI 回答风格。
///
/// 与设置页的单选项一一对应。`storageKey` 是本地持久化的稳定标识 ——
/// **不要用 [index] 存**：以后调整枚举顺序会让已保存的偏好错位。
enum AiAnswerStyle {
  concise('concise', '简洁'),
  detailed('detailed', '详细'),
  actionOriented('action_oriented', '行动导向');

  const AiAnswerStyle(this.storageKey, this.label);

  /// 本地持久化用的稳定字符串。
  final String storageKey;

  /// 设置页展示文案。
  final String label;

  /// 从本地值还原；未知值回退到 [actionOriented]。
  ///
  /// 回退而不是抛错：本地偏好坏了不该让设置页打不开。
  static AiAnswerStyle fromStorageKey(String? value) {
    for (final AiAnswerStyle style in values) {
      if (style.storageKey == value) return style;
    }
    return AiAnswerStyle.actionOriented;
  }
}

/// 设置页里的 AI 偏好。
///
/// 这些是**本机偏好**，不经过后端接口 —— 当前后端没有 settings / notification
/// 端点，App 也没有接入推送。设置页会把这一点如实写出来，不假装已经生效。
@immutable
class AssistantSettings {
  const AssistantSettings({
    this.proactiveAdvice = true,
    this.dailyBriefing = false,
    this.matchAlert = true,
    this.answerStyle = AiAnswerStyle.actionOriented,
  });

  /// AI 主动建议。
  final bool proactiveAdvice;

  /// 每日职业简报。
  final bool dailyBriefing;

  /// 匹配变化提醒。
  final bool matchAlert;

  /// AI 回答风格。
  final AiAnswerStyle answerStyle;

  /// 默认值 = 设置页此前的初始状态。
  static const AssistantSettings defaults = AssistantSettings();

  AssistantSettings copyWith({
    bool? proactiveAdvice,
    bool? dailyBriefing,
    bool? matchAlert,
    AiAnswerStyle? answerStyle,
  }) {
    return AssistantSettings(
      proactiveAdvice: proactiveAdvice ?? this.proactiveAdvice,
      dailyBriefing: dailyBriefing ?? this.dailyBriefing,
      matchAlert: matchAlert ?? this.matchAlert,
      answerStyle: answerStyle ?? this.answerStyle,
    );
  }

  /// 本地持久化格式。
  Map<String, Object?> toJson() => <String, Object?>{
    'proactiveAdvice': proactiveAdvice,
    'dailyBriefing': dailyBriefing,
    'matchAlert': matchAlert,
    'answerStyle': answerStyle.storageKey,
  };

  /// 从本地值还原。
  ///
  /// 字段缺失 / 类型不符时逐项回退到默认值 —— 同一份 JSON 里只有一项坏了，
  /// 不应该把其余三项也重置。
  factory AssistantSettings.fromJson(Map<String, Object?> json) {
    bool readBool(String key, bool fallback) {
      final Object? value = json[key];
      return value is bool ? value : fallback;
    }

    final Object? style = json['answerStyle'];

    return AssistantSettings(
      proactiveAdvice: readBool('proactiveAdvice', defaults.proactiveAdvice),
      dailyBriefing: readBool('dailyBriefing', defaults.dailyBriefing),
      matchAlert: readBool('matchAlert', defaults.matchAlert),
      answerStyle: AiAnswerStyle.fromStorageKey(
        style is String ? style : null,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AssistantSettings &&
            other.proactiveAdvice == proactiveAdvice &&
            other.dailyBriefing == dailyBriefing &&
            other.matchAlert == matchAlert &&
            other.answerStyle == answerStyle;
  }

  @override
  int get hashCode =>
      Object.hash(proactiveAdvice, dailyBriefing, matchAlert, answerStyle);
}
