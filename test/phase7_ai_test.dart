import 'package:careerly/data/mock/mock_ai_repository.dart';
import 'package:careerly/data/mock/mock_config.dart';
import 'package:careerly/features/ai/state/ai_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('发送消息后收到 Mock 回复', () async {
    final AIProvider provider = AIProvider(
      MockAIRepository(config: const MockConfig(latency: Duration.zero)),
    );

    await provider.sendMessage('我目前最需要提升什么能力？');

    expect(provider.messages, hasLength(2));
    expect(provider.messages.first.isUser, isTrue);
    expect(provider.messages.last.isUser, isFalse);
    expect(provider.messages.last.text, contains('Mock 回复'));
    expect(provider.isLoading, isFalse);
  });

  test('空消息不会创建对话', () async {
    final AIProvider provider = AIProvider(
      MockAIRepository(config: const MockConfig(latency: Duration.zero)),
    );

    await provider.sendMessage('   ');

    expect(provider.messages, isEmpty);
  });
}
