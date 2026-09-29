import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';

/// 开屏页 —— Onboarding 第 1 屏。
///
/// 真值来源：Figma `OnSplash`（`src/App.tsx` L366-425）。
///
/// ```text
/// 背景   linear-gradient(111deg, rgb(220,233,251) → rgb(251,233,241))
/// 内容   141×141 品牌渐变球 → 「Careerly」渐变文字
///        → 「看见能力 · 跨越 Gap」→「记录成长」→ 说明文案
/// 底部   「点击登录」(主按钮) / 「点击注册」(白底按钮)
/// ```
///
/// ## ⚠️ 两个按钮的去向（2026-09-21 起，已被 D85 改写）
///
/// ```text
/// Figma 原行为   两个按钮的 onClick **都**是 go('on-register')
///                （`App.tsx` L409 / L416），且 `ONBOARDING_SCREENS`（L5162）
///                里没有独立登录屏 —— 设计稿中「登录」不拥有自己的页面。
/// 现在           「点击注册」→ 账号页**注册形态**
///                「点击登录」→ 同一条路由 + `?mode=login` → **登录形态**
/// ```
///
/// **仍然是同一条路由、同一个页面** —— 产品侧裁决 **D85**：
/// 登录补成账号页内的**模式切换**，不新增一级页面、不新增路由
/// （原 **D55** 就此结案，采用其中的「方案 B」）。
/// 因此 Figma 那句「两个按钮都进注册页」不再原样成立，
/// 但**没有**多出任何页面。
///
/// ## ⚠️ 未做的部分
///
/// Figma 开屏顶部有**自绘的 iOS 状态栏**（`9:41` + 信号 / 电池 SVG）。
/// Flutter 侧的状态栏是系统绘制的，不在页面内 —— 这块归 **K13**
/// （`TODO.md` §2.2），**本批未实现**，因为它牵涉全局的
/// `SystemChrome` / `AnnotatedRegion` 策略，不是开屏一页的事。
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
          child: Column(
            children: <Widget>[
              Expanded(child: const _SplashHeadline()),
              const _SplashActions(),
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

/// 底部的两个入口按钮。
class _SplashActions extends StatelessWidget {
  const _SplashActions();

  @override
  Widget build(BuildContext context) {
    // ⚠️ 两个按钮去**同一个页面的两种形态**（D85），见本页类文档。
    void goToRegister() => context.go(AppRoutes.onboardingRegister);
    void goToLogin() => context.go(AppRoutes.onboardingRegisterLogin);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        children: <Widget>[
          CareerlyButton(
            label: '点击登录',
            onPressed: goToLogin,
          ),
          const SizedBox(height: AppSpacing.buttonStack),
          CareerlyButton(
            label: '点击注册',
            variant: CareerlyButtonVariant.neutral,
            onPressed: goToRegister,
          ),
        ],
      ),
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
  /// ⚠️ 这是**唯一的页面级尺寸常量**，未进 Token ——
  /// 它不属于间距 / 圆角 / 颜色 / 字号任何一类既有 Token 家族，
  /// 且只在这一处出现。若后续再出现「品牌大球」场景，应提为 Token。
  static const double orbSize = 141;
}
