import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/router/back_navigation.dart';
import '../../../data/models/assistant_settings.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../onboarding/state/auth_provider.dart';
import '../state/settings_provider.dart';

/// 设置页。属于「我的 → 齿轮」的二级页面，不是一级导航。
///
/// ## 分组
///
/// ```text
/// 账户          个人信息（只读汇总）
/// AI 与通知     三个开关（本机持久化）
/// AI 回答风格   三个单选项（本机持久化）
/// 隐私与数据     三份协议文档
/// 帮助与反馈     帮助中心 / 意见反馈 / 关于 Careerly
/// 危险操作       删除职业数据 / 注销账号
/// 退出登录
/// ```
///
/// 开关与单选的改动会**真实写入本地存储**（`SettingsProvider`），
/// 不再只是 `setState` 的临时状态。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// 退出登录。
  ///
  /// ⚠️ 「先确认再退出」这一步是 **Flutter 侧补齐的交互**：
  /// Figma 只画了按钮，**没有**退出确认层的规格。补它的理由与既有
  /// `CareerlyBackGuard` 同型 —— 退出会丢弃本机身份（需重新登录），
  /// 属不可逆操作，与 Back 的「未保存修改先确认」是同一类保护。
  Future<void> _onLogout(BuildContext context) async {
    final bool confirmed = await _confirmLogout(context);
    if (!confirmed || !context.mounted) return;

    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.logout();
    if (!context.mounted) return;

    if (!ok) {
      CareerlyToast.show(
        context,
        message: auth.error?.message ?? '退出登录失败，请重试',
        icon: Icons.error_outline,
      );
      auth.reset();
      return;
    }

    // 退出的落点 = 登录页。⚠️ 这里**不**回答 D54（App 冷启动落在哪一屏）——
    // 它只表达「用户主动登出后，本机没有身份，应回到登录入口」。
    context.go(AppRoutes.onboardingSplash);
  }

  /// 退出确认弹层。返回用户是否确认退出。
  Future<bool> _confirmLogout(BuildContext context) async {
    final bool? confirmed = await CareerlyBottomSheet.show<bool>(
      context,
      tone: CareerlyBottomSheetTone.confirm,
      // ⚠️ 必须用 [Builder] 拿**弹层自己的** context 来 pop：
      // 弹层被 push 到根 Navigator，而非本页所在的分支 Navigator
      // （`back_navigation.dart` 的 `CareerlyBackGuard.confirm` 同款写法）。
      child: Builder(
        builder: (BuildContext sheetContext) => Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('要退出登录吗？', style: AppTypography.title),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '退出后需要重新登录才能查看你的职业资产与成长记录。',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              CareerlyButton(
                label: '退出登录',
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
    return confirmed ?? false;
  }

  /// 执行一次偏好写入，并在写入失败时给出可见反馈。
  ///
  /// `SettingsProvider` 会先更新界面再写盘（避免开关卡顿），
  /// 因此失败只能事后提示，而不是阻止这次切换。
  Future<void> _persist(Future<void> Function() action) async {
    await action();
    if (!mounted) return;

    final SettingsProvider settings = context.read<SettingsProvider>();
    if (settings.lastWriteError != null) {
      CareerlyToast.show(
        context,
        message: '偏好保存失败，请稍后重试',
        icon: Icons.error_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final SettingsProvider settings = context.watch<SettingsProvider>();

    return CareerlyScaffold(
      title: '设置',
      leading: IconButton(
        onPressed: () => careerlyBack(context),
        icon: const Icon(Icons.arrow_back),
        tooltip: '返回',
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: <Widget>[
          _SettingsSection(
            title: '账户',
            children: <Widget>[
              _SettingsRow(
                label: '个人信息',
                icon: Icons.person_outline,
                onTap: () => context.push(AppRoutes.settingsPersonalInfo),
              ),
            ],
          ),
          _SettingsSection(
            title: 'AI 与通知',
            // 如实写出当前能力边界：偏好会保存，但提醒 / 推送尚未开放，
            // 不让开关看起来像「已经会发通知」。
            description: '以下偏好会保存在本机；相关提醒与推送能力尚未开放。',
            children: <Widget>[
              _SettingsSwitch(
                key: const ValueKey<String>('settings-proactive-advice'),
                label: 'AI 主动建议',
                value: settings.proactiveAdvice,
                onChanged: (bool value) =>
                    _persist(() => settings.setProactiveAdvice(value)),
              ),
              _SettingsSwitch(
                key: const ValueKey<String>('settings-daily-briefing'),
                label: '每日职业简报',
                value: settings.dailyBriefing,
                onChanged: (bool value) =>
                    _persist(() => settings.setDailyBriefing(value)),
              ),
              _SettingsSwitch(
                key: const ValueKey<String>('settings-match-alert'),
                label: '匹配变化提醒',
                value: settings.matchAlert,
                onChanged: (bool value) =>
                    _persist(() => settings.setMatchAlert(value)),
              ),
            ],
          ),
          _SettingsSection(
            title: 'AI 回答风格',
            // 同理：选择会持久化，但当前 AI 请求没有携带风格字段
            // （后端接口未定义），不写成「已按此风格回答」。
            description: '选择会保存在本机；当前 AI 对话暂未按该偏好调整回答。',
            children: <Widget>[
              for (final AiAnswerStyle style in AiAnswerStyle.values)
                _SettingsChoice(
                  key: ValueKey<String>(
                    'settings-answer-style-${style.storageKey}',
                  ),
                  label: style.label,
                  selected: settings.answerStyle == style,
                  onTap: () =>
                      _persist(() => settings.setAnswerStyle(style)),
                ),
            ],
          ),
          // 发布基线 §1.0f · E3 与 D123：三份文档在设置页平铺。
          _SettingsSection(
            title: '隐私与数据',
            description: '了解 Careerly 如何处理你的数据。',
            children: <Widget>[
              _SettingsRow(
                label: '用户协议',
                icon: Icons.description_outlined,
                onTap: () => context.push(AppRoutes.legalTerms),
              ),
              _SettingsRow(
                label: '隐私政策',
                icon: Icons.shield_outlined,
                onTap: () => context.push(AppRoutes.legalPrivacy),
              ),
              _SettingsRow(
                label: 'AI 数据使用说明',
                icon: Icons.smart_toy_outlined,
                onTap: () => context.push(AppRoutes.legalAiData),
              ),
            ],
          ),
          _SettingsSection(
            title: '帮助与反馈',
            description: '获取使用帮助、反馈建议，了解 Careerly。',
            children: <Widget>[
              _SettingsRow(
                label: '帮助中心',
                description: '遇到使用问题？在这里找到答案。',
                icon: Icons.help_outline,
                onTap: () => context.push(AppRoutes.settingsHelp),
              ),
              _SettingsRow(
                label: '意见反馈',
                description: '你的每一条建议，都能帮助 Careerly 变得更好。',
                icon: Icons.feedback_outlined,
                onTap: () => context.push(AppRoutes.settingsFeedback),
              ),
              _SettingsRow(
                label: '关于 Careerly',
                description: '了解 Careerly 的产品理念与品牌故事。',
                icon: Icons.info_outline,
                onTap: () => context.push(AppRoutes.settingsAbout),
              ),
            ],
          ),
          // 危险操作独立成组：与普通设置拉开距离，并用 danger 语义色
          // 明确「点进去会发生不可逆的事」。真正的二次确认在二级页里。
          _SettingsSection(
            title: '危险操作',
            description: '以下操作不可撤销，请确认后再继续。',
            danger: true,
            children: <Widget>[
              _SettingsRow(
                label: '删除职业数据',
                description: '清除简历、岗位分析与成长记录，账号保留。',
                icon: Icons.delete_sweep_outlined,
                danger: true,
                onTap: () => context.push(AppRoutes.settingsDeleteCareerData),
              ),
              _SettingsRow(
                label: '注销账号',
                description: '账号进入注销状态，30 天后永久删除。',
                icon: Icons.delete_outline,
                danger: true,
                onTap: () => context.push(AppRoutes.settingsDeleteAccount),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CareerlyButton(
            label: '退出登录',
            variant: CareerlyButtonVariant.neutral,
            // 退出中禁用（四态 Disabled）—— 避免重复触发。
            onPressed: auth.isLoggingOut ? null : () => _onLogout(context),
          ),
        ],
      ),
    );
  }
}

/// 一个设置分组：标题（可选说明）+ 玻璃卡片。
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
    this.description,
    this.danger = false,
  });

  final String title;
  final List<Widget> children;
  final String? description;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = danger
        ? AppTypography.onSurfaceVariant(AppTypography.caption, AppColors.danger)
        : AppTypography.caption;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: titleStyle),
                if (description != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description!,
                    style: AppTypography.onSurfaceVariant(
                      AppTypography.caption,
                      danger
                          ? AppColors.danger
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          CareerlyCard(
            variant: CareerlyCardVariant.glassLight,
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                for (int index = 0; index < children.length; index++) ...[
                  if (index > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.divider,
                    ),
                  children[index],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 一行可点击的设置项。
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.icon,
    required this.onTap,
    this.description,
    this.danger = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? description;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final Color foreground = danger ? AppColors.danger : AppColors.textPrimary;
    final Color iconColor = danger ? AppColors.danger : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor, size: _SettingsMetrics.iconSize),
        title: Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: foreground),
        ),
        subtitle: description == null
            ? null
            : Text(description!, style: AppTypography.caption),
        trailing: Icon(
          Icons.chevron_right,
          color: danger ? AppColors.danger : AppColors.textTertiary,
          size: _SettingsMetrics.iconSize,
        ),
      ),
    );
  }
}

/// 开关行。关闭态仍用可辨认的灰色轨道 + 描边，避免「看起来像禁用」。
class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        title: Text(label, style: AppTypography.bodySmall),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => AppColors.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? AppColors.primaryBlue
              : AppColors.divider,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? AppColors.primaryBlue
              : AppColors.textTertiary,
        ),
      ),
    );
  }
}

/// 单选行。选中态用品牌蓝底衬 + 实心圆点；未选中仍是清晰的空心圆。
class _SettingsChoice extends StatelessWidget {
  const _SettingsChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryBlueSurface : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? AppColors.primaryBlue : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: selected ? AppColors.primaryBlue : AppColors.textPrimary,
          ),
        ),
        trailing: selected
            ? const Icon(
                Icons.check_rounded,
                color: AppColors.primaryBlue,
                size: _SettingsMetrics.checkSize,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    );
  }
}

abstract final class _SettingsMetrics {
  static const double iconSize = 20;
  static const double checkSize = 18;
}
