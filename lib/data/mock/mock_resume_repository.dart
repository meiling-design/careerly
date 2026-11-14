import '../../core/errors/app_error.dart';
import '../models/resume_file.dart';
import '../models/resume_profile.dart';
import '../repositories/resume_repository.dart';
import 'mock_config.dart';

/// [ResumeRepository] 的 Mock 实现。
///
/// ⚠️ **默认返回 [ResumeProfile.empty]**——
/// 相当于「尚未上传简历」的新用户，让 Onboarding / 我的简历
/// 走 Empty State 分支（PRD §15）。
///
/// Phase 1 不实现简历上传与解析（明确禁止 Resume Parser）。
class MockResumeRepository implements ResumeRepository {
  MockResumeRepository({MockConfig? config})
    : _config = config ?? MockSettings.config;

  final MockConfig _config;

  @override
  Future<ResumeProfile> fetchProfile() async {
    await _config.simulate();
    return ResumeProfile.empty;
  }

  @override
  Future<List<ResumeVersion>> fetchVersions() async {
    await _config.simulate();
    return const <ResumeVersion>[];
  }

  @override
  Future<List<int>> fetchVersionOriginalPdf(String versionId) async {
    await _config.simulate();
    throw const UnknownError(
      message: 'Mock 简历存储没有原始 PDF',
      detail: 'MockResumeRepository.fetchVersionOriginalPdf',
    );
  }

  @override
  Future<void> setCurrentVersion(String versionId) async {
    await _config.simulate();
    // Phase 1 无本地/远端存储，写入操作明确失败，
    // 避免上层误以为已经持久化成功。
    throw const UnknownError(
      message: '简历存储尚未接入',
      detail: 'MockResumeRepository.setCurrentVersion',
    );
  }

  @override
  Future<void> deleteVersion(String versionId) async {
    await _config.simulate();
    // 与 [setCurrentVersion] 同一口径：Mock 无存储，写入动作明确失败。
    throw const UnknownError(
      message: '简历存储尚未接入',
      detail: 'MockResumeRepository.deleteVersion',
    );
  }

  // ---------------------------------------------------------------------------
  // Onboarding 的「提交简历 → 建立职业基线」（Phase 4 批 2）
  // ---------------------------------------------------------------------------

  /// 提交简历文本。
  ///
  /// ⚠️ Mock **不做持久化** —— 没有本地/远端存储（D52）。
  /// 文本到此为止，不会流向 [buildBaseline]。
  /// 真实实现会把文本送进解析服务；届时上层无需改动。
  @override
  Future<void> submitResumeText(String text) async {
    await _config.simulate();
  }

  /// 提交简历文件。
  ///
  /// 与 [submitResumeText] 同一口径：Mock **不持久化**（D52）。
  /// 真实实现会 multipart 上传到 Resume Parse API；届时上层无需改动。
  @override
  Future<void> submitResumeFile(ResumeFileData file) async {
    await _config.simulate();
  }

  /// 建立职业基线。
  ///
  /// ⚠️ **Mock 不做任何解析**，一律返回 [ResumeProfile.empty]。
  ///
  /// 这是刻意的（`CLAUDE.md` §7「不编造产品数据」）：
  /// 若这里编出一份「工作经历 / 技能 / 能力画像」，
  /// 它会被当成真实解析结果，进而被误读成需求。
  ///
  /// 代价是「确认职业信息」屏在 Mock 下**恒为 Empty 态** ——
  /// 这正是 §5.5 要求的四态之一，本轮把它真实地实现出来，
  /// 接真实 API 后同一页面即渲染真实数据，页面代码不改。
  @override
  Future<ResumeProfile> buildBaseline() async {
    await _config.simulate();
    return ResumeProfile.empty;
  }
}
