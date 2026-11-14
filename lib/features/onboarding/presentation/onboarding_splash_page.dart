import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';

/// 开屏页 —— Onboarding 第 1 屏。
///
/// 真值来源：Figma `OnSplash`（2026-10-04 重新导出版 `src/App.tsx` L392-452）。
///
/// ```text
/// 背景   linear-gradient(111.07deg, #DCE9FB → #E5DCFA → #FBE9F1)
/// 内容   141×141 品牌渐变球 → 「Careerly」渐变文字
///        → 「看见能力 · 跨越 Gap」→「记录成长」→ 说明文案
/// 底部   一个渐变主按钮「点击注册」(bottom 117)
///        + 一行文字「已经有账户了? 点击登录」(bottom 52)
/// ```
///
/// ## ⚠️ 底部从「两个按钮」改成了「一个按钮 + 一行文字」
///
/// ```text
/// 旧稿   主按钮「点击登录」+ 白底按钮「点击注册」  ← 两个等权入口
/// 新稿   渐变主按钮「点击注册」+ 文字链「点击登录」 ← 注册是主线，登录是退路
/// ```
///
/// 这不只是视觉调整 —— 它把两个入口的**权重**分开了，与新版
/// 注册页 / 登录页的字段集（注册要三个字段、登录只要两个）是一致的。
///
/// ## 两个入口的去向（2026-10-04 重新裁决）
///
/// ```text
/// 「点击注册」 →  /onboarding/register   注册页
/// 「点击登录」 →  /onboarding/login      登录页 —— **独立页面**
/// ```
///
/// ⚠️ 这**推翻了 2026-09-21 的 D85**（「登录 = 注册页的 `?mode=login` 形态」）。
/// 旧实现里「点击登录」指向 `AppRoutes.onboardingRegisterLogin`
/// （同一条路由 + 查询参数）—— 该常量已随 D85 一并删除。
///
/// ⚠️ 一处**保留**的 Figma 事实：Figma 里 `OnSplash` 的两个入口 onClick
/// 分别是 `go('on-register')` 与 `go('on-login')`（L438 / L446）——
/// 也就是说，**新稿的 Figma 自己就承认登录是一块独立的屏**。
/// 这与 Flutter 侧新增 `/onboarding/login` 路由是同一件事。
///
/// ## ⚠️ 未做的部分
///
/// Figma 的开屏**不渲染**它那个自绘的 iOS 状态栏
/// （`App.tsx` L5540：`hideStatusBar = screen === 'on-splash'`），
/// 因此本页顶部在 Flutter 侧只由 `SafeArea` 让位给系统状态栏。
/// 状态栏样式（浅色 / 深色内容）的全局策略归 **K13**（`TODO.md` §2.2），
/// **本批未实现** —— 它牵涉全局的 `SystemChrome` / `AnnotatedRegion`，
/// 不是开屏一页的事。
class OnboardingSplashPage extends StatefulWidget {
  const OnboardingSplashPage({super.key});

  @override
  State<OnboardingSplashPage> createState() => _OnboardingSplashPageState();
}

class _OnboardingSplashPageState extends State<OnboardingSplashPage>
    with TickerProviderStateMixin {
  /// Figma `careerly-splash--full` 的总时长（最后一项在 1.92s + 380ms 结束）。
  static const Duration _fullIntroDuration = Duration(milliseconds: 2300);

  /// Figma `careerly-splash--repeat`：只有一次很短的进场。
  static const Duration _repeatIntroDuration = Duration(milliseconds: 420);

  /// 同一次 App 进程内只播完整版一次。
  ///
  /// Figma 用 `sessionStorage['careerly-splash-seen']` 做同一件事：
  /// 第二次进入开屏时不再等品牌字标画完（`careerly-splash--repeat`）。
  /// Flutter 侧用静态标记表达，退出 App 后自然重置。
  static bool _introPlayed = false;

  late final bool _fullIntro = !_introPlayed;
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: _fullIntro ? _fullIntroDuration : _repeatIntroDuration,
  );
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  Timer? _breathTimer;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _introPlayed = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _reduceMotion) return;
      _intro.forward();
      // Figma：球体入场 520ms + 120ms 延迟后，再等 810ms 开始呼吸投影。
      _breathTimer = Timer(Duration(milliseconds: _fullIntro ? 1450 : 500), () {
        if (mounted) _breath.repeat(reverse: true);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void dispose() {
    _breathTimer?.cancel();
    _intro.dispose();
    _breath.dispose();
    super.dispose();
  }

  /// 把「绝对时间轴」换算成当前进度。
  ///
  /// 时间点直接来自 Figma `index.css` 的 `careerly-splash--full`：
  ///
  /// ```text
  /// 120ms  球体 scale-in 520ms
  /// 430ms  字标从左到右显现 880ms
  /// 1140ms Careerly 文案
  /// 1380ms 标语
  /// 1580ms 说明文案
  /// 1780ms 主按钮
  /// 1920ms 登录文字链
  /// ```
  ///
  /// `repeat` 模式与「减少动态效果」都直接返回 1（立即呈现）。
  double _phase(double beginMs, double durationMs) {
    if (!_fullIntro || _reduceMotion) return 1;
    final double total = _fullIntroDuration.inMilliseconds.toDouble();
    final double begin = (beginMs / total).clamp(0.0, 1.0);
    final double end = ((beginMs + durationMs) / total).clamp(0.0, 1.0);
    return Interval(
      begin,
      end,
      curve: Curves.easeOutCubic,
    ).transform(_intro.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Careerly 全页面共用透明 Scaffold —— 但 Onboarding 有自己的页面背景，
      // 因此这里铺一层不透明的开屏渐变，盖住 `CareerlyApp` 绘制的全局渐变。
      // （依据 `CLAUDE.md` §10.4：全局渐变只在 root builder 画一次，
      //   页面要换背景就自己铺一层，不要改 root。）
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          // ⚠️ 底部两个元素改用**贴底绝对定位**（Figma 的 `bottom: 117` /
          // `bottom: 52`），而不是旧的 `Column` + `Expanded`。
          // 两者在**同一台**设备上视觉接近，但在矮屏上差异明显：
          // 旧写法会让按钮跟着内容一起上浮，新写法让它始终贴着底部。
          //
          // ⚠️ Figma 的 `bottom` 从**机身底边**量起（它的 iPhone 机身
          // 自带 34px home indicator 区），这里的 `bottom` 从
          // **SafeArea 底边**量起 —— Android 的导航条高度因机而异，
          // 用 SafeArea 表达「让开系统占位」比硬编 34 更接近意图。
          child: AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[_intro, _breath]),
            builder: (BuildContext context, Widget? _) {
              final double surfaceOpacity = _reduceMotion
                  ? 1
                  : _fullIntro
                  ? _phase(0, 420)
                  : Curves.easeOut.transform(_intro.value);
              final _SplashMotion motion = _SplashMotion(
                orbScale: 0.88 + 0.12 * _phase(120, 520),
                orbOpacity: _phase(120, 300),
                orbShadow: _orbShadow(),
                logoReveal: _phase(430, 880),
                logoOpacity: _phase(430, 260),
                brand: _phase(1140, 460),
                tagline: _phase(1380, 460),
                description: _phase(1580, 420),
                primaryAction: _phase(1780, 420),
                footer: _phase(1920, 380),
              );

              return Opacity(
                opacity: surfaceOpacity.clamp(0.0, 1.0),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(child: _SplashHeadline(motion: motion)),
                    Positioned(
                      left: _SplashMetrics.horizontalInset,
                      right: _SplashMetrics.horizontalInset,
                      bottom: _SplashMetrics.footerBottom,
                      child: _SplashReveal(
                        progress: motion.footer,
                        child: const _SplashFooter(),
                      ),
                    ),
                    Positioned(
                      left: _SplashMetrics.horizontalInset,
                      right: _SplashMetrics.horizontalInset,
                      bottom: _SplashMetrics.primaryButtonBottom,
                      child: _SplashReveal(
                        progress: motion.primaryAction,
                        child: const _SplashPrimaryAction(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Figma `_splash-breathe`：投影在 2.8s 内柔和地变亮 / 变大。
  List<BoxShadow> _orbShadow() {
    final double glow = _reduceMotion ? 0 : math.sin(_breath.value * math.pi);
    return <BoxShadow>[
      BoxShadow(
        color: Color.lerp(
          const Color(0x594F7EF5),
          const Color(0x6E726FEE),
          glow,
        )!,
        offset: const Offset(0, 20),
        blurRadius: 48 + 8 * glow,
      ),
    ];
  }
}

/// 本次进场动画的数值快照。
///
/// 把「时间轴」与「具体 Widget」解耦：State 只负责计算进度，
/// 视觉组件只负责把进度落到 `Transform` / `Opacity` 上。
class _SplashMotion {
  const _SplashMotion({
    required this.orbScale,
    required this.orbOpacity,
    required this.orbShadow,
    required this.logoReveal,
    required this.logoOpacity,
    required this.brand,
    required this.tagline,
    required this.description,
    required this.primaryAction,
    required this.footer,
  });

  final double orbScale;
  final double orbOpacity;
  final List<BoxShadow> orbShadow;
  final double logoReveal;
  final double logoOpacity;
  final double brand;
  final double tagline;
  final double description;
  final double primaryAction;
  final double footer;
}

/// 中部的品牌球 + 文字区。
class _SplashHeadline extends StatelessWidget {
  const _SplashHeadline({required this.motion});

  final _SplashMotion motion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _SplashOrb(motion: motion),
          const SizedBox(height: AppSpacing.xl),

          // Figma: 渐变填充文字（157deg，与 brandGradient 的 135deg 不同）
          _SplashReveal(
            progress: motion.brand,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) =>
                  AppColors.splashTitleGradient.createShader(bounds),
              child: const Text(
                'Careerly',
                textAlign: TextAlign.center,
                style: AppTypography.splashBrandTitle,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          _SplashReveal(
            progress: motion.tagline,
            child: const Column(
              children: <Widget>[
                Text(
                  '看见能力 · 跨越 Gap',
                  textAlign: TextAlign.center,
                  style: AppTypography.splashTagline,
                ),
                Text(
                  '记录成长',
                  textAlign: TextAlign.center,
                  style: AppTypography.splashTagline,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.blockGap),

          _SplashReveal(
            progress: motion.description,
            child: const Text(
              '你的职业成长，从看见自己开始。',
              textAlign: TextAlign.center,
              style: AppTypography.splashDescription,
            ),
          ),
        ],
      ),
    );
  }
}

/// 开屏品牌球：渐变圆 + **白色字标** + 呼吸投影。
///
/// Figma `OnSplash` 的球体不是空的 —— 中心有一个 126×60 的白色字标，
/// 且字标带一段「从左向右显现」的入场（`_splash-mark-draw`）。
/// 这里用 [CustomClipper] 做同样的横向揭示：素材是填充路径，
/// 无法直接复用 stroke-dashoffset 的描边动画。
class _SplashOrb extends StatelessWidget {
  const _SplashOrb({required this.motion});

  final _SplashMotion motion;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: motion.orbOpacity.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: motion.orbScale,
        child: Container(
          width: _SplashMetrics.orbSize,
          height: _SplashMetrics.orbSize,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: AppRadius.borderPill,
            boxShadow: motion.orbShadow,
          ),
          alignment: Alignment.center,
          child: SizedBox(
            width: _SplashMetrics.logoWidth,
            height: _SplashMetrics.logoHeight,
            child: Opacity(
              opacity: motion.logoOpacity.clamp(0.0, 1.0),
              child: ClipRect(
                clipper: _SplashLogoClipper(
                  reveal: motion.logoReveal.clamp(0.0, 1.0),
                ),
                child: SvgPicture.asset(
                  _SplashMetrics.logoAsset,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 字标从左到右的揭示裁切。
class _SplashLogoClipper extends CustomClipper<Rect> {
  const _SplashLogoClipper({required this.reveal});

  final double reveal;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, 0, size.width * reveal, size.height);

  @override
  bool shouldReclip(covariant _SplashLogoClipper oldClipper) =>
      oldClipper.reveal != reveal;
}

/// Figma `_splash-copy-in`：淡入 + 上移 9px。
class _SplashReveal extends StatelessWidget {
  const _SplashReveal({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double t = progress.clamp(0.0, 1.0);
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, (1 - t) * 9), child: child),
    );
  }
}

/// 底部的**主线入口**：一个渐变主按钮「点击注册」。
///
/// ⚠️ Figma 的按钮是 `left-6 right-6 mx-auto max-w-[342px]` ——
/// 左右各让 24，且**大屏上不拉满**（342 上限）后居中。
/// 页面级 `Positioned` 已经让出了左右 24，这里只负责居中与限宽。
class _SplashPrimaryAction extends StatelessWidget {
  const _SplashPrimaryAction();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _SplashMetrics.buttonMaxWidth,
        ),
        child: CareerlyButton(
          label: '点击注册',
          // ⚠️ `authPrimary`（172.01deg / 投影 0 8px 12px），
          // 不是默认的 `primary`（135deg / 0 8px 24px）—— 见枚举文档。
          variant: CareerlyButtonVariant.authPrimary,
          onPressed: () => context.go(AppRoutes.onboardingRegister),
        ),
      ),
    );
  }
}

/// 底部的**退路入口**：「已经有账户了? 点击登录」。
///
/// ⚠️ 它**不是**按钮 —— Figma 里这是一段 `<p>` 里嵌一个 `<button>`，
/// 因此用 `CareerlyTextLink`（行内文字）而不是 `CareerlyButton`
/// （固定高 48 的块）。两者的行为本来就不同，见该组件的文档。
class _SplashFooter extends StatelessWidget {
  const _SplashFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Figma 这里有一个尾随空格（`已经有账户了? `）。
        const Text('已经有账户了? ', style: AppTypography.splashFooter),
        CareerlyTextLink(
          label: '点击登录',
          style: AppTypography.splashFooterLink,
          onPressed: () => context.go(AppRoutes.onboardingLogin),
          // 「点击登录」在别处也可能出现，读屏器需要能区分上下文。
          semanticsLabel: '已经有账户了，点击登录',
        ),
      ],
    );
  }
}

/// 页面内部几何。
///
/// 单独列出而不是散在 build 里，是为了让「哪些数字来自 Figma」
/// 一眼可见（`CLAUDE.md` §8.2：页面不得内联暂定数值）。
abstract final class _SplashMetrics {
  /// Figma `OnSplash`：品牌球 `width: 141, height: 141`。
  ///
  /// ⚠️ 它是**页面内的尺寸常量**，未进 Token ——
  /// 它不属于间距 / 圆角 / 颜色 / 字号任何一类既有 Token 家族，
  /// 且只在这一处出现。若后续再出现「品牌大球」场景，应提为 Token。
  static const double orbSize = 141;

  /// Figma 品牌字标：`width: 126, height: 60, viewBox 60 48 188 83`。
  ///
  /// 素材来自 `careerly-assets/svg/logo.svg`（黑色字标），
  /// 视觉上通过 `ColorFilter` 转成白色 —— 与 Figma 的白色描边一致。
  static const String logoAsset = 'assets/images/brand/careerly-logo.svg';
  static const double logoWidth = 126;
  static const double logoHeight = 60;

  /// Figma：主按钮容器 `left-6 right-6`（`inset-x-6`）→ 左右各 24。
  ///
  /// ⚠️ 与 `AppSpacing.lg`（24）同值，但**刻意不复用别名**：
  /// 这里的 24 是「`inset-x-6` 这个 Tailwind 类的字面含义」，
  /// 而 `AppSpacing.pageHorizontal` 是另一个语义槽位（且目前取 16）。
  /// 直接取其值而不借其名，避免两处将来一起漂。
  static const double horizontalInset = 24;

  /// Figma：主按钮 `max-w-[342px]`。
  static const double buttonMaxWidth = 342;

  /// Figma：主按钮 `bottom: 117`。
  static const double primaryButtonBottom = 117;

  /// Figma：底部文字 `bottom: 52`。
  static const double footerBottom = 52;
}
