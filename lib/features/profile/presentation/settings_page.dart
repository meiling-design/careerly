import 'package:flutter/material.dart';

import '../../../app/router/back_navigation.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';

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

  @override
  Widget build(BuildContext context) {
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
              _SettingsRow(label: '个人信息', icon: Icons.person_outline, onTap: () {}),
            ],
          ),
          _SettingsSection(
            title: 'AI 与通知',
            children: <Widget>[
              _SettingsSwitch(
                label: 'AI 主动建议',
                value: _proactiveAdvice,
                onChanged: (bool value) => setState(() => _proactiveAdvice = value),
              ),
              _SettingsSwitch(
                label: '每日职业简报',
                value: _dailyBriefing,
                onChanged: (bool value) => setState(() => _dailyBriefing = value),
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
          _SettingsSection(
            title: '更多',
            children: <Widget>[
              _SettingsRow(label: '隐私与数据', icon: Icons.shield_outlined, onTap: () {}),
              _SettingsRow(label: '帮助中心', icon: Icons.help_outline, onTap: () {}),
              _SettingsRow(label: '关于 Careerly', icon: Icons.info_outline, onTap: () {}),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CareerlyButton(
            label: '退出登录',
            variant: CareerlyButtonVariant.neutral,
            onPressed: () {},
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
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
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
  const _SettingsRow({required this.label, required this.icon, required this.onTap});
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
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({required this.label, required this.value, required this.onChanged});
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
  const _SettingsChoice({required this.label, required this.selected, required this.onTap});
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
