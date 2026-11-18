import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';

/// 分析额度状态。
///
/// 结构来自 Baseline §5 / PRD §16：
/// ```text
/// QuotaState
/// ├── total
/// ├── used
/// ├── remaining
/// └── canAnalyze
/// ```
///
/// **额度规则（Baseline §5，硬规则）：**
/// - 上传简历 → 不扣
/// - 粘贴 JD → 不扣
/// - 进入分析页面 → 不扣
/// - **只有点击「开始分析」时才扣减**
/// - 分析失败 → 回滚额度
///
/// ## P1-03：`used` 与 `reserved` 分开
///
/// 用户点「开始分析」后，这一次额度先进入 [reserved]（预占），
/// 任务成功才转为 [used]，失败 / 取消 / 服务重启则释放。
/// 剩余额度 = `total - used - reserved`，并发请求不会同时通过门禁。
@immutable
class QuotaState {
  const QuotaState({
    required this.total,
    required this.used,
    this.reserved = 0,
    this.isMember = false,
  });

  /// 免费用户的初始额度。PRD §16：3 次完整分析。
  static const QuotaState free = QuotaState(
    total: AppConstants.freeAnalysisQuota,
    used: 0,
  );

  /// 总次数。会员场景下为 [unlimited]。
  final int total;

  /// 已确认消耗的次数。
  final int used;

  /// 已被进行中的分析任务预占、尚未确认消耗的次数。
  final int reserved;

  /// 是否为会员。
  ///
  /// ⚠️ 开放项 O5（Baseline §9）：Pro 的额度语义（无限 / 每月 N 次）**尚未裁决**，
  /// 阻塞 Phase 9。此字段先以布尔占位，不预设具体语义。
  final bool isMember;

  /// 无限额度的哨兵值。
  static const int unlimited = -1;

  /// 剩余次数（预占中的次数也计入占用）。会员为 [unlimited]。
  int get remaining =>
      isMember ? unlimited : (total - used - reserved).clamp(0, total);

  /// 是否还能发起分析。
  ///
  /// UI 依据此值 gate「开始分析」按钮（PRD §16：禁用 + 显示剩余次数 + 升级入口）。
  bool get canAnalyze => isMember || remaining > 0;

  /// 是否已耗尽。
  bool get isExhausted => !canAnalyze;

  /// 预占一次（本地乐观更新）。**仅在真正开始 AI 分析时调用。**
  QuotaState consume([int count = 1]) {
    if (isMember) return this;
    return copyWith(reserved: (reserved + count).clamp(0, total));
  }

  /// 回滚一次预占。分析失败 / 退出时调用。
  QuotaState rollback([int count = 1]) {
    if (isMember) return this;
    return copyWith(reserved: (reserved - count).clamp(0, total));
  }

  QuotaState copyWith({int? total, int? used, int? reserved, bool? isMember}) {
    return QuotaState(
      total: total ?? this.total,
      used: used ?? this.used,
      reserved: reserved ?? this.reserved,
      isMember: isMember ?? this.isMember,
    );
  }

  factory QuotaState.fromJson(Map<String, dynamic> json) {
    return QuotaState(
      total: json['total'] as int? ?? AppConstants.freeAnalysisQuota,
      used: json['used'] as int? ?? 0,
      reserved: json['reserved'] as int? ?? 0,
      isMember: json['isMember'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'total': total,
    'used': used,
    'reserved': reserved,
    'isMember': isMember,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuotaState &&
          other.total == total &&
          other.used == used &&
          other.reserved == reserved &&
          other.isMember == isMember;

  @override
  int get hashCode => Object.hash(total, used, reserved, isMember);

  @override
  String toString() =>
      'QuotaState(total: $total, used: $used, reserved: $reserved, '
      'remaining: $remaining, canAnalyze: $canAnalyze)';
}
