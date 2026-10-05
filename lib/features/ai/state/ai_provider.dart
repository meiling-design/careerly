import 'package:flutter/foundation.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/state/state.dart';
import '../../../data/models/ai_chat.dart';
import '../../../data/models/ai_message.dart';
import '../../../data/repositories/ai_repository.dart';

/// AI 对话状态。
///
/// ## 两条分开的消息流
///
/// ```text
/// _messages    已「落定」的对话 —— 用户消息 + 完整回答。永不半截。
/// _streaming   正在逐字生成的那条回答；不在生成时为 null。
/// ```
///
/// 分开的意义：**发给后端的历史**取自 [_messages]，因此永远只会带上完整
/// 轮次，不会把一句写到一半的回答当成上文。
///
/// ## 失败怎么收场
///
/// 已经收到的半句**不丢弃**，照样落进 [_messages] —— 后端不回滚已发出的
/// delta，界面上把它抹掉等于让用户白等一次。失败只体现在
/// [responseState] 上，界面据此给出重试。
class AIProvider extends ChangeNotifier {
  AIProvider(this._repository);

  final AIRepository _repository;

  final List<AIMessage> _messages = <AIMessage>[];
  final List<AIConversation> _conversations = <AIConversation>[];
  AIMessage? _streaming;
  AsyncState<AIMessage> _responseState = const AsyncState<AIMessage>.initial();
  String _lastMessage = '';
  String? _activeConversationId;
  int _conversationSequence = 0;

  /// 生成回答的 id 序号。保证同一轮回答在整个流式过程中 id 不变，
  /// 列表不至于因为 id 抖动而重建。
  int _assistantSequence = 0;

  List<AIMessage> get messages => List<AIMessage>.unmodifiable(_messages);

  List<AIConversation> get conversations {
    final List<AIConversation> sorted = List<AIConversation>.of(_conversations)
      ..sort(
        (AIConversation a, AIConversation b) =>
            b.updatedAt.compareTo(a.updatedAt),
      );
    return List<AIConversation>.unmodifiable(sorted);
  }

  String? get activeConversationId => _activeConversationId;

  /// 正在逐字生成的那条回答；当前没有生成时为 `null`。
  AIMessage? get streamingMessage => _streaming;

  AsyncState<AIMessage> get responseState => _responseState;

  /// 本轮是否仍在进行（含「首字未到」与「正在吐字」两段）。
  bool get isLoading => _responseState.isLoading;

  AppError? get error => _responseState.errorOrNull;

  /// Start a blank conversation without discarding any existing history.
  void startNewConversation() {
    if (isLoading) return;
    _activeConversationId = null;
    _messages.clear();
    _streaming = null;
    _lastMessage = '';
    _responseState = const AsyncState<AIMessage>.initial();
    notifyListeners();
  }

  /// Restore one of the conversations held by this provider.
  void selectConversation(String conversationId) {
    if (isLoading) return;
    AIConversation? selected;
    for (final AIConversation conversation in _conversations) {
      if (conversation.id == conversationId) {
        selected = conversation;
        break;
      }
    }
    if (selected == null) {
      throw ArgumentError.value(
        conversationId,
        'conversationId',
        'No such AI conversation',
      );
    }

    _activeConversationId = selected.id;
    _messages
      ..clear()
      ..addAll(selected.messages);
    _streaming = null;
    _lastMessage = _lastUserMessage(_messages);
    _responseState = const AsyncState<AIMessage>.initial();
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final String value = text.trim();
    if (value.isEmpty || isLoading) return;
    _lastMessage = value;

    // 历史 = 已落定的全部轮次，**不含**本轮 —— 后端把 message 作为
    // 最后一轮 user 追加。_streaming 本就在 _messages 之外，带不进去。
    final List<AIMessage> history = List<AIMessage>.of(_messages);

    _messages.add(
      AIMessage(
        id: 'user-${++_assistantSequence}',
        text: value,
        isUser: true,
        createdAt: DateTime.now(),
      ),
    );
    _ensureConversation(value);
    _saveActiveConversation();
    _streaming = null;
    _responseState = const AsyncState<AIMessage>.loading();
    notifyListeners();

    final String assistantId = 'ai-${++_assistantSequence}';
    String? buffer;
    DateTime? startedAt;
    bool done = false;

    try {
      await for (final AIStreamEvent event in _repository.sendMessage(
        AIRequest(message: value, history: history),
      )) {
        switch (event) {
          case AIStreamStarted():
            buffer = '';
            startedAt = DateTime.now();
          case AIStreamDelta(:final String text):
            buffer = (buffer ?? '') + text;
          case AIStreamDone():
            done = true;
        }

        // 每来一段就重建这条消息并通知 —— 「边生成边显示」就在这里。
        //
        // ⚠️ 判空**必须**带上 `isNotEmpty`：`start` 帧会把 buffer 置成空串，
        // 单看 `!= null` 就会立刻造出一条空消息，把一个**空气泡**推到界面上。
        // 推理模型（qwen3.5-plus）首字前要思考数十秒，那段时间用户看到的
        // 就是那个空气泡，而 `_TypingIndicator` 被 `streamingMessage == null`
        // 挡在门外、永远不显示 —— 于是「AI 正在思考…」成了不可达代码。
        // 留空串时 `_streaming` 保持 null，指示器才真的会出现。
        if (buffer != null && buffer.isNotEmpty) {
          _streaming = AIMessage(
            id: assistantId,
            text: buffer,
            isUser: false,
            createdAt: startedAt,
          );
        }
        notifyListeners();
      }

      if (!done) {
        // 流断了却没有 done 帧 → 回答可能被截断，**不能**算成功
        // （后端正是在发出 done 之前才扣额度）。
        throw const AIError(
          message: 'AI 回复未完成，请重试',
          detail: 'stream ended without done',
        );
      }

      final AIMessage? answer = _settle(
        buffer: buffer,
        id: assistantId,
        createdAt: startedAt,
      );
      _responseState = answer == null
          // 服务端一个字都没吐（极罕见）——不编一条空消息出来。
          ? const AsyncState<AIMessage>.initial()
          : AsyncState<AIMessage>.success(answer);
    } catch (error, stackTrace) {
      _settle(buffer: buffer, id: assistantId, createdAt: startedAt);
      _responseState = AsyncState<AIMessage>.failure(
        AppError.from(error, stackTrace),
      );
    }
    _saveActiveConversation();
    notifyListeners();
  }

  void clearError() {
    if (!_responseState.isFailure) return;
    _responseState = const AsyncState<AIMessage>.initial();
    notifyListeners();
  }

  Future<void> retryLastMessage() async {
    if (_lastMessage.isEmpty || isLoading) return;
    // 丢掉上一轮的残句与提问，再问一次 —— 重试是**重发**，不是续写。
    if (_messages.isNotEmpty && !_messages.last.isUser) {
      _messages.removeLast();
    }
    if (_messages.isNotEmpty && _messages.last.isUser) {
      _messages.removeLast();
    }
    await sendMessage(_lastMessage);
  }

  void _ensureConversation(String firstMessage) {
    if (_activeConversationId != null) return;
    final DateTime now = DateTime.now();
    final String id =
        'ai-conversation-${now.microsecondsSinceEpoch}-${++_conversationSequence}';
    _activeConversationId = id;
    _conversations.add(
      AIConversation(
        id: id,
        title: AIConversation.titleFrom(firstMessage),
        messages: List<AIMessage>.unmodifiable(_messages),
        createdAt: now,
        updatedAt: now,
        tag: AIConversation.tagFrom(firstMessage),
      ),
    );
  }

  void _saveActiveConversation() {
    final String? activeId = _activeConversationId;
    if (activeId == null) return;
    final int index = _conversations.indexWhere(
      (AIConversation conversation) => conversation.id == activeId,
    );
    if (index == -1) return;
    _conversations[index] = _conversations[index].copyWith(
      messages: _messages,
      updatedAt: DateTime.now(),
    );
  }

  String _lastUserMessage(List<AIMessage> messages) {
    for (final AIMessage message in messages.reversed) {
      if (message.isUser) return message.text;
    }
    return '';
  }

  /// 把流式缓冲落定为一条正式消息。返回落定的消息；无内容时返回 `null`。
  AIMessage? _settle({
    required String? buffer,
    required String id,
    required DateTime? createdAt,
  }) {
    _streaming = null;
    final String text = buffer ?? '';
    if (text.isEmpty) return null;

    final AIMessage message = AIMessage(
      id: id,
      text: text,
      isUser: false,
      createdAt: createdAt ?? DateTime.now(),
    );
    _messages.add(message);
    return message;
  }
}
