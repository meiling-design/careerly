import 'package:flutter/foundation.dart';

/// 「我的」页面顶部身份区的用户资料。
///
/// 归属：「我的」（IA §10）。
///
/// ## ⚠️ 为什么这是一个**独立于 `ResumeProfile`** 的模型
///
/// `ResumeProfile` 描述的是**职业基线**（简历版本 / 经历 / 技能），
/// 而这一区描述的是**账号身份**（昵称 / 账号名 / 会员标签）。
/// 两者在 Figma 里就是两块不同的数据，不互为派生。
///
/// ## ⚠️ 当前**没有真实数据来源**（**待裁决 · D90**）
///
/// `AuthRepository.register` 只做「一次网络往返」，**不保存会话**
/// （D52：不引入本地存储依赖），因此注册时填的姓名**读不回来**。
///
/// ```text
/// ✅ Mock 默认返回 UserProfile.empty
/// ❌ 不编造「Alex」「@elmasekeri」之类的示例身份
/// ```
///
/// 空态下「我的」主页显示的是**中性占位文案**，不是假身份。
/// 该占位文案由 Flutter 侧自拟（Figma 没有空态），
/// 已登记 **待裁决 · D90**（`docs/05_progress/TODO.md` §3.1）。
@immutable
class UserProfile {
  const UserProfile({
    this.displayName = '',
    this.handle = '',
    this.membershipLabel = '',
  });

  /// 空资料 —— Mock 的默认返回（`CLAUDE.md` §7）。
  static const UserProfile empty = UserProfile();

  /// 昵称，例如「Alex」。
  final String displayName;

  /// 账号名，例如「@elmasekeri」。
  final String handle;

  /// 会员徽章文案，例如「V1会员」。
  ///
  /// ⚠️ PRD **未定义会员等级体系**，Figma 硬编码的是 `V1会员`。
  /// 语义未定，已登记 **待裁决 · D87**（`docs/05_progress/TODO.md` §3.1）。
  /// 为空时徽章显示中性文案（见页面实现）。
  final String membershipLabel;

  /// 是否有任何身份资料。
  bool get isEmpty =>
      displayName.isEmpty && handle.isEmpty && membershipLabel.isEmpty;

  /// 头像上的字母。
  ///
  /// 取昵称首字符并大写 —— 与 Figma 的 `'A'`（`ProfilePage` L3160）同一规则。
  /// 昵称为空时返回 `null`，由调用方决定用什么中性图形代替。
  ///
  /// ⚠️ 用 `runes` 而不是 `substring(0, 1)` —— 后者会在
  /// 基本多文种平面之外的字符（emoji 等代理对）上截出半个字符。
  /// 这里取的是**码点**而非完整的字素簇（`characters` 包才有），
  /// 对一个字母头像而言已经足够，且不必为此新增依赖（`CLAUDE.md` §6.5）。
  String? get avatarGlyph {
    if (displayName.isEmpty) return null;
    return String.fromCharCode(displayName.runes.first).toUpperCase();
  }

  UserProfile copyWith({
    String? displayName,
    String? handle,
    String? membershipLabel,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      handle: handle ?? this.handle,
      membershipLabel: membershipLabel ?? this.membershipLabel,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      displayName: json['displayName'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      membershipLabel: json['membershipLabel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'displayName': displayName,
    'handle': handle,
    'membershipLabel': membershipLabel,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          other.displayName == displayName &&
          other.handle == handle &&
          other.membershipLabel == membershipLabel;

  @override
  int get hashCode => Object.hash(displayName, handle, membershipLabel);

  @override
  String toString() => 'UserProfile($displayName, $handle)';
}
