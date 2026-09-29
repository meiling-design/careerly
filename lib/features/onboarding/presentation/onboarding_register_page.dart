import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/onboarding_provider.dart';
import 'widgets/onboarding_progress_header.dart';

/// 账号页的两种**形态**。
///
/// ⚠️ 形态**不是**路由 —— 两者共用 `/onboarding/register` 一条路径、
/// 同一个页面类（产品侧裁决 **D85**，2026-09-21）。
/// 「新增页面 / 新增路由」属 `CLAUDE.md` §0 第二禁令，本页**没有**触发它。
enum OnboardingAccountMode {
  /// 注册 —— Figma 里唯一的形态（`OnRegister`，`src/App.tsx` L460-560）。
  register,

  /// 登录 —— **无 Figma 依据**（设计稿里登录没有自己的屏）。
  ///
  /// 字段集由 D85 裁决：**只有手机号**，不设密码 / 验证码。
  login;

  /// 解析路由上的 `?mode=` 取值。
  ///
  /// ```text
  /// 'login'      → login
  /// 其他 / 缺省   → register（Figma 的默认形态，也是历史行为）
  /// ```
  ///
  /// ⚠️ 未知值**不报错**而是落到 [register]：地址栏是用户可以改的，
  /// 为一个拼错的 query 参数弹「页面不存在」比按默认形态打开更糟。
  static OnboardingAccountMode fromQuery(String? raw) {
    return raw == AppRoutes.accountModeLogin
        ? OnboardingAccountMode.login
        : OnboardingAccountMode.register;
  }
}

/// 账号页（注册 / 登录）—— Onboarding 第 2 屏。
///
/// 真值来源：Figma `OnRegister`（`src/App.tsx` L460-560），**注册形态**。
///
/// ```text
/// 背景   linear-gradient(143deg, #EEF2FF → #FDF4FF)
/// 顶部   OnboardingProgressHeader(step: 1, total: 4)
/// 内容   形态切换 → 标题 → 说明 → 头像 → 姓名 / 手机号 / 邮箱（选填）
/// 底部   「继续」(主按钮) / 「跳过，稍后完善」(文字链)
/// ```
///
/// ## 两种形态（D85，2026-09-21 产品侧裁决）
///
/// ```text
///               注册形态（= Figma）        登录形态（Flutter 侧新增）
/// 标题          「创建你的个人账号 📋」      「登录你的账号」
/// 头像占位      有                          无 —— 它是「换头像」的暗示，登录场景无意义
/// 字段          姓名 / 手机号 / 邮箱（选填）  手机号
/// 主按钮        「继续」                     「登录」
/// 次按钮        「跳过，稍后完善」           无 —— 登录没有「稍后完善」可跳过
/// 校验          姓名非空 且 手机号非空        手机号非空（沿用 D57 的「非空即可」最小规则）
/// 成功后去向    提交简历（继续 Onboarding）    **首页 /home**（老用户已有职业基线）
/// ```
///
/// ⚠️ **上表的登录形态一列是 Flutter 侧补齐，不是设计稿。**
/// Figma 里没有登录屏，因此这一列的**每一格都没有出处** ——
/// 文案、头像的去留、次按钮的去留、切换控件的形态与间距。
/// 已登记 **待裁决 · D86**（`docs/05_progress/TODO.md` §3.1），
/// **验收时不得盖章为视觉已定稿**。
///
/// ## 数据链路（D52：纯 Mock）
///
/// ```text
/// 本页 → OnboardingProvider → AuthRepository → MockAuthRepository
/// ```
///
/// **不接真实鉴权、不写本地存储、不保存会话。**
///
/// ## ⚠️ Flutter 侧补齐的既有两处（Figma 未定义）
///
/// 1. **「继续」的 Disabled 规则** —— Figma 未定义校验。
///    当前取「姓名与手机号均非空」。这是**最小**规则，
///    手机号格式、验证码等均**未**自行发明。
///    登记为 **待裁决 · D57**（`docs/05_progress/TODO.md` §3.1）。
/// 2. **失败后的表现** —— 用既有 [CareerlyToast] 提示 + 按钮回到可用态
///    （PRD §15 要求分析类操作失败可见原因并重试）。
class OnboardingRegisterPage extends StatefulWidget {
  const OnboardingRegisterPage({
    super.key,
    this.initialMode = OnboardingAccountMode.register,
  });

  /// 进入本页时的形态，来自路由的 `?mode=`（见 [OnboardingAccountMode]）。
  ///
  /// ⚠️ 它只决定**初始值**：页内的切换控件改的是本页 State 的 `_mode`，
  /// **不回写路由**。原因是 `go` 到「同路径、不同 query」会重建页面，
  /// 把用户正在输入的内容丢掉。代价是地址栏的模式可能与页面不一致 ——
  /// 这是实现取舍，已在交付报告中声明，不属产品规则。
  final OnboardingAccountMode initialMode;

  @override
  State<OnboardingRegisterPage> createState() => _OnboardingRegisterPageState();
}

class _OnboardingRegisterPageState extends State<OnboardingRegisterPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();

  /// 当前形态。切换只影响本页渲染，不动路由。
  late OnboardingAccountMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    // 三个字段任一变化都要重算主按钮的可用态。
    // ⚠️ 登录形态下只有手机号参与判定，但另外两个 controller 仍要挂监听 ——
    // 切回注册形态时它们的内容是**保留**的（不因换形态被清空）。
    for (final TextEditingController controller in <TextEditingController>[
      _name,
      _phone,
      _email,
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
    _email.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  /// 当前是否为登录形态。
  bool get _isLogin => _mode == OnboardingAccountMode.login;

  /// 主按钮是否可用。
  ///
  /// ⚠️ Flutter 侧规则（Figma 未定义，D57）：
  /// 注册 = 姓名与手机号**非空**；登录 = 手机号**非空**。
  bool get _canSubmit => _isLogin
      ? _phone.text.trim().isNotEmpty
      : _name.text.trim().isNotEmpty && _phone.text.trim().isNotEmpty;

  /// 切换注册 / 登录形态。
  ///
  /// 表单内容**不清空** —— 用户填到一半发现走错形态时，切回去不该重填。
  /// 但会清掉**提交残状态**：上一形态的失败原因（如「注册失败」）
  /// 不该继续挂在另一形态的表单上。
  void _switchMode(OnboardingAccountMode next) {
    if (next == _mode) return;
    setState(() => _mode = next);
    context.read<OnboardingProvider>().reset();
  }

  Future<void> _submit() async {
    final OnboardingProvider provider = context.read<OnboardingProvider>();

    final bool ok = _isLogin
        ? await provider.login(phone: _phone.text)
        : await provider.submit(
            name: _name.text,
            phone: _phone.text,
            email: _email.text,
          );

    if (!mounted) return;

    if (!ok) {
      CareerlyToast.show(
        context,
        message: provider.error?.message ?? (_isLogin ? '登录失败，请重试' : '注册失败，请重试'),
        icon: Icons.error_outline,
        // Onboarding 没有底部导航，提示贴底即可。
        bottomOffset: AppSpacing.xxl,
      );
      return;
    }

    _goAfterSubmit();
  }

  /// 提交成功后的去向 —— **两种形态不同**（D85）。
  ///
  /// ```text
  /// 登录   →  首页 /home    老用户已有职业基线，不再走一遍建立基线的流程
  /// 注册   →  提交简历       新用户从零建立职业基线
  /// ```
  ///
  /// ⚠️ **登录直达首页是产品侧裁决**（2026-09-21，D85），
  /// 不是 Flutter 侧自行推断的「老用户跳过引导」——
  /// 那种推断需要会话持久化（**D54 未裁决**），本轮无法表达。
  /// 这里只是执行给定的去向。
  ///
  /// ⚠️ 注册侧的 **`on-welcome` 被跳过是有原因的，不是链路变更**：
  /// 六步链路是「开屏 → 注册/登录 → **on-welcome** → 提交简历 → 解析 → 确认」，
  /// 而 `on-welcome` 的真实语义是**用户身份选择**（产品侧裁决 **D61**），
  /// 其规格**尚未给出**，因此该屏**未进入实现队列**。
  ///
  /// 在它缺位的情况下，注册完成后**没有该屏可去**，故直接指向「提交简历」。
  /// 待规格落地后，把这一行改回 `AppRoutes.onboardingWelcome` 即可
  /// —— 改动为一行，见 `TODO.md` §3.2 · D61 的「接线缺口」说明。
  void _goAfterSubmit() {
    context.go(_isLogin ? AppRoutes.home : AppRoutes.onboardingResume);
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingProvider provider = context.watch<OnboardingProvider>();
    final bool submitting = provider.isSubmitting;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.onboardingGradient),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              OnboardingProgressHeader(
                step: 1,
                total: 4,
                onBack: () => context.go(AppRoutes.onboardingSplash),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _AccountModeSwitch(
                        mode: _mode,
                        // 提交中禁止切形态：请求已经在飞，换形态会让
                        // 「正在提交」这句话指向另一个动作。
                        onChanged: submitting ? null : _switchMode,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _AccountHeadline(mode: _mode),
                      // 头像占位只在注册形态出现（见类文档 D86 一栏）。
                      if (!_isLogin) const _RegisterAvatar(),
                      _AccountForm(
                        mode: _mode,
                        name: _name,
                        phone: _phone,
                        email: _email,
                        enabled: !submitting,
                      ),
                    ],
                  ),
                ),
              ),
              _AccountActions(
                mode: _mode,
                // 提交中禁用，避免重复扣减 / 重复提交。
                onSubmit: (_canSubmit && !submitting) ? _submit : null,
                onSkip: submitting ? null : _goAfterSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 注册 / 登录形态切换。
///
/// ## ⚠️ 这个控件的视觉**没有设计依据**
///
/// Figma 里不存在登录屏，也就没有「形态切换」这个控件。
/// 这里**复用既有组件**而不是新造一个分段控件：
/// [CareerlyChip] 的 `dark` 色调在组件文档里就写着
/// 「选中态 Chip / Tab」—— 选中 = `dark`，未选中 = `neutral`，
/// 因此不需要任何新组件、新 Token。
///
/// 间距 **16（`AppSpacing.md`）** 是补齐值，已并入 **待裁决 · D86**。
class _AccountModeSwitch extends StatelessWidget {
  const _AccountModeSwitch({required this.mode, required this.onChanged});

  /// 当前形态。
  final OnboardingAccountMode mode;

  /// 切换回调。为 `null` 时两枚 Chip 均不可点（提交中）。
  final ValueChanged<OnboardingAccountMode>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _tab(OnboardingAccountMode.register, '注册'),
        const SizedBox(width: AppSpacing.xs),
        _tab(OnboardingAccountMode.login, '登录'),
      ],
    );
  }

  Widget _tab(OnboardingAccountMode value, String label) {
    final bool selected = value == mode;

    return Semantics(
      // 让「当前是哪种形态」在语义树里可读，也是验收 / 测试的抓手。
      selected: selected,
      child: CareerlyChip(
        label: label,
        size: CareerlyChipSize.medium,
        tone: selected ? CareerlyChipTone.dark : CareerlyChipTone.neutral,
        onTap: onChanged == null ? null : () => onChanged!(value),
      ),
    );
  }
}

/// 标题与说明。
///
/// ⚠️ 登录形态的两句文案**无设计依据**（Figma 无登录屏）——
/// 标题按注册标题的句式改写，说明句**原样复用**注册形态的隐私说明
/// （复用既有文案优于新造一句）。
/// 两句都属 **待裁决 · D86**，产品侧给出正式文案后替换。
class _AccountHeadline extends StatelessWidget {
  const _AccountHeadline({required this.mode});

  final OnboardingAccountMode mode;

  @override
  Widget build(BuildContext context) {
    final bool isLogin = mode == OnboardingAccountMode.login;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Figma 注册标题里带一个 📋，与文案同属一个 span 组。
        Text(
          isLogin ? '登录你的账号' : '创建你的个人账号 📋',
          style: AppTypography.onboardingTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        const SizedBox(
          // Figma：说明文案 `width: 260`（刻意不让它撑满，避免行长过宽）。
          width: 260,
          child: Text(
            '只有你能看到你的个人信息，不会对外展示。',
            style: AppTypography.onboardingSubtitle,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
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
/// ⚠️ 只在注册形态渲染 —— 它暗示「设置你的头像」，登录形态下不成立。
/// 这条去留属 **待裁决 · D86**。
class _RegisterAvatar extends StatelessWidget {
  const _RegisterAvatar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
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
      ),
    );
  }
}

/// 表单字段。注册形态三个，登录形态一个（手机号，与注册的同一套写法）。
///
/// ⚠️ **未复刻 Figma 的标签配色差异**：设计稿里「姓名」的标签是 `#727272`，
/// 而「手机号」「邮箱（选填）」被内联覆盖成 `#6B7280`。
/// 三个字段同为表单标签却用两种灰，更像原型里的手写残留而非规则；
/// 因此这里统一走 [AppTypography.inputLabel]（`#727272`），
/// 该差异已登记 **待裁决 · D56**（`docs/05_progress/TODO.md` §3.1）。
///
/// ⚠️ 登录形态下「姓名 / 邮箱」两个 controller **不销毁、不隐藏为字段** ——
/// 它们只在注册形态参与渲染，内容在切换过程中保留（见 `_switchMode`）。
class _AccountForm extends StatelessWidget {
  const _AccountForm({
    required this.mode,
    required this.name,
    required this.phone,
    required this.email,
    required this.enabled,
  });

  final OnboardingAccountMode mode;
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController email;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isLogin = mode == OnboardingAccountMode.login;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!isLogin) ...<Widget>[
          CareerlyInput(
            label: '姓名',
            hint: '你的名字',
            controller: name,
            enabled: enabled,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.blockGap),
        ],
        CareerlyInput(
          label: '手机号',
          hint: '+86 138 0000 0000',
          controller: phone,
          enabled: enabled,
          keyboardType: TextInputType.phone,
          textInputAction: isLogin ? TextInputAction.done : TextInputAction.next,
        ),
        if (!isLogin) ...<Widget>[
          const SizedBox(height: AppSpacing.blockGap),
          CareerlyInput(
            label: '邮箱（选填）',
            hint: 'your@email.com',
            controller: email,
            enabled: enabled,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),
        ],
      ],
    );
  }
}

/// 底部的主按钮与次按钮。
///
/// ```text
/// 注册   「继续」 + 「跳过，稍后完善」
/// 登录   「登录」  —— 次按钮不渲染（登录没有「稍后完善」可跳过，D86）
/// ```
class _AccountActions extends StatelessWidget {
  const _AccountActions({
    required this.mode,
    required this.onSubmit,
    required this.onSkip,
  });

  final OnboardingAccountMode mode;
  final VoidCallback? onSubmit;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final bool isLogin = mode == OnboardingAccountMode.login;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xxs,
      ),
      child: Column(
        children: <Widget>[
          CareerlyButton(
            label: isLogin ? '登录' : '继续',
            onPressed: onSubmit,
          ),
          if (!isLogin) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            _SkipButton(onTap: onSkip),
          ],
        ],
      ),
    );
  }
}

/// 「跳过，稍后完善」—— Figma 里是一个 24px 高的纯文字链，不是按钮组件。
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: _RegisterMetrics.skipHeight,
          child: Center(
            child: Text(
              '跳过，稍后完善',
              style: AppTypography.onSurfaceVariant(
                AppTypography.bodySmall,
                enabled ? AppColors.textSecondary : AppColors.textDisabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 页面内部几何（Figma 原值，未进 Token 的理由见各类文档）。
abstract final class _RegisterMetrics {
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

  /// Figma：「跳过，稍后完善」按钮 `height: 24`。
  static const double skipHeight = 24;
}
