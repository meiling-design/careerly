import 'package:url_launcher/url_launcher.dart';

/// Careerly 支持邮箱与 `mailto:` 组装。
///
/// ## 为什么反馈走邮件
///
/// 后端**没有** feedback 接口（`work_agent/app/api/` 下无对应路由），
/// 因此不能做一个「点提交后没有实际去向」的表单。这里统一用
/// 系统邮件应用作为真实出口：邮件由用户自己发出，收件人是下面这个地址。
///
/// ## 失败不伪造成功
///
/// [open] 返回 `false` 表示没有可用的邮件应用。调用方必须据此给出
/// 「复制邮箱 / 内容」的兜底，而**不是**提示「已提交」。
typedef SupportMailLauncher = Future<bool> Function(Uri uri);

abstract final class SupportMail {
  /// 应用内公开的支持邮箱（帮助中心 / 意见反馈 / 关于 Careerly）。
  static const String address = 'l1350900062@163.com';

  /// 组装一封给支持邮箱的 `mailto:` URI。
  ///
  /// 手动 `Uri.encodeComponent` 而不是用 `queryParameters`：
  /// 后者会把空格编码成 `+`，部分邮件客户端会原样显示 `+`。
  static Uri compose({required String subject, String? body}) {
    final String encodedSubject = Uri.encodeComponent(subject);
    final String encodedBody = Uri.encodeComponent(body ?? '');
    return Uri.parse(
      'mailto:$address?subject=$encodedSubject&body=$encodedBody',
    );
  }

  /// 尝试打开系统邮件应用。
  ///
  /// 插件不可用（桌面 / 测试环境）或系统没有邮件客户端时返回 `false`，
  /// 不抛异常 —— 调用方据此走复制兜底。
  static Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
