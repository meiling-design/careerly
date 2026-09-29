import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../data/models/resume_file.dart';
import '../errors/app_error.dart';

/// 「选择文件」的平台网关。
///
/// ## 为什么抽象成接口
///
/// `FilePicker` 走平台通道（Android SAF / iOS Document Picker），
/// Widget 测试里**没有真通道**。抽象成接口后：
///
/// ```text
/// 生产：DefaultResumeFilePicker（file_picker 实现）
/// 测试：FakeResumeFilePicker（返回构造好的 ResumeFileData / null）
/// ```
///
/// 注册在 `lib/app/providers.dart`（唯一装配点），页面 `context.read` 取用。
///
/// ## 职责边界
///
/// 只做「选 → 读 → 收敛成 [ResumeFileData]」三件事：
/// - 类型白名单（PDF / Word）在这里卡（选择器层就过滤掉不支持的类型）；
/// - 大小上限**不在这里卡** —— 选择器无法按大小过滤，
///   由页面拿到文件后用 [ResumeFileData.exceedsLimit] 判断并提示；
/// - **不提交** —— 提交走 `ResumeRepository.submitResumeFile`。
abstract interface class ResumeFilePicker {
  /// 弹出系统文件选择器。
  ///
  /// 返回 `null` 表示**用户取消**（不是失败，UI 不做任何提示）。
  /// 文件读到但内容为空（极少见：云端文件未下载完成等）时
  /// 抛 [UnknownError]，由 UI 归一化为错误提示。
  Future<ResumeFileData?> pick();
}

/// 基于 `file_picker` 的生产实现。
class DefaultResumeFilePicker implements ResumeFilePicker {
  const DefaultResumeFilePicker();

  @override
  Future<ResumeFileData?> pick() async {
    // file_picker ^13：`FilePicker` 是 abstract final class，方法为静态；
    // 返回 `PlatformFile?`（旧版是 `FilePickerResult?` + `withData`）。
    final PlatformFile? file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ResumeFileData.allowedExtensions.toList(),
    );

    // 用户取消。
    if (file == null) return null;

    // v13 起字节不再随返回结果带出，需要显式读取：
    // 解析 API 的 multipart 需要字节，且 10MB 上限下内存压力可控。
    final Uint8List bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw UnknownError(
        message: '文件读取失败，请重新选择',
        detail: 'DefaultResumeFilePicker: bytes.isEmpty (${file.name})',
      );
    }

    return ResumeFileData(
      name: file.name,
      extension: (file.extension ?? '').toLowerCase(),
      // 大小按实际读到的字节数算（v13 无 `size` 字段）。
      sizeBytes: bytes.length,
      bytes: bytes,
    );
  }
}
