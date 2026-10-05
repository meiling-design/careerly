import 'package:flutter/material.dart';
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
class OnboardingSplashPage extends StatelessWidget {
  const OnboardingSplashPage({super.key});

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
          child: Stack(
            children: <Widget>[
              const Positioned.fill(child: _SplashHeadline()),
              const Positioned(
                left: _SplashMetrics.horizontalInset,
                right: _SplashMetrics.horizontalInset,
                bottom: _SplashMetrics.footerBottom,
                child: _SplashFooter(),
              ),
              Positioned(
                left: _SplashMetrics.horizontalInset,
                right: _SplashMetrics.horizontalInset,
                bottom: _SplashMetrics.primaryButtonBottom,
                child: const _SplashPrimaryAction(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 中部的品牌球 + 文字区。
class _SplashHeadline extends StatelessWidget {
  const _SplashHeadline();

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
          // Figma: 141×141 圆 + 135deg 品牌渐变 + `0 20px 48px rgba(79,126,245,0.35)`
          Container(
            width: _SplashMetrics.orbSize,
            height: _SplashMetrics.orbSize,
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: AppRadius.borderPill,
              boxShadow: AppShadows.splashOrb,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Figma: 渐变填充文字（157deg，与 brandGradient 的 135deg 不同）
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (Rect bounds) =>
                AppColors.splashTitleGradient.createShader(bounds),
            child: const Text(
              'Careerly',
              textAlign: TextAlign.center,
              style: AppTypography.splashBrandTitle,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          const Text(
            '看见能力 · 跨越 Gap',
            textAlign: TextAlign.center,
            style: AppTypography.splashTagline,
          ),
          const Text(
            '记录成长',
            textAlign: TextAlign.center,
            style: AppTypography.splashTagline,
          ),
          const SizedBox(height: AppSpacing.blockGap),

          const Text(
            '你的职业成长，从看见自己开始。',
            textAlign: TextAlign.center,
            style: AppTypography.splashDescription,
          ),
        ],
      ),
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
