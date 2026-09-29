import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/state/state.dart';
import '../../../data/models/resume_file.dart';
import '../../../data/models/resume_profile.dart';
import '../../../data/repositories/resume_repository.dart';

/// 「提交简历」这一动作的生命周期。
///
/// ⚠️ 与 [ResumeProvider] 的 `state`（职业基线本身）**不是同一件事**：
///
/// | 关注点 | 载体 | 对应屏 |
/// |---|---|---|
/// | **提交**这份简历成不成功 | 本枚举 + [ResumeProvider.submitError] | `on-resume` |
/// | **建立**职业基线成不成功 | [AsyncStateNotifier.state] | `on-parsing` |
///
/// 拆开是因为两屏的失败语义不同：提交失败留在原页重试，
/// 基线建立失败要展示解析错误的四态。合成一个状态会让
/// 「重试」按钮不知道该重试哪一步。
///
/// ## 命名对齐 Flutter Dev Spec §16「Resume」
///
/// 规范给出的简历状态是 `idle / uploading / parsing / success / error`。
/// 本枚举取其中的 **`idle` / `uploading` / `success` / `error`**，
/// 而 **`parsing`** 由 `on-parsing` 屏的 [AsyncStateNotifier.state] 承载
/// —— 两屏各占一段，合起来即完整的规范状态集。
///
/// > 「上传」在规范里是这一段的**统称**（§16 的流程为
/// > 「选择 / 上传简历 → 上传 → 解析」），
/// > 「粘贴简历文本」走的是同一段，故共用 [uploading] 一词。
enum ResumeSubmitStatus { idle, uploading, success, failure }

/// 简历 / 职业资产状态。
///
/// 归属（PRD §14 / Baseline §3.3）：简历属于职业资产，由「我的」管理。
///
/// ## 两段职责
///
/// 1. **读取** —— [load] 取回已经建立的职业基线（「我的 → 我的简历」用）。
/// 2. **建立** —— [submitText] + [buildBaseline] 走完
///    Figma 的「提交简历 → 解析」两屏（Phase 4 批 2）。
///
/// 第二段是 PRD §7.2 的 Career Baseline 建立流程：
/// **只看简历，不涉及 JD、不做匹配、不扣分析额度。**
class ResumeProvider extends AsyncStateNotifier<ResumeProfile> {
  ResumeProvider(this._repository);

  final ResumeRepository _repository;

  ResumeSubmitStatus _submitStatus = ResumeSubmitStatus.idle;
  AppError? _submitError;

  /// 提交动作的当前状态。
  ResumeSubmitStatus get submitStatus => _submitStatus;

  /// 提交失败原因。仅在 [submitStatus] 为
  /// [ResumeSubmitStatus.failure] 时非空。
  AppError? get submitError => _submitError;

  /// 是否正在提交。UI 据此禁用输入与按钮。
  bool get isUploading => _submitStatus == ResumeSubmitStatus.uploading;

  /// 读取简历解析后的职业画像。
  Future<void> load() => execute(_repository.fetchProfile);

  /// 是否已建立职业基线。
  ///
  /// 对应 PRD §7.2：Careerly 根据用户首次提交的当前简历建立的初始状态。
  bool get hasBaseline => data?.hasBaseline ?? false;

  /// 提交一份简历文本（「粘贴简历文本」路径）。
  ///
  /// 返回 `true` 表示提交成功。失败时**不抛异常** ——
  /// 错误已归一化进 [submitError]，由 UI 渲染（四态要求）。
  Future<bool> submitText(String text) async {
    _setSubmit(ResumeSubmitStatus.uploading, null);

    try {
      await _repository.submitResumeText(text.trim());
    } catch (error, stackTrace) {
      _setSubmit(
        ResumeSubmitStatus.failure,
        ErrorHandler.normalize(error, stackTrace),
      );
      return false;
    }

    _setSubmit(ResumeSubmitStatus.success, null);
    return true;
  }

  /// 提交一份简历文件（「选择文件」路径，**D67 已关闭**）。
  ///
  /// 与 [submitText] 同一生命周期：成功 → `on-parsing`，
  /// 失败 → 错误归一化进 [submitError]，由 UI 渲染。
  Future<bool> submitFile(ResumeFileData file) async {
    _setSubmit(ResumeSubmitStatus.uploading, null);

    try {
      await _repository.submitResumeFile(file);
    } catch (error, stackTrace) {
      _setSubmit(
        ResumeSubmitStatus.failure,
        ErrorHandler.normalize(error, stackTrace),
      );
      return false;
    }

    _setSubmit(ResumeSubmitStatus.success, null);
    return true;
  }

  /// 建立职业基线（`on-parsing` 一屏调用）。
  ///
  /// 走 [AsyncStateNotifier.execute]，因此四态天然可用：
  /// `isLoading`（解析中）/ `data`（解析结果）/ `error`（解析失败，可重试）。
  ///
  /// ⚠️ **不扣分析额度**（CLAUDE.md §5.2）。
  Future<void> buildBaseline() => execute(_repository.buildBaseline);

  /// 清掉本次 Onboarding 留下的提交状态。
  ///
  /// 用于两处：进入「提交简历」页时（清上一次的残状态）、
  /// 以及确认完成后离开引导流程时。
  void resetSubmit() => _setSubmit(ResumeSubmitStatus.idle, null);

  void _setSubmit(ResumeSubmitStatus status, AppError? error) {
    _submitStatus = status;
    _submitError = error;
    notifyListeners();
  }
}
