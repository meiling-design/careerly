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
/// 大小上限（10MB）来自 Figma `OnResume` 的页面文案
/// （`src/App.tsx` L768「PDF / Word · 最大 10MB」）—— **不放大**。
///
/// 类型白名单**与后端 `POST /api/v1/resume` 的 `_ALLOWED_RESUME_SUFFIXES`
/// 逐项一致**（2026-10-02）：白名单必须收敛到 **ResumeAgent 真能解析的格式**，
/// 否则会放行必然被后端拒绝的类型。
///
/// ```text
/// ✅ 文档：pdf / docx / txt
/// ✅ 截图：png / jpg / jpeg / webp / bmp   ← 走 OCR（产品侧 2026-10-02 指令）
/// ❌ doc   旧二进制格式，python-docx 读不了 —— 后端必拒，故不放行
/// ```
///
/// ⚠️ 上传卡上的**文案**已同步改为「PDF / Word / 图片截图」
/// —— 改法由产品侧 2026-10-02 拍板（`TODO.md` §3.1 · **D107**，已裁决）。
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

  /// 允许的类型白名单 —— 与后端 `_ALLOWED_RESUME_SUFFIXES` 逐项一致。
  static const Set<String> allowedExtensions = <String>{
    'pdf',
    'docx',
    'txt',
    'png',
    'jpg',
    'jpeg',
    'webp',
    'bmp',
  };

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
