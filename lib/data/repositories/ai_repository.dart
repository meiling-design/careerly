import '../models/ai_chat.dart';

/// AI 数据访问接口。
///
/// ## 为什么返回 `Stream` 而不是 `Future<AIMessage>`
///
/// 后端 `POST /api/v1/ai/messages` 是 **SSE 流式**接口（2026-10-03 P-AI-1）：
/// 回答逐段下发，界面才能「边生成边显示」，而不是干等几秒后一次性弹出。
/// 因此这里返回事件流，而不是一个拿到就完整的消息对象。
///
/// ## 失败怎么表达
///
/// 只有一条路径：**抛出 `AppError`**。开流前的 403（额度耗尽）/
/// 404（项目不存在）/ 503（AI 不可用）与流中途的 `error` 帧，
/// 都由实现统一转成抛出 —— 调用方写一个 `try/catch` 即可覆盖全部失败。
///
/// 流正常结束的依据是收到 [AIStreamDone]；**没有它就不算成功**
/// （后端正是在发出该帧之前才扣减额度）。
abstract interface class AIRepository {
  /// 发送一条消息，返回服务端回答的事件流。
  Stream<AIStreamEvent> sendMessage(AIRequest request);
}
