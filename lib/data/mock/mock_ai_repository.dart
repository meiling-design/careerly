import '../models/ai_message.dart';
import '../repositories/ai_repository.dart';
import 'mock_config.dart';

/// AI Repository 的 Mock 实现。
///
/// 不读取简历、岗位或 Career Context，避免在 Context 阶段之前伪造个性化结论。
class MockAIRepository implements AIRepository {
  MockAIRepository({MockConfig? config}) : _config = config ?? MockSettings.config;

  final MockConfig _config;
  int _sequence = 0;

  @override
  Future<AIMessage> sendMessage(String message) async {
    await _config.simulate();
    _sequence += 1;
    return AIMessage(
      id: 'mock-ai-$_sequence',
      isUser: false,
      text: '这是 Mock 回复。接入职业上下文后，我会结合你的简历、目标岗位和能力 Gap 给出更具体的建议。',
      createdAt: DateTime.now(),
    );
  }
}
