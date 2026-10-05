/// Careerly 全局常量。
///
/// 只放**跨模块稳定不变**的事实。
/// 业务规则（额度、分数区间等）不放这里猜测，必须来自
/// `docs/01_...PRD` / `docs/04_...IA` / `docs/07_...Baseline`。
///
/// 路由常量不在此文件，见 `lib/app/router/app_routes.dart`。
abstract final class AppConstants {
  /// 应用展示名。
  static const String appName = 'Careerly';

  /// 应用标语。PRD §1.1。
  static const String tagline = '看见能力 · 跨越 Gap · 记录成长';

  /// 匹配度分值区间。PRD §9.4：0–100。
  ///
  /// **硬规则：分值只由能力匹配计算，薪资 / 通勤 / 城市不得进入。**
  static const int matchScoreMin = 0;
  static const int matchScoreMax = 100;

  /// 免费用户的完整分析次数。PRD §16 / Baseline §5。
  static const int freeAnalysisQuota = 3;

  /// 密码的最小长度。
  ///
  /// ⚠️ **真值来源是后端**，不是这里 ——
  /// `work_agent/app/core/passwords.py` 的 `MIN_PASSWORD_LENGTH`（= 6，
  /// 2026-10-04 产品侧裁决：「最保守：bcrypt + 最小 6 位非空，
  /// 不做强度校验」）。真正的判定点在服务端（短密码走 401）。
  ///
  /// 本常量是**客户端镜像**，只用于一件事：让注册 / 登录页在按下主按钮
  /// **之前**就能表达「还差几位」。两处若不一致，**以后端为准**并改这里。
  ///
  /// 放在 `AppConstants` 而不是各自页面里，是因为注册页与登录页
  /// **都需要**它 —— 两份字面量迟早会漂。
  static const int passwordMinLength = 6;

  /// 底部导航**浮层**高度（不含底部 SafeArea）。
  ///
  /// Figma `BottomNav`：上留白 8 + AI 浮球 62 + 下留白 20 = 90。
  /// 注意这是**浮层压住内容**的高度，不是它占据的文档流高度
  /// —— 导航是 `position: absolute` 的覆盖层，不参与内容布局。
  static const double navigationBarHeight = 90;

  /// 内容区需要为底部导航预留的避让高度（含底部 SafeArea 之外的余量）。
  ///
  /// Figma 内容区使用 `pb-24`（96px）让最后一段内容不被浮起的导航遮住。
  static const double navigationBarContentInset = 96;
}
