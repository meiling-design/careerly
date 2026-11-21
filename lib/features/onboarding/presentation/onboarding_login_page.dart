import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/onboarding_provider.dart';
import 'widgets/auth_social_row.dart';
import 'widgets/back_pill.dart';
import 'widgets/onboarding_login_ip.dart';
import 'widgets/password_visibility_toggle.dart';

/// 登录页 —— Onboarding 第 2 屏的**另一条入口**（注册 / 登录二选一）。
///
/// 真值来源：Figma `OnLogin`（2026-10-04 重新导出版 `src/App.tsx` L455-623）。
///
/// ```text
/// 背景   全局渐变（S.bg）—— 见下方「背景为什么不再铺一层」
/// 顶部   44×44 Glass 圆钮返回键（left 20 / top 12，填充 0.45）
/// 面板   top 185 → 底边，顶圆角 40，自带渐变，内部可滚动
///        └── 欢迎回来！ → 继续成长从看见自己开始
///            → 注册手机号 / 密码（含显隐切换）
///            → 记住我 · 忘记密码?
///            → 「点击登录」 → sign in with → 微信 / QQ
///            → 还没有账号? 点击注册
/// ```
///
/// ## ⚠️ 本页是 2026-10-04 新建的**独立页面**
///
/// 它**推翻**了 2026-09-21 的 **D85**（「登录 = 注册页的第二种形态，
/// 用 `?mode=login` 表达」）。新稿里 `OnLogin` 与 `OnRegister`
/// 是两个独立的屏：标题、字段集、主按钮文案、分隔线文案全都不同，
/// 连返回键形态也不同（注册页是「返回键 + 进度条」的头部，
/// 登录页是一个游离的 Glass 圆钮）。
///
/// 因此 `OnboardingAccountMode` / `_AccountModeSwitch` / `?mode=` 查询参数
/// 连同 D85 一并删除，**不保留任何向后兼容**。
///
/// ⚠️ 本页**不是一级页面** —— 它和注册页一样属于同一条一次性的
/// Onboarding 流程，不进 `AppRoutes.shellBranches`、没有底部导航、
/// 不是任何一个 Tab。新增本路由**没有**触碰 `CLAUDE.md` §0 的第二禁令。
///
/// ## 数据链路
///
/// ```text
/// 本页 → OnboardingProvider → AuthRepository → Mock | API
/// ```
///
/// 登录页**复用** [OnboardingProvider] 而不是新建 `LoginProvider`：
/// 两条链路的状态机完全相同（四态 + 错误归一化 + `Future<bool>`），
/// 新建只会得到两个同构类（`CLAUDE.md` §6.3）。理由详见该类的文档。
///
/// ## 背景为什么不再铺一层
///
/// Figma 的 `OnLogin` 把背景写成 `S.bg`，而 `S.bg` **就是**
/// [AppColors.backgroundGradient]（同一个 `128.67deg` 三段渐变，
/// 逐位一致）。`CLAUDE.md` §10.4 规定全局渐变由 `CareerlyApp` 的
/// builder **统一画一次**，页面要换背景才自己铺 ——
/// 这里不换，所以**不铺**。注册页铺是因为它的背景确实不同
/// （`142.84deg`，终点 `#FDF4FF`）。
///
/// ## 与 Figma 的三处差异（都是 Flutter 侧补齐，不是遗漏）
///
/// ```text
/// 1. SafeArea      Figma 的 390×844 机身里，状态栏是 44px 的固定兄弟节点，
///                  页面内容从它**下方**开始 —— 所以 `top: 12` / `top: 185`
///                  本来就是「安全区之内」的坐标。Android 状态栏高度因机而异，
///                  故用 SafeArea 表达同一件事，而不是硬编 44。
/// 2. 忘记密码?      Figma 的按钮**没有 onClick**（稿子里的死链）。
///                  2026-11-13 产品侧要求补齐：点击进入
///                  `/onboarding/reset-password`，后端**仅 DEV 模式**开放；
///                  正式形态由重置页如实展示 501，不自造找回行为。
/// 3. 记住我        Figma 只画了勾选框，**没有定义它改变什么**。
///                  当前令牌**总是**持久化（见 `AuthRepository` 实现对照表），
///                  因此本参数只驱动视觉，**不代表会话规则**。详见下方 [_remember]。
/// ```
class OnboardingLoginPage extends StatefulWidget {
  const OnboardingLoginPage({super.key});

  @override
  State<OnboardingLoginPage> createState() => _OnboardingLoginPageState();
}

class _OnboardingLoginPageState extends State<OnboardingLoginPage> {
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();

  /// 「记住我」的勾选状态。
  ///
  /// ⚠️ **它当前不改变任何行为** —— `ApiClient.setSession` 一律写入
  /// `SecureTokenStore`，没有「不勾选就只放内存」的开关。
  /// 本轮**不自行发明**这条会话规则（原样登记为待裁决项），
  /// 但也不假装它已经生效：这里只持有 UI 状态，注释说清它是什么。
  bool _remember = false;

  /// 密码是否明文可见。
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    // 两个字段任一变化都要重算主按钮的可用态。
    for (final TextEditingController controller in <TextEditingController>[
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
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  /// 主按钮是否可用。
  ///
  /// ⚠️ Flutter 侧规则（Figma 未定义校验，沿用 **D57** 的「最小非空」思路）：
  /// **手机号非空 且 密码 >= 6 位**。
  ///
  /// 密码下界取自 [AppConstants.passwordMinLength]，它是**后端**
  /// `passwords.MIN_PASSWORD_LENGTH` 的镜像 —— 这里只是提前拦一次，
  /// 真正的判定仍在服务端（短密码走 401 `INVALID_CREDENTIALS`）。
  bool get _canSubmit =>
      _phone.text.trim().isNotEmpty &&
      _password.text.length >= AppConstants.passwordMinLength;

  /// 提交手机号 + 密码登录。
  ///
  /// ⚠️ 密码**不 trim** —— 首尾空格是密码的一部分（与注册页同一处置）。
  Future<void> _submit() async {
    final OnboardingProvider provider = context.read<OnboardingProvider>();

    final bool ok = await provider.login(
      phone: _phone.text,
      password: _password.text,
    );

    if (!mounted) return;

    if (!ok) {
      _showFailure(provider, fallback: '登录失败，请重试');
      return;
    }

    // 老用户已有职业基线，登录后**直达首页**，不再走一遍建立基线
    // 的流程（D85 裁定的去向；该裁定在本次改版中被保留，作废的
    // 只是它的「登录 = 注册页第二种形态」那一半）。
    context.go(AppRoutes.home);
  }

  /// 第三方登录（微信 / QQ）。
  ///
  /// 按钮**真实调用**后端 —— 未配置凭据时后端返回 501
  /// （`OAUTH_NOT_CONFIGURED`），这里把它的原文如实展示。
  /// 这正是产品侧要的「可配置契约」的可见行为：
  /// **不静默失败，也不假装成功**（见 `AuthRepository.signInWithOAuth`）。
  Future<void> _signInWithOAuth(String provider) async {
    final OnboardingProvider state = context.read<OnboardingProvider>();

    final bool ok = await state.signInWithOAuth(provider: provider);

    if (!mounted) return;

    if (!ok) {
      _showFailure(state, fallback: '第三方登录暂不可用');
      return;
    }

    // ⚠️ 当前**不可达** —— 后端一律 501，成功分支要到真实换码流程
    // （Roadmap P5）落地后才会被走到。去向与手机号登录对齐（首页），
    // 因为「第三方登录」在语义上也是**老用户登录**。
    context.go(AppRoutes.home);
  }

  /// 失败提示 —— 用既有 [CareerlyToast]（PRD §15：失败要可见原因）。
  void _showFailure(OnboardingProvider provider, {required String fallback}) {
    CareerlyToast.show(
      context,
      message: provider.error?.message ?? fallback,
      icon: Icons.error_outline,
      // Onboarding 没有底部导航，提示贴底即可。
      bottomOffset: AppSpacing.xxl,
    );
  }

  /// 「忘记密码?」→ 重置密码页（2026-11-13 产品侧要求补齐）。
  ///
  /// ⚠️ 后端当前只在 `AUTH_MODE=dev` 开放重置；正式形态返回 501，
  /// 由重置页如实展示。这里**不**判断模式，也不假装一定能重置 ——
  /// 能力边界属于后端，客户端只负责把错误展示出来。
  void _onForgotPassword() {
    context.push(AppRoutes.onboardingResetPassword);
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingProvider provider = context.watch<OnboardingProvider>();
    final bool submitting = provider.isSubmitting;

    // ⚠️ 在 `SafeArea` **之外**读系统底部内边距 —— `SafeArea` 会把
    // MediaQuery 的 padding 抹掉，里面再读就是 0。
    // 面板一直铺到屏幕物理底边（Figma 的 `bottom-0`），
    // 因此滚动内容要自己给系统导航条让出位置。
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      // 见类文档第 1 条：Figma 的 390×844 机身里状态栏是内容区之外的
      // 44px 固定兄弟节点，故 `top` 坐标本就在安全区之内。
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              top: _LoginMetrics.panelTop,
              bottom: 0,
              child: _LoginPanel(
                bottomInset: bottomInset,
                phone: _phone,
                password: _password,
                enabled: !submitting,
                showPassword: _showPassword,
                onTogglePassword: () =>
                    setState(() => _showPassword = !_showPassword),
                remember: _remember,
                // 提交中不允许改勾选：请求在飞时改状态会让
                // 「正在提交」这句话指向另一个动作。
                onRememberChanged: submitting
                    ? null
                    : (bool value) => setState(() => _remember = value),
                onForgotPassword: _onForgotPassword,
                onSubmit: (_canSubmit && !submitting) ? _submit : null,
                onWechat: submitting
                    ? null
                    : () => _signInWithOAuth(_LoginMetrics.wechatProvider),
                onQq: submitting
                    ? null
                    : () => _signInWithOAuth(_LoginMetrics.qqProvider),
                onGoToRegister: submitting
                    ? null
                    : () => context.go(AppRoutes.onboardingRegister),
              ),
            ),
            Positioned(
              top: 0,
              right: MediaQuery.sizeOf(context).height <= 700 ? 16 : 18,
              child: OnboardingLoginIp(
                width: math.min(
                  MediaQuery.sizeOf(context).width *
                      (MediaQuery.sizeOf(context).height <= 700 ? 0.52 : 0.58),
                  MediaQuery.sizeOf(context).height <= 700 ? 184 : 224,
                ),
              ),
            ),
            Positioned(
              left: _LoginMetrics.backInsetLeft,
              top: _LoginMetrics.backInsetTop,
              child: BackPill(
                fill: AppColors.authGlassFill,
                // ⚠️ 已知差异（待产品侧裁决）：顶部返回固定回开屏，
                // 而深链直达时**系统 Back** 在栈底只退后台（§5.6）。
                // 之所以没有统一成 `careerlyBack`：深链场景下栈底
                // 没有可 pop 的页面，会让顶部按钮变成静默死键
                // （`phase4_onboarding_test` 钉的正是这一行为）。
                onTap: () => context.go(AppRoutes.onboardingSplash),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `top: 185` 起、顶圆角 40、自带渐变的底部面板。
///
/// ⚠️ **不是 `CareerlyBottomSheet`** —— 那个是**模态** sheet
/// （静态 `show()`，带遮罩与 dismiss 语义）。这里是页面内的**常驻**面板，
/// 不遮挡任何东西、也没有「关闭」的概念，只是登录页的一块固定区域。
/// 两者只是长得像，行为完全不同（`CLAUDE.md` §8.4：行为不同才拆，
/// 也意味着行为不同**不能合并**成同一个组件）。
class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.bottomInset,
    required this.phone,
    required this.password,
    required this.enabled,
    required this.showPassword,
    required this.onTogglePassword,
    required this.remember,
    required this.onRememberChanged,
    required this.onForgotPassword,
    required this.onSubmit,
    required this.onWechat,
    required this.onQq,
    required this.onGoToRegister,
  });

  /// 系统底部内边距（键盘未弹出时的导航条高度）。
  final double bottomInset;

  final TextEditingController phone;
  final TextEditingController password;
  final bool enabled;
  final bool showPassword;
  final VoidCallback onTogglePassword;
  final bool remember;
  final ValueChanged<bool>? onRememberChanged;
  final VoidCallback onForgotPassword;
  final VoidCallback? onSubmit;
  final VoidCallback? onWechat;
  final VoidCallback? onQq;
  final VoidCallback? onGoToRegister;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.borderAuthPanel,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.authLoginPanelGradient,
        ),
        child: SingleChildScrollView(
          // Figma `px-4 py-[31px]`；底部再加系统内边距，避免内容压在导航条下。
          padding: EdgeInsetsDirectional.fromSTEB(
            _LoginMetrics.panelPaddingHorizontal,
            _LoginMetrics.panelPaddingVertical,
            _LoginMetrics.panelPaddingHorizontal,
            _LoginMetrics.panelPaddingVertical + bottomInset,
          ),
          child: Center(
            // Figma `max-w-[342px]` —— 大屏上不让表单无限拉宽。
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _LoginMetrics.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    '欢迎回来！',
                    textAlign: TextAlign.center,
                    style: AppTypography.authPageTitle,
                  ),
                  // Figma `marginTop: 20`。
                  const SizedBox(height: _LoginMetrics.subtitleGap),
                  const Text(
                    '继续成长从看见自己开始',
                    textAlign: TextAlign.center,
                    style: AppTypography.authPageSubtitle,
                  ),
                  _buildForm(),
                  _buildRememberRow(),
                  _buildPrimaryButton(),
                  _buildDivider(),
                  AuthSocialRow(onWechat: onWechat, onQq: onQq),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 手机号 + 密码。
  ///
  /// ⚠️ 手机号的标签在 Figma 里写的是 **「注册手机号」** ——
  /// 登录页用「注册」两个字确实别扭，但这是设计稿原样，
  /// **不顺手改成「手机号」**（那是改产品文案，属 §0 第一禁令）。
  /// 已登记为待产品侧确认。
  Widget _buildForm() {
    return Padding(
      // Figma `mt-[34px] … px-1`。
      padding: const EdgeInsetsDirectional.fromSTEB(
        _LoginMetrics.formPaddingHorizontal,
        _LoginMetrics.formGap,
        _LoginMetrics.formPaddingHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CareerlyInput(
            variant: CareerlyInputVariant.outlined,
            label: '注册手机号',
            hint: '+86 138 0000 0000',
            controller: phone,
            enabled: enabled,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.authFieldGap),
          CareerlyInput(
            variant: CareerlyInputVariant.outlined,
            label: '密码',
            hint: 'example_1',
            controller: password,
            enabled: enabled,
            obscureText: !showPassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            suffix: PasswordVisibilityToggle(
              visible: showPassword,
              onPressed: enabled ? onTogglePassword : () {},
            ),
          ),
        ],
      ),
    );
  }

  /// 「记住我」+「忘记密码?」。
  ///
  /// ⚠️ Figma 这一行是 `w-[calc(100%-17px)]` 且父级 `items-center`，
  /// 即整行比表单窄 17px 并**居中** —— 左右各让出 8.5px。
  /// 这里如实照做（不是笔误，也不是四舍五入成 8 或 9）。
  Widget _buildRememberRow() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        _LoginMetrics.rememberRowInset,
        _LoginMetrics.rememberRowGap,
        _LoginMetrics.rememberRowInset,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CareerlyCheckbox(
            value: remember,
            label: '记住我',
            onChanged: onRememberChanged,
          ),
          CareerlyTextLink(
            label: '忘记密码?',
            style: AppTypography.authMeta,
            // Figma 的按钮没有 onClick；2026-11-13 起接到重置页
            // （DEV-only，见 `_onForgotPassword`）。
            onPressed: onForgotPassword,
            semanticsLabel: '忘记密码',
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Padding(
      // Figma `mt-5`。
      padding: const EdgeInsetsDirectional.only(
        top: _LoginMetrics.primaryButtonGap,
      ),
      child: CareerlyButton(
        label: '点击登录',
        // ⚠️ 这里是 `authPrimary`（172.01deg / 投影 0 8px 12px），
        // **不是**默认的 `primary`（135deg / 0 8px 24px）——
        // 见枚举文档：三处 auth 主按钮与 `S.primary` 是两套刻意的取值。
        variant: CareerlyButtonVariant.authPrimary,
        onPressed: onSubmit,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      // Figma `mt-2.5`（10）与 `w-[calc(100%-9px)]` 居中 → 左右各 4.5。
      padding: const EdgeInsetsDirectional.fromSTEB(
        _LoginMetrics.dividerInset,
        _LoginMetrics.dividerGap,
        _LoginMetrics.dividerInset,
        _LoginMetrics.socialGap,
      ),
      child: CareerlyLabeledDivider(
        // ⚠️ Figma 原文就是全小写、且**没有** `Or`（注册页是
        // `Or sign up with`）。不要顺手补齐。
        label: 'sign in with',
        // Figma `gap-[25px]`；注册页是 13 —— 故该值不给默认值。
        labelGap: _LoginMetrics.dividerLabelGap,
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      // Figma `marginTop: 20`。
      padding: const EdgeInsetsDirectional.only(top: _LoginMetrics.footerGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Figma 这里有一个尾随空格（`还没有账号? `）。
          const Text('还没有账号? ', style: AppTypography.authFooter),
          CareerlyTextLink(
            label: '点击注册',
            style: AppTypography.authFooterLink,
            onPressed: onGoToRegister,
            // 「点击注册」在开屏页底部也有一处，读屏器需要能区分。
            semanticsLabel: '还没有账号，点击注册',
          ),
        ],
      ),
    );
  }
}

/// 页面内部几何（Figma 原值）。
///
/// 与 `_SplashMetrics` / `_RegisterMetrics` 同理：这些数值**只在登录页出现**，
/// 不是跨页共用的间距，故按本仓库既定做法留在页面私有的 metrics 里，
/// 不进 `AppSpacing`。跨页重复的三项（表单字段间距 20 / 标签间距 6 /
/// 社交按钮间距 21）已在 Token 层，见 `AppSpacing.auth*`。
abstract final class _LoginMetrics {
  /// Figma `left-5` = 20（返回键左内缩）。
  static const double backInsetLeft = 20;

  /// Figma `top-3` = 12（返回键上内缩）。见类文档第 1 条：
  /// 它是**安全区之内**的坐标，故与 `SafeArea` 叠加使用。
  static const double backInsetTop = 12;

  /// Figma `top: 185`（面板上沿）。
  static const double panelTop = 185;

  /// Figma `px-4` = 16（面板内边距）。
  static const double panelPaddingHorizontal = 16;

  /// Figma `py-[31px]` = 31（面板内边距）。
  static const double panelPaddingVertical = 31;

  /// Figma `max-w-[342px]`（内容列最大宽度）。
  static const double contentMaxWidth = 342;

  /// Figma 副标题 `marginTop: 20`。
  static const double subtitleGap = 20;

  /// Figma 表单块 `mt-[34px]`。
  static const double formGap = 34;

  /// Figma 表单块 `px-1` = 4。
  static const double formPaddingHorizontal = 4;

  /// Figma 记住我行 `mt-4` = 16。
  static const double rememberRowGap = 16;

  /// Figma 记住我行 `w-[calc(100%-17px)]` + 父级 `items-center`
  /// → 左右各让出 **8.5**。
  ///
  /// ⚠️ 半像素是 `calc` 居中的必然结果，**不要取整** ——
  /// 取 8 或 9 都会让这一行相对表单偏 0.5px。
  static const double rememberRowInset = 8.5;

  /// Figma 主按钮 `mt-5` = 20。
  static const double primaryButtonGap = 20;

  /// Figma 分隔线 `mt-2.5` = 10。
  static const double dividerGap = 10;

  /// Figma 分隔线 `w-[calc(100%-9px)]` → 左右各让出 **4.5**（同 [rememberRowInset]）。
  static const double dividerInset = 4.5;

  /// Figma 分隔线 `gap-[25px]`（登录页专用值，注册页是 13）。
  static const double dividerLabelGap = 25;

  /// Figma 社交按钮行 `mt-2.5` = 10。
  static const double socialGap = 10;

  /// Figma 底部文案 `marginTop: 20`。
  static const double footerGap = 20;

  /// 微信渠道标识（后端白名单取值，见 `router_auth.py`）。
  static const String wechatProvider = 'wechat';

  /// QQ 渠道标识。
  static const String qqProvider = 'qq';
}
