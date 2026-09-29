import 'package:flutter/foundation.dart';

/// 一份**待提交的简历文件**（「选择文件」路径）。
///
/// 与「粘贴简历文本」路径的 `String` 平行：
///
/// ```text
/// 粘贴文本 → String          → ResumeRepository.submitResumeText
/// 选择文件 → ResumeFileData  → ResumeRepository.submitResumeFile
/// ```
///
/// ## 为什么不让 `PlatformFile` 漏进数据层
///
/// `file_picker` 的 `PlatformFile` 是平台网关的类型，
/// Repository / Provider / 测试都不该依赖它。
/// 页面在边界处把它**收敛**为本类型，之后全链路只认 [ResumeFileData]。
///
/// ## 约束来源
///
/// 类型白名单与大小上限来自 Figma `OnResume` 的页面文案
/// （`src/App.tsx` L761「支持 PDF、Word 格式」/ L768「PDF / Word · 最大 10MB」）
/// —— **不擅自扩展**（不加 txt / 图片，不放大上限）。
@immutable
class ResumeFileData {
  const ResumeFileData({
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.bytes,
  });

  /// 文件名（含扩展名），如 `张三-产品经理-2026.pdf`。
  final String name;

  /// 小写扩展名（不含点），如 `pdf`。
  final String extension;

  /// 文件大小（字节）。
  final int sizeBytes;

  /// 文件内容。解析 API 的 multipart 上传体。
  final Uint8List bytes;

  /// Figma 允许的类型白名单（PDF / Word）。
  static const Set<String> allowedExtensions = <String>{'pdf', 'doc', 'docx'};

  /// Figma 文案的大小上限：10MB。
  static const int maxSizeBytes = 10 * 1024 * 1024;

  /// 是否超过大小上限。超限文件**不提交**，由 UI 提示更换。
  bool get exceedsLimit => sizeBytes > maxSizeBytes;

  /// 展示用大小（如 `3.2MB` / `512KB`）。
  String get displaySize {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / 1024 / 1024).toStringAsFixed(1)}MB';
    }
    return '${(sizeBytes / 1024).ceil()}KB';
  }

  @override
  String toString() =>
      'ResumeFileData($name, $extension, $displaySize, ${bytes.length}B)';
}
