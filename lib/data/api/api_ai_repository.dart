import '../models/ai_chat.dart';
import '../repositories/ai_repository.dart';
import 'api_client.dart';

/// AI 数据访问的**真实后端**实现。
///
/// ```text
/// AIProvider
///   ↓
/// ApiAiRepository          ← 本文件：SSE 帧 → 领域事件
///   ↓
/// ApiClient.postSse        ← 传输层：SSE 分帧 + 错误归一化
///   ↓
/// POST /api/v1/ai/messages
/// ```
///
/// 契约来源：`docs/careerly/BACKEND_API_CONTRACT.md` §0.5.8。
class ApiAiRepository implements AIRepository {
  ApiAiRepository(this._client);

  final ApiClient _client;

  static const String _path = '/api/v1/ai/messages';

  @override
  Stream<AIStreamEvent> sendMessage(AIRequest request) async* {
    await for (final Map<String, dynamic> frame
        in _client.postSse(_path, body: request.toJson())) {
      switch (frame['type']) {
        case 'start':
          yield const AIStreamStarted();

        case 'delta':
          final Object? text = frame['text'];
          // 空 delta 不往上传：界面没必要为它重建一次。
          if (text is String && text.isNotEmpty) yield AIStreamDelta(text);

        case 'done':
          yield const AIStreamDone();
          // 显式收流。`await for` 里的 return 会取消对底层 socket 的订阅，
          // 不至于因为服务端还挂着连接而让界面停在「还在生成」。
          return;

        // `error` 帧到不了这里 —— ApiClient.postSse 已把它转成抛出的
        // AppError。未知 type 同样跳过：后端将来加帧不该让旧客户端崩。
      }
    }
  }
}
