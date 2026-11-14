import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/router/back_navigation.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../onboarding/state/auth_provider.dart';

/// 设置页。属于「我的 → 齿轮」的二级页面，不是一级导航。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _proactiveAdvice = true;
  bool _dailyBriefing = false;
  bool _matchAlert = true;
  String _answerStyle = '行动导向';

  /// 退出登录。
  ///
  /// ⚠️ 「先确认再退出」这一步是 **Flutter 侧补齐的交互**：
  /// Figma 只画了按钮，**没有**退出确认层的规格。补它的理由与既有
  /// `CareerlyBackGuard` 同型 —— 退出会丢弃本机身份（需重新登录），
  /// 属不可逆操作，与 Back 的「未保存修改先确认」是同一类保护。
  /// 该交互与文案**未经产品侧确认**，已在交付报告中登记为待裁决项。
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
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('要退出登录吗？', style: AppTypography.title),
              const SizedBox(height: AppSpacing.xs),
              Text('退出后需要重新登录才能查看你的职业资产与成长记录。', style: AppTypography.bodySmall),
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

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

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
              // 2026-10-07 接线。此前是空壳 `onTap: () {}`。
              //
              // ⚠️ 这处空壳**从未被任何条目登记过** —— `TODO.md` §2.2 · K22 ②
              // 记的是下面「隐私与数据」那一行的空壳（同日修复），
              // 是**两处不同的**空壳，别混为一谈。
              //
              // ⚠️ Figma 全稿**没有「个人信息」这一页**，页面是按
              // 「设置 → 账户」的既有形态 + 两个已有接口拼的，
              // 因此登记 **待裁决 · D125**（`docs/05_progress/TODO.md` §3.1）。
              //
              // ⚠️ 该页**只读**（用户裁决：「先跑通只读」）——
              // 页面内没有任何输入控件，编辑路径本轮未做。
              _SettingsRow(
                label: '个人信息',
                icon: Icons.person_outline,
                onTap: () => context.push(AppRoutes.settingsPersonalInfo),
              ),
            ],
          ),
          _SettingsSection(
            title: 'AI 与通知',
            children: <Widget>[
              _SettingsSwitch(
                label: 'AI 主动建议',
                value: _proactiveAdvice,
                onChanged: (bool value) =>
                    setState(() => _proactiveAdvice = value),
              ),
              _SettingsSwitch(
                label: '每日职业简报',
                value: _dailyBriefing,
                onChanged: (bool value) =>
                    setState(() => _dailyBriefing = value),
              ),
              _SettingsSwitch(
                label: '匹配变化提醒',
                value: _matchAlert,
                onChanged: (bool value) => setState(() => _matchAlert = value),
              ),
            ],
          ),
          _SettingsSection(
            title: 'AI 回答风格',
            children: <Widget>[
              for (final String style in <String>['简洁', '详细', '行动导向'])
                _SettingsChoice(
                  label: style,
                  selected: _answerStyle == style,
                  onTap: () => setState(() => _answerStyle = style),
                ),
            ],
          ),
          // 发布基线 §1.0f · E3 与 D123。
          //
          // 原先这里是一行「隐私与数据」指向隐私政策（此前还是空壳
          // `onTap: () {}`，TODO §2.2 · K22 ② 记的正是那一条）。
          // 2026-10-07 产品侧裁决 **D123 = A**：三份文档在**设置页平铺**，
          // 于是这一行升级成一个独立分区。
          //
          // ⚠️ 三个入口**都是二级页**，`context.push` 进入、Back 回设置页。
          // 与注册页的同意链接指向**同一批路由**（`/legal/*`），
          // 不是两套页面 —— 两份文档共用一个 `LegalDocumentPage`。
          _SettingsSection(
            title: '隐私与数据',
            children: <Widget>[
              _SettingsRow(
                label: '删除职业数据',
                icon: Icons.delete_sweep_outlined,
                onTap: () => context.push(AppRoutes.settingsDeleteCareerData),
              ),
              _SettingsRow(
                label: '注销账号',
                icon: Icons.delete_outline,
                onTap: () => context.push(AppRoutes.settingsDeleteAccount),
              ),
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
              // 第三份（E1 要求三份齐备）。在此之前它只进资产与镜像、
              // App 内没有任何入口 —— 见 `LegalDocument` 的类文档。
              _SettingsRow(
                label: 'AI 数据使用说明',
                icon: Icons.smart_toy_outlined,
                onTap: () => context.push(AppRoutes.legalAiData),
              ),
            ],
          ),
          _SettingsSection(
            title: '更多',
            children: <Widget>[
              _SettingsRow(
                label: '帮助中心',
                icon: Icons.help_outline,
                onTap: () {},
              ),
              _SettingsRow(
                label: '关于 Careerly',
                icon: Icons.info_outline,
                onTap: () {},
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
            child: Text(title, style: AppTypography.caption),
          ),
          CareerlyCard(
            variant: CareerlyCardVariant.glassLight,
            padding: EdgeInsets.zero,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.textSecondary, size: 20),
        title: Text(label, style: AppTypography.bodySmall),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
          size: 20,
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
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
        activeThumbColor: AppColors.primaryBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    );
  }
}

class _SettingsChoice extends StatelessWidget {
  const _SettingsChoice({
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
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? AppColors.primaryBlue : AppColors.textTertiary,
        ),
        title: Text(label, style: AppTypography.bodySmall),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    );
  }
}
