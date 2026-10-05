import 'package:flutter/foundation.dart';

import 'ai_message.dart';

/// A client-side conversation that can be resumed from the chat history.
@immutable
class AIConversation {
  const AIConversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.tag = '对话',
  });

  final String id;
  final String title;
  final List<AIMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String tag;

  String get preview {
    if (messages.isEmpty) return '';
    final String text = messages.last.text.replaceAll('\n', ' ').trim();
    return text.length > 32 ? '${text.substring(0, 32)}…' : text;
  }

  AIConversation copyWith({
    String? title,
    List<AIMessage>? messages,
    DateTime? updatedAt,
  }) {
    return AIConversation(
      id: id,
      title: title ?? this.title,
      messages: List<AIMessage>.unmodifiable(messages ?? this.messages),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tag: tag,
    );
  }

  static String titleFrom(String text) {
    final String normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized.length > 24
        ? '${normalized.substring(0, 24)}…'
        : normalized;
  }

  static String tagFrom(String text) {
    final String normalized = text.toLowerCase();
    final RegExpMatch? percentage = RegExp(r'\b\d{1,3}%').firstMatch(text);
    if (percentage != null) return percentage.group(0)!;
    if (normalized.contains('简历') || normalized.contains('项目')) {
      return '简历';
    }
    if (normalized.contains('能力') || normalized.contains('gap')) {
      return '能力';
    }
    if (normalized.contains('下一步') ||
        normalized.contains('计划') ||
        normalized.contains('应该做什么')) {
      return '规划';
    }
    return '对话';
  }
}

/// 一次 AI 提问的入参。
///
/// 对应后端 `POST /api/v1/ai/messages` 的请求体
/// （契约见 `docs/careerly/BACKEND_API_CONTRACT.md` §0.5.8）。
///
/// ⚠️ **不含 user id** —— 身份由 JWT 携带，客户端传什么都不影响数据作用域。
/// ⚠️ **不含 Career Context** —— 只带入口 id，上下文由后端按 id 重新取数组装，
/// 这样用户更新简历后，对话里不会还拿着旧数据。
@immutable
class AIRequest {
  const AIRequest({
    required this.message,
    this.projectId,
    this.jobId,
    this.history = const <AIMessage>[],
  });

  /// 本轮用户输入。
  final String message;

  /// 入口上下文：分析项目 id。
  ///
  /// 从岗位详情 / 分析结果进入时携带；
  /// `null` 时后端回退「该用户最近一次分析」，一次分析都没有则走通用顾问。
  final String? projectId;

  /// 入口上下文：聚焦的某个岗位（可选）。
  final String? jobId;

  /// 本会话**本轮之前**已落定的对话。
  ///
  /// 后端不留存会话，多轮上下文靠这里带回去。
  /// ⚠️ 不含本轮 [message] —— 后端把它作为最后一轮 `user` 追加。
  final List<AIMessage> history;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'message': message,
    if (projectId != null) 'projectId': projectId,
    if (jobId != null) 'jobId': jobId,
    'history': <Map<String, String>>[
      for (final AIMessage turn in history)
        <String, String>{
          'role': turn.isUser ? 'user' : 'assistant',
          'content': turn.text,
        },
    ],
  };
}

/// 服务端回答流上的一个事件。
///
/// 对应 SSE 帧 `start` / `delta` / `done`。
///
/// ⚠️ **`error` 帧不在此列** —— `ApiClient.postSse` 已把它与「开流前的
/// 403 / 404 / 503」一并转成抛出的 `AppError`。调用方因此只有**一条**
/// 失败路径（try/catch），不必同时处理「事件流里的错误」和「抛出的错误」。
@immutable
sealed class AIStreamEvent {
  const AIStreamEvent();
}

/// 流已建立（服务端 `start` 帧）。
final class AIStreamStarted extends AIStreamEvent {
  const AIStreamStarted();
}

/// 一段增量回答（服务端 `delta` 帧）。渲染时**追加**，不要整段替换。
final class AIStreamDelta extends AIStreamEvent {
  const AIStreamDelta(this.text);

  final String text;
}

/// 回答正常结束（服务端 `done` 帧）。
///
/// 这也是**唯一**的「成功」信号 —— 后端在发出它之前才扣减额度。
final class AIStreamDone extends AIStreamEvent {
  const AIStreamDone();
}
