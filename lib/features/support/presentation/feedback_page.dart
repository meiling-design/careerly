import 'package:flutter/material.dart';

import '../../../app/router/back_navigation.dart';
import '../../../core/services/support_mail.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import 'widgets/support_email_action.dart';

/// 反馈类型。顺序即页面顺序。
enum _FeedbackType {
  feature('功能建议'),
  issue('使用问题'),
  other('其他反馈');

  const _FeedbackType(this.label);

  final String label;
}

/// 意见反馈。属于「设置 → 帮助与反馈」的二级页面，不是一级导航。
///
/// ## 为什么不是「提交表单」
///
/// 后端没有 feedback 端点。如果做一个「点提交 → 清空表单 → 提示已收到」
/// 的假流程，用户会以为反馈真的送达了，实际没有任何去向。
///
/// 这里把整页明确成**邮件反馈**：
///
/// ```text
/// 按钮文案      「通过邮件发送」
/// 页面说明      会打开系统邮件应用，邮件真正发出后才送达
/// 失败兜底      复制整封邮件内容 + 收件地址，用户可手动发送
/// ```
///
/// 这样入口是真实可用的，也不伪造成功状态。
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key, this.mailLauncher});

  /// 测试注入缝：默认打开系统邮件应用。
  final SupportMailLauncher? mailLauncher;

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  _FeedbackType _type = _FeedbackType.feature;
  String? _descriptionError;
  String? _emailError;

  @override
  void dispose() {
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _descriptionController.text.trim().isNotEmpty;

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  Future<void> _submit() async {
    final String description = _descriptionController.text.trim();
    final String email = _emailController.text.trim();

    final String? descriptionError = description.isEmpty
        ? '请描述你遇到的问题或建议'
        : null;
    final String? emailError =
        email.isNotEmpty && !_isValidEmail(email) ? '请检查邮箱地址格式' : null;

    setState(() {
      _descriptionError = descriptionError;
      _emailError = emailError;
    });

    if (descriptionError != null || emailError != null) return;

    final String subject = '[Careerly 反馈][${_type.label}]';
    final String body =
        '反馈类型：${_type.label}\n\n'
        '反馈内容：\n$description\n\n'
        '联系邮箱：${email.isEmpty ? '未填写' : email}\n';

    await sendSupportMail(
      context,
      subject: subject,
      body: body,
      // 邮件应用不可用时，复制的不只是邮箱，而是整封邮件 ——
      // 否则用户已经写好的内容会丢。
      clipboardFallback:
          '收件邮箱：${SupportMail.address}\n'
          '主题：$subject\n\n'
          '$body',
      launcher: widget.mailLauncher,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CareerlyScaffold(
      title: '意见反馈',
      leading: IconButton(
        onPressed: () => careerlyBack(context),
        icon: const Icon(Icons.arrow_back),
        tooltip: '返回',
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: <Widget>[
          Text(
            '你的每一条建议，都能帮助 Careerly 变得更好。',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text('反馈类型', style: AppTypography.caption),
          ),
          const SizedBox(height: AppSpacing.xs),
          CareerlyCard(
            variant: CareerlyCardVariant.glassLight,
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                for (int index = 0;
                    index < _FeedbackType.values.length;
                    index++) ...<Widget>[
                  if (index > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.divider,
                    ),
                  _FeedbackTypeTile(
                    type: _FeedbackType.values[index],
                    selected: _type == _FeedbackType.values[index],
                    onTap: () =>
                        setState(() => _type = _FeedbackType.values[index]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          CareerlyInput(
            key: const ValueKey<String>('feedback-description'),
            variant: CareerlyInputVariant.boxed,
            label: '反馈内容',
            hint: '说说你遇到了什么问题，或希望 Careerly 增加什么功能…',
            controller: _descriptionController,
            maxLines: 6,
            minLines: 5,
            maxLength: 2000,
            errorText: _descriptionError,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          CareerlyInput(
            key: const ValueKey<String>('feedback-email'),
            variant: CareerlyInputVariant.boxed,
            label: '联系邮箱（选填）',
            hint: '方便我们回复你',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '点击「通过邮件发送」后会打开你的邮件应用；'
            '邮件真正发出后，我们才会收到反馈。',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          CareerlyButton(
            label: '通过邮件发送',
            icon: Icons.mail_outline,
            onPressed: _canSubmit ? _submit : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(SupportMail.address, style: AppTypography.caption),
          ),
        ],
      ),
    );
  }
}

/// 一个反馈类型选项。
class _FeedbackTypeTile extends StatelessWidget {
  const _FeedbackTypeTile({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final _FeedbackType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color ink = selected ? AppColors.primaryBlue : AppColors.textPrimary;

    return Material(
      color: selected ? AppColors.primaryBlueSurface : Colors.transparent,
      child: ListTile(
        key: ValueKey<String>('feedback-type-${type.name}'),
        onTap: onTap,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          // 未选中用 textSecondary 而不是 textTertiary ——
          // 保证浅色玻璃底上仍然看得清「这是可选项」。
          color: selected ? AppColors.primaryBlue : AppColors.textSecondary,
        ),
        title: Text(
          type.label,
          style: AppTypography.bodySmall.copyWith(color: ink),
        ),
        trailing: selected
            ? const Icon(
                Icons.check_rounded,
                color: AppColors.primaryBlue,
                size: _FeedbackMetrics.selectedIconSize,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
        ),
      ),
    );
  }
}

abstract final class _FeedbackMetrics {
  static const double selectedIconSize = 20;
}
