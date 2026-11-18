import 'package:flutter/material.dart';

import '../../../app/router/back_navigation.dart';
import '../../../core/services/support_mail.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../help_center_content.dart';
import 'widgets/support_email_action.dart';

/// 帮助中心。属于「设置 → 帮助与反馈」的二级页面，不是一级导航。
///
/// ## 交互
///
/// FAQ 默认收起，点击问题展开答案；同一时间只展开一项（手风琴）。
/// 选择单项展开而不是多项：一屏里同时铺开多个答案会让页面迅速变长，
/// 与「简洁、温柔、清晰」的既定方向相反。
///
/// ## 内容来源
///
/// 问题与答案在 `help_center_content.dart` 中维护，见该文件顶部的内容边界说明。
class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key, this.mailLauncher});

  /// 测试注入缝：默认打开系统邮件应用。
  final SupportMailLauncher? mailLauncher;

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  /// 当前展开的问题。`null` = 全部收起。
  String? _expandedKey;

  void _toggle(String key) {
    setState(() => _expandedKey = _expandedKey == key ? null : key);
  }

  Future<void> _contactUs() {
    return sendSupportMail(
      context,
      subject: 'Careerly 使用问题',
      body: '你好，我在使用 Careerly 时遇到了以下问题：\n\n',
      launcher: widget.mailLauncher,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CareerlyScaffold(
      title: '帮助中心',
      leading: IconButton(
        onPressed: () => careerlyBack(context),
        icon: const Icon(Icons.arrow_back),
        tooltip: '返回',
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: <Widget>[
          Text('遇到使用问题？在这里找到答案。', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          for (int categoryIndex = 0;
              categoryIndex < helpCenterCategories.length;
              categoryIndex++) ...<Widget>[
            if (categoryIndex > 0) const SizedBox(height: AppSpacing.lg),
            _HelpCategoryView(
              category: helpCenterCategories[categoryIndex],
              categoryIndex: categoryIndex,
              expandedKey: _expandedKey,
              onToggle: _toggle,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          _ContactCard(onContact: _contactUs),
        ],
      ),
    );
  }
}

/// 一个分类：标题 + 手风琴卡片。
class _HelpCategoryView extends StatelessWidget {
  const _HelpCategoryView({
    required this.category,
    required this.categoryIndex,
    required this.expandedKey,
    required this.onToggle,
  });

  final HelpCategory category;
  final int categoryIndex;
  final String? expandedKey;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(category.title, style: AppTypography.subtitle),
        ),
        const SizedBox(height: AppSpacing.sm),
        CareerlyCard(
          variant: CareerlyCardVariant.glassLight,
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              for (int itemIndex = 0;
                  itemIndex < category.items.length;
                  itemIndex++) ...<Widget>[
                if (itemIndex > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
                _FaqTile(
                  item: category.items[itemIndex],
                  expanded: expandedKey == '$categoryIndex-$itemIndex',
                  onTap: () => onToggle('$categoryIndex-$itemIndex'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 单条 FAQ：问题行 + 可展开答案。
class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.item,
    required this.expanded,
    required this.onTap,
  });

  final HelpItem item;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.question,
                      style: AppTypography.bodyStrong,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: AppMotion.micro,
                    curve: AppMotion.standard,
                    child: const Icon(
                      Icons.expand_more,
                      size: _HelpMetrics.chevronSize,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // 收起时**不构建**答案节点：读屏器不会读到隐藏内容，
            // 测试里的「默认收起」也才是真的。
            AnimatedSize(
              duration: AppMotion.smallComponent,
              curve: AppMotion.standard,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: Text(item.answer, style: AppTypography.bodySmall),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

/// 底部「还没有解决你的问题？」。
class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.onContact});

  final Future<void> Function() onContact;

  @override
  Widget build(BuildContext context) {
    return CareerlyCard(
      variant: CareerlyCardVariant.glassLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('还没有解决你的问题？', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '欢迎告诉我们你遇到的问题，我们会持续改进 Careerly。',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              const Icon(
                Icons.mail_outline,
                size: _HelpMetrics.mailIconSize,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  SupportMail.address,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          CareerlyButton(
            label: '联系我们',
            variant: CareerlyButtonVariant.secondary,
            icon: Icons.mail_outline,
            onPressed: onContact,
          ),
        ],
      ),
    );
  }
}

abstract final class _HelpMetrics {
  static const double chevronSize = 20;
  static const double mailIconSize = 18;
}
