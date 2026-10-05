import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/onboarding_provider.dart';
import 'widgets/auth_social_row.dart';
import 'widgets/onboarding_progress_header.dart';
import 'widgets/password_visibility_toggle.dart';

/// 注册页 —— Onboarding 第 2 屏（注册 / 登录二选一）。
///
/// 真值来源：Figma `OnRegister`（2026-10-04 重新导出版 `src/App.tsx` L661-797）。
///
/// ```text
/// 背景   页面自带渐变（142.84deg，终点 #FDF4FF）—— 与全局背景不同，故自铺一层
/// 顶部   OnboardingProgressHeader(step: 1, total: 4)
/// 内容   创建你的个人账号 📋 → 只有你能看到你的个人信息…
///        → 头像（80×88 + 编辑徽标）
///        → 名字 / 手机号 / 密码（方框输入框）
///        → 「创建账号」 → Or sign up with → 微信 / QQ
/// ```
///
/// ## ⚠️ 本页在 2026-10-04 被**重写**（不是微调）
///
/// 新稿相对旧稿是三处结构性变化，逐条对应删除的内容：
///
/// | | 旧稿（已删除） | 新稿（本实现） |
/// |---|---|---|
/// | 字段 | 姓名 / 手机号 / 邮箱（选填） | 名字 / 手机号 / **密码** |
/// | 底部 | 「继续」+「跳过，稍后完善」 | 「创建账号」+ 分隔线 + 微信 / QQ |
/// | 输入框 | 下划线（`underline`） | 方框（`outlined`，1px / r10 / h52） |
/// | 标签 | 大写加粗灰 `#727272` | 常规紫 `#664293` |
///
/// 与之一起删除的还有 **D85** 带来的整套「双形态」机制：
/// `OnboardingAccountMode` / `fromQuery` / `_AccountModeSwitch` /
/// 标题与表单项的形态分支。登录**不再是本页的另一种形态**，
/// 而是独立页面 `/onboarding/login`（见 `OnboardingLoginPage` 的类文档）。
///
/// ## 校验（Flutter 侧补齐，Figma 未定义）
///
/// **名字非空 且 手机号非空 且 密码 >= [AppConstants.passwordMinLength] 位**。
///
/// 前两条沿用 **D57** 的「最小非空」思路（不发明手机号格式校验）；
/// 密码下界是**后端**规则的镜像（`passwords.MIN_PASSWORD_LENGTH`）。
/// 这套三字段规则已登记为待裁决项，**不得盖章为产品已确认**。
///
/// ## 数据链路
///
/// ```text
/// 本页 → OnboardingProvider → AuthRepository → Mock | API
/// ```
///
/// ⚠️ 旧的类文档写的是「D52：纯 Mock、不接真实鉴权」—— **那已不成立**。
/// 现在 `ApiAuthRepository` 会真实注册并把 JWT 写进 `ApiClient` 会话。
/// 过时的只是「登录后去哪」这条**产品规则**仍是 D85 的（见 `_goAfterSubmit`）。
class OnboardingRegisterPage extends StatefulWidget {
  const OnboardingRegisterPage({super.key});

  @override
  State<OnboardingRegisterPage> createState() => _OnboardingRegisterPageState();
}

class _OnboardingRegisterPageState extends State<OnboardingRegisterPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();

  /// 密码是否明文可见。
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    for (final TextEditingController controller in <TextEditingController>[
      _name,
      _phone,
      _password,
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
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  /// 主按钮是否可用。规则见类文档「校验」一节。
  bool get _canSubmit =>
      _name.text.trim().isNotEmpty &&
      _phone.text.trim().isNotEmpty &&
      _password.text.length >= AppConstants.passwordMinLength;

  Future<void> _submit() async {
    final OnboardingProvider provider = context.read<OnboardingProvider>();

    final bool ok = await provider.submit(
      // ⚠️ 名字 trim，密码**不 trim** —— 首尾空格是密码的一部分
      // （trim 掉会让用户的密码与他自己以为的不一致）。
      name: _name.text,
      phone: _phone.text,
      password: _password.text,
    );

    if (!mounted) return;

    if (!ok) {
      CareerlyToast.show(
        context,
        message: provider.error?.message ?? '注册失败，请重试',
        icon: Icons.error_outline,
        // Onboarding 没有底部导航，提示贴底即可。
        bottomOffset: AppSpacing.xxl,
      );
      return;
    }

    _goAfterSubmit();
  }

  /// 第三方注册（微信 / QQ）—— 与登录页**完全同一条链路**。
  ///
  /// 后端当前一律 501（未配置 / 未开通），本页把它的原文如实展示：
  /// **不静默失败，也不假装成功**（见 `AuthRepository.signInWithOAuth`）。
  Future<void> _signUpWithOAuth(String provider) async {
    final OnboardingProvider state = context.read<OnboardingProvider>();

    final bool ok = await state.signInWithOAuth(provider: provider);

    if (!mounted) return;

    if (!ok) {
      CareerlyToast.show(
        context,
        message: state.error?.message ?? '第三方注册暂不可用',
        icon: Icons.error_outline,
        bottomOffset: AppSpacing.xxl,
      );
      return;
    }

    // ⚠️ 当前不可达（后端一律 501），去向与手机号注册对齐。
    _goAfterSubmit();
  }

  /// 提交成功后的去向：继续 Onboarding（提交简历）。
  ///
  /// ⚠️ 六步链路是「开屏 → 注册/登录 → **on-welcome** → 提交简历 → 解析 → 确认」，
  /// 而 `on-welcome` 的真实语义是**用户身份选择**（产品侧裁决 **D61**），
  /// 其规格**尚未给出**，因此该屏**未进入实现队列**。
  /// 在它缺位的情况下注册完成后没有该屏可去，故直接指向「提交简历」。
  /// 待规格落地后，把这一行改回 `AppRoutes.onboardingWelcome` 即可 ——
  /// 改动为一行，见 `TODO.md` §3.2 · D61 的「接线缺口」说明。
  ///
  /// ⚠️ 旧稿的「跳过，稍后完善」也走这个去向，新稿**已无该按钮**。
  void _goAfterSubmit() => context.go(AppRoutes.onboardingResume);

  @override
  Widget build(BuildContext context) {
    final OnboardingProvider provider = context.watch<OnboardingProvider>();
    final bool submitting = provider.isSubmitting;

    return Scaffold(
      // Careerly 全页面共用透明 Scaffold —— 但本页背景与全局渐变不同
      // （142.84deg / 终点 #FDF4FF），因此自己铺一层盖住它。
      // 依据 `CLAUDE.md` §10.4：全局渐变只在 root builder 画一次，
      // 页面要换背景就自己铺一层，**不要**改 root。
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.onboardingGradient),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              OnboardingProgressHeader(
                step: 1,
                total: 4,
                // ⚠️ Onboarding 全流程（6 屏）都是**平铺的一级路由**，
                // 页面之间用 `context.go` 切换，导航栈里没有上一层，
                // 因此这里**不能**用 `careerlyBack`（`Navigator.maybePop`
                // 会找不到可 pop 的页面，返回键变成静默死键）。
                // 本次沿用本流程既有做法 —— 见交付报告中的发现项。
                onBack: () => context.go(AppRoutes.onboardingSplash),
              ),
              Expanded(
                child: SingleChildScrollView(
                  // Figma `px-6 pb-6 pt-6`。
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    _RegisterMetrics.contentPadding,
                    _RegisterMetrics.contentPadding,
                    _RegisterMetrics.contentPadding,
                    _RegisterMetrics.contentPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const _RegisterHeadline(),
                      // Figma 头像块 `mt-[34px]`。
                      const SizedBox(height: _RegisterMetrics.avatarGap),
                      const _RegisterAvatar(),
                      _buildForm(submitting: submitting),
                      _buildActions(submitting: submitting),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 名字 / 手机号 / 密码。
  ///
  /// Figma `mx-auto mt-8 max-w-[334px] gap-5` —— 表单比页面窄，
  /// 大屏上居中且不无限拉宽。
  Widget _buildForm({required bool submitting}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: _RegisterMetrics.formGap,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _RegisterMetrics.formMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CareerlyInput(
                variant: CareerlyInputVariant.outlined,
                label: '名字',
                hint: '你的名字',
                controller: _name,
                enabled: !submitting,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.authFieldGap),
              CareerlyInput(
                variant: CareerlyInputVariant.outlined,
                label: '手机号',
                hint: '+86 138 0000 0000',
                controller: _phone,
                enabled: !submitting,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.authFieldGap),
              CareerlyInput(
                variant: CareerlyInputVariant.outlined,
                label: '密码',
                hint: 'example_1',
                controller: _password,
                enabled: !submitting,
                obscureText: !_showPassword,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                suffix: PasswordVisibilityToggle(
                  visible: _showPassword,
                  onPressed: submitting
                      ? () {}
                      : () => setState(() => _showPassword = !_showPassword),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 主按钮 + 分隔线 + 微信 / QQ。Figma `mt-8` 起。
  Widget _buildActions({required bool submitting}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          // Figma 按钮块 `mt-8`。
          padding: const EdgeInsetsDirectional.only(
            top: _RegisterMetrics.actionsGap,
          ),
          child: CareerlyButton(
            label: '创建账号',
            // ⚠️ `authPrimary`（172.01deg / 投影 0 8px 12px），
            // 不是默认的 `primary`（135deg / 0 8px 24px）—— 见枚举文档。
            variant: CareerlyButtonVariant.authPrimary,
            // 提交中禁用，避免重复建号。
            onPressed: (_canSubmit && !submitting) ? _submit : null,
          ),
        ),
        Padding(
          // Figma 分隔线 `mt-3`。
          padding: const EdgeInsetsDirectional.only(
            top: _RegisterMetrics.dividerGap,
            bottom: _RegisterMetrics.socialGap,
          ),
          child: const CareerlyLabeledDivider(
            // ⚠️ 注册页是 `Or sign up with`，登录页是 `sign in with` —— 不同。
            label: 'Or sign up with',
            // Figma `gap-[13px]`；登录页是 25 —— 故该值不给默认值。
            labelGap: _RegisterMetrics.dividerLabelGap,
          ),
        ),
        AuthSocialRow(
          onWechat: submitting
              ? null
              : () => _signUpWithOAuth(_RegisterMetrics.wechatProvider),
          onQq: submitting
              ? null
              : () => _signUpWithOAuth(_RegisterMetrics.qqProvider),
        ),
      ],
    );
  }
}

/// 标题与说明。
///
/// ⚠️ 两句都是 Figma 原值，**沿用既有的 `onboardingTitle` /
/// `onboardingSubtitle` 角色** —— 新稿的注册页与旧稿在这两句上逐位一致，
/// 故**不**新立角色（登录页的标题 / 副标题取值不同，才另外立了两个角色）。
class _RegisterHeadline extends StatelessWidget {
  const _RegisterHeadline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Figma 注册标题里带一个 📋，与文案同属一个 span 组。
        const Text('创建你的个人账号 📋', style: AppTypography.onboardingTitle),
        const SizedBox(height: _RegisterMetrics.subtitleGap),
        const SizedBox(
          // Figma：说明文案 `width: 260`（刻意不让它撑满，避免行长过宽）。
          width: _RegisterMetrics.subtitleWidth,
          child: Text(
            '只有你能看到你的个人信息，不会对外展示。',
            style: AppTypography.onboardingSubtitle,
          ),
        ),
      ],
    );
  }
}

/// 头像占位 + 右下角「编辑」徽标。
///
/// ⚠️ Figma 的头像人像是**自绘 SVG**（圆形头部 + 肩部弧线）。
/// 这里用 Material 的 [Icons.person] 近似，**未新建图标资源**。
/// 若视觉验证后认为字形差异明显，再单独补一张 SVG 资产。
/// 登记为 **待裁决 · D58**（`docs/05_progress/TODO.md` §3.1）。
///
/// ⚠️ 旧实现把一个 `bottom: 24` 的内边距画在里面充当「与下方表单的间距」，
/// 那与 Figma 的 `mt-[34px]`（**只在上方**）不是一回事 —— 已移到调用点。
class _RegisterAvatar extends StatelessWidget {
  const _RegisterAvatar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: _RegisterMetrics.avatarSize,
        height: _RegisterMetrics.avatarBoxHeight,
        child: Stack(
          children: <Widget>[
            Container(
              width: _RegisterMetrics.avatarSize,
              height: _RegisterMetrics.avatarSize,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: AppRadius.borderPill,
                boxShadow: AppShadows.onboardingAvatar,
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: _RegisterMetrics.avatarIconSize,
                  color: AppColors.onAvatarGlyph,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: _RegisterMetrics.badgeSize,
                height: _RegisterMetrics.badgeSize,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.borderPill,
                  boxShadow: AppShadows.onboardingBadge,
                ),
                child: const Center(
                  child: Icon(
                    Icons.edit_outlined,
                    size: _RegisterMetrics.badgeIconSize,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 页面内部几何（Figma 原值）。
///
/// 与 `_LoginMetrics` / `_SplashMetrics` 同理：这些数值**只在注册页出现**，
/// 不是跨页共用的间距，故留在页面私有的 metrics 里，不进 `AppSpacing`。
/// 跨页重复的三项（表单字段间距 20 / 标签间距 6 / 社交按钮间距 21）
/// 已在 Token 层，见 `AppSpacing.auth*`。
abstract final class _RegisterMetrics {
  /// Figma `px-6 pb-6 pt-6` —— 内容区三边同为 24。
  static const double contentPadding = 24;

  /// Figma 副标题 `marginTop: 8`。
  static const double subtitleGap = 8;

  /// Figma 副标题 `width: 260`。
  static const double subtitleWidth = 260;

  /// Figma 头像块 `mt-[34px]`。
  static const double avatarGap = 34;

  /// Figma 表单 `mt-8` = 32。
  static const double formGap = 32;

  /// Figma 表单 `max-w-[334px]`。
  static const double formMaxWidth = 334;

  /// Figma 按钮块 `mt-8` = 32。
  static const double actionsGap = 32;

  /// Figma 分隔线 `mt-3` = 12。
  static const double dividerGap = 12;

  /// Figma 社交按钮行 `mt-3` = 12。
  static const double socialGap = 12;

  /// Figma 分隔线 `gap-[13px]`（注册页专用值，登录页是 25）。
  static const double dividerLabelGap = 13;

  /// Figma：头像 `width: 80, height: 80`。
  static const double avatarSize = 80;

  /// Figma：头像容器 `height: 88`（给右下角徽标留 8px 溢出）。
  static const double avatarBoxHeight = 88;

  /// Figma：头像内的人像 SVG 为 `36×36`。
  static const double avatarIconSize = 36;

  /// Figma：徽标 `width: 26, height: 26`。
  static const double badgeSize = 26;

  /// Figma：徽标内的铅笔 SVG 为 `13×13`。
  static const double badgeIconSize = 13;

  /// 微信渠道标识（后端白名单取值，见 `router_auth.py`）。
  static const String wechatProvider = 'wechat';

  /// QQ 渠道标识。
  static const String qqProvider = 'qq';
}
