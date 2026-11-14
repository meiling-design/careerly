import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/router/back_navigation.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../onboarding/state/auth_provider.dart';

/// 注销账号。属于「我的 → 设置 → 账户」的二级页面。
///
/// ## 为什么需要这一页（不是可选功能）
///
/// Google Play 政策要求提供 App 内的账号删除入口，且删除请求必须覆盖
/// **账号本身与关联数据** —— 只有「退出登录」不算，那只结束本机会话。
///
/// ## ⚠️ 这一页说的每一句都必须是后端真实做到的事
///
/// 后端是**软删除 + 30 天缓冲**（`work_agent/app/api/router_auth.py` 的
/// `delete_account`）：账号立刻不可登录、旧凭据立刻失效，数据在缓冲期后
/// 由离线任务物理清除。因此本页：
///
/// ```text
/// ✅ 写「立即无法登录」       —— 真的立即发生
/// ✅ 写「30 天后彻底删除」    —— 真的由 purge 脚本执行
/// ❌ 不写「立即永久删除」     —— 那是另一个事实
/// ❌ 不写「数据已全部清除」   —— 产物文件有已知无法归属的部分，
///                              见 work_agent/docs/09_Release/DEPLOY_ECS.md §3
/// ```
///
/// ## 与「退出登录」的区别（页面必须让用户看懂）
///
/// 退出登录 → 账号还在，换台设备重登就能回来。
/// 注销账号 → 账号进入注销状态，**无法自助恢复**。
class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({super.key});

  /// 缓冲期天数。与后端 `PURGE_GRACE_DAYS` 一致。
  ///
  /// ⚠️ 这里**硬编码了一份**后端常量。不改成接口下发的原因是：
  /// 后端响应里已经带了 `purge_after_days`，但那是**提交之后**才知道的 ——
  /// 而本页要在用户点按钮**之前**就把窗口期说清楚。
  /// 改动后端窗口期时必须同步改这里，已在 `TODO.md` 登记为待跟进项。
  static const int purgeGraceDays = 30;

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    return CareerlyScaffold(
      title: '注销账号',
      leading: IconButton(
        onPressed: () => careerlyBack(context),
        icon: const Icon(Icons.arrow_back),
        tooltip: '返回',
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: <Widget>[
          _Section(
            title: '注销后会发生什么',
            children: <Widget>[
              _Bullet('你将无法再登录这个账号，旧凭据立即失效。'),
              _Bullet('你的简历、职业资产、分析结果与成长记录将不再可访问。'),
              _Bullet('$purgeGraceDays 天缓冲期后，这些数据会被永久删除，无法恢复。'),
              _Bullet('缓冲期内如需恢复，请联系客服 —— 你自己无法自助恢复。'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            title: '如果你只是想换个账号',
            children: <Widget>[
              _Bullet('只是想退出当前身份 → 回到设置页用「退出登录」，账号会被保留。'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CareerlyButton(
            label: '注销账号',
            variant: CareerlyButtonVariant.secondary,
            // 提交中禁用（四态 Disabled）—— 避免重复触发。
            onPressed: auth.isDeletingAccount
                ? null
                : () => _onDelete(context),
          ),
        ],
      ),
    );
  }

  /// 注销流程：强确认 → 调后端 → 回登录页。
  ///
  /// 成功后的落点与「退出登录」**完全一致**（`AppRoutes.onboardingSplash`）：
  /// 两者都表达同一个事实 ——「本机已经没有身份了」。
  /// 这里刻意不新造一个「注销成功页」：那是**新增产品页面**，
  /// 且 `CLAUDE.md` §0 第二禁令要求先经产品侧确认。
  Future<void> _onDelete(BuildContext context) async {
    final bool confirmed = await _confirmDelete(context);
    if (!confirmed || !context.mounted) return;

    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.deleteAccount();
    if (!context.mounted) return;

    if (!ok) {
      CareerlyToast.show(
        context,
        message: auth.deleteError?.message ?? '注销失败，请重试',
        icon: Icons.error_outline,
      );
      // 回到可操作状态，让用户能重试（否则按钮永久禁用）。
      auth.resetDeleteAccount();
      return;
    }

    CareerlyToast.show(
      context,
      message: '账号已注销，$purgeGraceDays 天后数据将被永久删除',
      icon: Icons.check_circle_outline,
    );
    context.go(AppRoutes.onboardingSplash);
  }

  /// 注销确认弹层。返回用户是否确认。
  ///
  /// 比退出确认**更重**是做在这里的：标题直说「永久删除」，
  /// 正文复述缓冲期，而确认按钮用「确认注销」而不是「确定」——
  /// 让用户在最后一屏仍然清楚自己在做什么。
  Future<bool> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await CareerlyBottomSheet.show<bool>(
      context,
      tone: CareerlyBottomSheetTone.confirm,
      // ⚠️ 用 [Builder] 拿**弹层自己的** context 来 pop：
      // 弹层被 push 到根 Navigator，而非本页所在的分支 Navigator
      // （与 `settings_page.dart` 的 `_confirmLogout` 同款写法）。
      child: Builder(
        builder: (BuildContext sheetContext) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('确认注销账号？', style: AppTypography.title),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '你的职业资产、分析结果与成长记录将在 $purgeGraceDays 天后被永久删除。'
                '这个操作无法自助撤销。',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              CareerlyButton(
                label: '确认注销',
                variant: CareerlyButtonVariant.secondary,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              const SizedBox(height: AppSpacing.xs),
              CareerlyButton(
                label: '取消',
                variant: CareerlyButtonVariant.neutral,
                onPressed: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      ),
    );

    // 点 scrim / 系统 Back 收掉弹层时结果是 null —— 一律按「取消」处理。
    // 对不可逆操作，这个默认方向是刻意的：**不做任何事**永远比误删安全。
    return confirmed ?? false;
  }
}

/// 一组带标题的说明块。
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
          child: Text(title, style: AppTypography.caption),
        ),
        CareerlyCard(
          variant: CareerlyCardVariant.glassLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

/// 一条说明。行首用中性圆点，不用图标 —— 这里没有需要靠图标区分的语义。
class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 7, right: AppSpacing.xs),
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.textTertiary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
