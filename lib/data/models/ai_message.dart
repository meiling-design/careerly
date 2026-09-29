import 'package:flutter/foundation.dart';

/// AI 对话中的一条消息。
@immutable
class AIMessage {
  const AIMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.createdAt,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime? createdAt;
}
