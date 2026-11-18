import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/support_mail.dart';
import '../../../../design_system/components/components.dart';

/// 打开系统邮件应用，并在不可用时把内容复制到剪贴板。
///
/// ## 为什么需要这个兜底
///
/// 帮助中心 / 意见反馈 / 关于页的「联系邮箱」都必须**真的有去向**。
/// 如果设备上没有邮件客户端，直接提示「已发送」就是伪造成功；
/// 这里改为复制收件地址（反馈页还会复制整封邮件内容），
/// 用户仍可手动粘贴到任意邮件工具里。
Future<void> sendSupportMail(
  BuildContext context, {
  required String subject,
  String? body,
  String? clipboardFallback,
  SupportMailLauncher? launcher,
}) async {
  final Uri uri = SupportMail.compose(subject: subject, body: body);
  final SupportMailLauncher open = launcher ?? SupportMail.open;
  final bool opened = await open(uri);

  if (!context.mounted) return;

  if (opened) {
    CareerlyToast.show(
      context,
      message: '已打开邮件应用，请确认发送',
      icon: Icons.check_circle_outline,
    );
    return;
  }

  final String text = clipboardFallback ?? SupportMail.address;
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;

  CareerlyToast.show(
    context,
    message: '未能打开邮件应用，内容已复制，可发送至 ${SupportMail.address}',
    icon: Icons.info_outline,
  );
}
