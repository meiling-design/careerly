import '../models/resume_file.dart';
import '../models/resume_profile.dart';

/// 简历与职业资产数据访问接口。
///
/// 归属（PRD §14 / Baseline §3.3）：简历属于职业资产，由「我的」管理。
/// 「分析」可以**调用**简历，但不负责简历的长期管理。
///
/// Phase 1 只定义接口，**不实现简历解析**（Phase 1 §八明确禁止 Resume Parser）。
abstract interface class ResumeRepository {
  /// 读取简历解析后的职业画像 / 职业基线。
  Future<ResumeProfile> fetchProfile();

  /// 读取简历版本列表（当前简历 + 历史简历）。
  Future<List<ResumeVersion>> fetchVersions();

  /// 设置当前简历版本。
  ///
  /// Phase 1 只定义签名，不接入真实实现。
  Future<void> setCurrentVersion(String versionId);

  // ---------------------------------------------------------------------------
  // Onboarding 的「提交简历 → 建立职业基线」两屏（Phase 4 批 2）
  // ---------------------------------------------------------------------------

  /// 提交一份简历文本（「粘贴简历文本」路径）。
  ///
  /// ⚠️ **只做提交，不做解析、不建立基线** —— 对应 Figma 的 `on-resume` 一屏。
  /// 解析发生在下一页（[buildBaseline]）。
  Future<void> submitResumeText(String text);

  /// 提交一份简历文件（「选择文件」路径，**D67 已关闭**）。
  ///
  /// 与 [submitResumeText] 平行：同样**只做提交**，
  /// 解析发生在 [buildBaseline]。
  ///
  /// 真实实现：multipart 上传到 Resume Parse API；
  /// Mock 实现：不持久化（D52），与文本路径同一口径。
  Future<void> submitResumeFile(ResumeFileData file);

  /// 用最近一次提交的简历建立**职业基线**（PRD §7.2）。
  ///
  /// 对应 Figma 的 `on-parsing` 一屏。
  ///
  /// ⚠️ **这不是「分析」** —— 本方法内不得涉及 JD、目标岗位、
  /// 匹配度、排名或 Gap（PRD §7.1 / Baseline §4.1 的逐条禁令，
  /// 并见产品侧裁决 **D63**）。
  ///
  /// ⚠️ **不扣分析额度**（CLAUDE.md §5.2：上传简历 / 粘贴 JD 均不扣额度，
  /// 只有点击「开始分析」才扣）。
  Future<ResumeProfile> buildBaseline();
}
