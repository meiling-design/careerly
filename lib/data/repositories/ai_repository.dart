import '../models/ai_message.dart';

/// AI 数据访问接口。
///
/// Phase 7 当前只提供 Mock 实现；职业上下文与真实 API 留到后续步骤。
abstract interface class AIRepository {
  Future<AIMessage> sendMessage(String message);
}
