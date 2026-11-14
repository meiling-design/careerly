import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/router/back_navigation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/onboarding_provider.dart';
import 'widgets/password_visibility_toggle.dart';

/// 重置密码 —— 登录页「忘记密码?」的落点。
///
/// ## 为什么现在才有这一页
///
/// 「忘记密码?」在 Figma 里本来就是**没有 onClick 的死链**，项目此前也
/// 没有找回链路（后端无端点、无路由），所以登录页只如实提示「尚未接入」。
/// 2026-11-13 产品侧要求补齐。
///
/// ## ⚠️ 当前是 DEV-only 重置，不是正式找回
///
/// 密码是 bcrypt 哈希，**无法找回，只能重置**。后端
/// `POST /api/v1/auth/reset-password` 只在 `AUTH_MODE=dev` 时开放，
/// 正式部署返回 `501 PASSWORD_RESET_UNAVAILABLE`。页面因此：
///
/// ```text
/// ✅ 说明「重置后其他设备的登录会失效」 —— 后端真的吊销全部旧令牌
/// ✅ 正式形态下展示后端返回的 501 文案 —— 不假装成功
/// ❌ 不写「通过短信验证码找回」       —— 当前没有这条链路
/// ```
///
/// ## 数据链路
///
/// ```text
/// 本页 → OnboardingProvider.resetPassword → AuthRepository → Mock | API
/// ```
///
/// 与注册 / 登录页**共用同一个 Provider 与同一套四态**（`CLAUDE.md` §6.3：
/// 不为一模一样的状态机新建第二个类）。
class OnboardingResetPasswordPage extends StatefulWidget {
  const OnboardingResetPasswordPage({super.key});

  @override
  State<OnboardingResetPasswordPage> createState() =>
      _OnboardingResetPasswordPageState();
}

class _OnboardingResetPasswordPageState
    extends State<OnboardingResetPasswordPage> {
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    for (final TextEditingController controller in <TextEditingController>[
      _phone,
      _newPassword,
      _confirmPassword,
    ]) {
      controller.addListener(_onFieldChanged);
    }
    // 进入本页时清掉上一次留下的成功 / 失败残状态。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OnboardingProvider>().reset();
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  /// 提交条件：手机号非空、新密码达到后端下界、两次输入一致。
  ///
  /// 密码**不做 `trim()`** —— 首尾空格是密码的一部分（与注册页同一规则）。
  bool get _canSubmit =>
      _phone.text.trim().isNotEmpty &&
      _newPassword.text.length >= AppConstants.passwordMinLength &&
      _confirmPassword.text == _newPassword.text;

  Future<void> _submit() async {
    final OnboardingProvider provider = context.read<OnboardingProvider>();

    final bool ok = await provider.resetPassword(
      phone: _phone.text,
      newPassword: _newPassword.text,
    );

    if (!mounted) return;

    if (!ok) {
      CareerlyToast.show(
        context,
        message: provider.error?.message ?? '密码重置失败，请重试',
        icon: Icons.error_outline,
        // Onboarding 没有底部导航，提示贴底即可。
        bottomOffset: AppSpacing.xxl,
      );
      return;
    }

    CareerlyToast.show(
      context,
      message: '密码已重置，请用新密码登录',
      icon: Icons.check_circle_outline,
      bottomOffset: AppSpacing.xxl,
    );
    // 重置不等于登录：回到登录页，让用户用新密码重新建立会话。
    context.go(AppRoutes.onboardingLogin);
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingProvider provider = context.watch<OnboardingProvider>();
    final bool submitting = provider.isSubmitting;
    final bool enabled = !submitting;

    return CareerlyScaffold(
      title: '重置密码',
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
          const Text(
            '输入注册手机号并设置新密码。重置成功后，其他设备上的登录会立即失效。',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          CareerlyInput(
            variant: CareerlyInputVariant.outlined,
            label: '注册手机号',
            hint: '+86 138 0000 0000',
            controller: _phone,
            enabled: enabled,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.authFieldGap),
          CareerlyInput(
            variant: CareerlyInputVariant.outlined,
            label: '新密码',
            hint: '至少 ${AppConstants.passwordMinLength} 位',
            controller: _newPassword,
            enabled: enabled,
            obscureText: !_showPassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            suffix: PasswordVisibilityToggle(
              visible: _showPassword,
              onPressed: enabled
                  ? () => setState(() => _showPassword = !_showPassword)
                  : () {},
            ),
          ),
          const SizedBox(height: AppSpacing.authFieldGap),
          CareerlyInput(
            variant: CareerlyInputVariant.outlined,
            label: '确认新密码',
            hint: '再次输入新密码',
            controller: _confirmPassword,
            enabled: enabled,
            obscureText: !_showPassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            // 两次不一致时给出即时提示，但不阻塞输入。
            helperText: _confirmPassword.text.isEmpty ||
                    _confirmPassword.text == _newPassword.text
                ? null
                : '两次输入的密码不一致',
          ),
          const SizedBox(height: AppSpacing.lg),
          CareerlyButton(
            label: submitting ? '重置中…' : '重置密码',
            variant: CareerlyButtonVariant.authPrimary,
            onPressed: enabled && _canSubmit ? _submit : null,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            '当前版本仅在开发模式下支持重置；正式找回通道（短信 / 邮箱验证）尚未上线。',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}
