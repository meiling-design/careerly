import 'package:flutter/foundation.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/state/state.dart';
import '../../../data/models/ai_message.dart';
import '../../../data/repositories/ai_repository.dart';

/// AI 对话状态。
///
/// 当前阶段只负责 Chat UI + Mock Response，不构建 Career Context。
class AIProvider extends ChangeNotifier {
  AIProvider(this._repository);

  final AIRepository _repository;
  final List<AIMessage> _messages = <AIMessage>[];
  AsyncState<AIMessage> _responseState = const AsyncState<AIMessage>.initial();
  String _lastMessage = '';

  List<AIMessage> get messages => List<AIMessage>.unmodifiable(_messages);
  AsyncState<AIMessage> get responseState => _responseState;
  bool get isLoading => _responseState.isLoading;
  AppError? get error => _responseState.errorOrNull;

  Future<void> sendMessage(String text) async {
    final String value = text.trim();
    if (value.isEmpty || isLoading) return;
    _lastMessage = value;

    _messages.add(
      AIMessage(
        id: 'user-${_messages.length + 1}',
        text: value,
        isUser: true,
        createdAt: DateTime.now(),
      ),
    );
    _responseState = const AsyncState<AIMessage>.loading();
    notifyListeners();

    try {
      final AIMessage response = await _repository.sendMessage(value);
      _messages.add(response);
      _responseState = AsyncState<AIMessage>.success(response);
    } catch (error, stackTrace) {
      _responseState = AsyncState<AIMessage>.failure(
        AppError.from(error, stackTrace),
      );
    }
    notifyListeners();
  }

  void clearError() {
    if (!_responseState.isFailure) return;
    _responseState = const AsyncState<AIMessage>.initial();
    notifyListeners();
  }

  Future<void> retryLastMessage() async {
    if (_lastMessage.isEmpty || isLoading) return;
    if (_messages.isNotEmpty && _messages.last.isUser) {
      _messages.removeLast();
    }
    await sendMessage(_lastMessage);
  }
}
