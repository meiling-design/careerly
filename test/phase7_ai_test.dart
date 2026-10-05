import 'dart:convert';

import 'package:careerly/core/errors/app_error.dart';
import 'package:careerly/data/api/api_client.dart';
import 'package:careerly/data/mock/mock_ai_repository.dart';
import 'package:careerly/data/mock/mock_config.dart';
import 'package:careerly/data/models/ai_chat.dart';
import 'package:careerly/data/models/ai_message.dart';
import 'package:careerly/data/repositories/ai_repository.dart';
import 'package:careerly/features/ai/state/ai_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// 不拖慢用例的 Mock 装配。
MockAIRepository _mock({MockConfig? config}) => MockAIRepository(
  config: config ?? const MockConfig(latency: Duration.zero),
  chunkInterval: Duration.zero,
);

void main() {
  group('AIProvider × Mock', () {
    test('发送消息后收到 Mock 回复', () async {
      final AIProvider provider = AIProvider(_mock());

      await provider.sendMessage('我目前最需要提升什么能力？');

      expect(provider.messages, hasLength(2));
      expect(provider.messages.first.isUser, isTrue);
      expect(provider.messages.last.isUser, isFalse);
      expect(provider.messages.last.text, contains('Mock 回复'));
      expect(provider.isLoading, isFalse);
      // 落定后不该再有「正在生成」的影子消息。
      expect(provider.streamingMessage, isNull);
    });

    test('空消息不会创建对话', () async {
      final AIProvider provider = AIProvider(_mock());

      await provider.sendMessage('   ');

      expect(provider.messages, isEmpty);
    });

    test('回答是分帧到达的 —— 中途能读到半句，且已落定的消息列表不含它', () async {
      final AIProvider provider = AIProvider(_mock());
      final List<String> seen = <String>[];

      provider.addListener(() {
        final AIMessage? live = provider.streamingMessage;
        if (live != null) seen.add(live.text);
      });

      await provider.sendMessage('你好');

      // 收到过至少一次「还没写完」的中间态。
      expect(seen.length, greaterThan(1));
      expect(seen.first.length, lessThan(seen.last.length));
      // 中间态只存在于 streamingMessage，不污染已落定的对话。
      expect(provider.messages, hasLength(2));
    });

    test('失败后半句仍留在对话里，并给出可重试的错误', () async {
      final AIProvider provider = AIProvider(
        _mock(config: const MockConfig(latency: Duration.zero, failNext: true)),
      );

      await provider.sendMessage('你好');

      expect(provider.isLoading, isFalse);
      expect(provider.responseState.isFailure, isTrue);
      // 只有用户那条 —— 一次 delta 都没收到，没有半句可留。
      expect(provider.messages, hasLength(1));
      expect(provider.messages.single.isUser, isTrue);
    });

    test('向后端回传的历史不含本轮提问', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final AIProvider provider = AIProvider(repository);

      await provider.sendMessage('第一问');
      await provider.sendMessage('第二问');

      expect(repository.requests, hasLength(2));
      // 第一轮：没有任何上文。
      expect(repository.requests.first.history, isEmpty);
      // 第二轮：带上一轮的「问题 + 回答」，但**不含**本轮问题。
      expect(repository.requests.last.message, '第二问');
      expect(repository.requests.last.history, hasLength(2));
      expect(repository.requests.last.history.first.text, '第一问');
      expect(repository.requests.last.history.last.isUser, isFalse);
    });

    test('会话可新建、出现在历史中并恢复完整消息', () async {
      final AIProvider provider = AIProvider(_mock());

      await provider.sendMessage('帮我优化简历');
      final AIConversation first = provider.conversations.single;
      expect(first.title, '帮我优化简历');
      expect(first.tag, '简历');
      expect(first.messages, hasLength(2));

      provider.startNewConversation();
      expect(provider.messages, isEmpty);
      expect(provider.activeConversationId, isNull);
      expect(provider.conversations, hasLength(1));

      await provider.sendMessage('下一步我应该做什么？');
      expect(provider.conversations, hasLength(2));
      expect(provider.conversations.first.title, '下一步我应该做什么？');

      provider.selectConversation(first.id);
      expect(provider.activeConversationId, first.id);
      expect(provider.messages, hasLength(2));
      expect(provider.messages.first.text, '帮我优化简历');
      expect(provider.messages.last.isUser, isFalse);

      provider.startNewConversation();
      expect(provider.messages, isEmpty);
      expect(provider.conversations, hasLength(2));
    });
  });

  group('ApiClient.postSse', () {
    test('逐帧解析 start / delta / done', () async {
      final ApiClient client = ApiClient(
        baseUrl: 'http://test.local',
        httpClient: MockClient.streaming((http.BaseRequest request, _) async {
          return http.StreamedResponse(
            Stream<List<int>>.fromIterable(<List<int>>[
              // 故意在**一个多字节汉字中间**切断，验证 UTF-8 跨块解码。
              ..._split('data: {"type":"start"}\n\n'),
              ..._split('data: {"type":"delta","text":"你'),
              ..._split('好"}\n\ndata: {"type":"delta","text":"，世界"}\n\n'),
              ..._split('data: {"type":"done"}\n\n'),
            ]),
            200,
          );
        }),
      );

      final List<Map<String, dynamic>> frames = await client
          .postSse('/api/v1/ai/messages')
          .toList();

      expect(frames.map((Map<String, dynamic> f) => f['type']), <String>[
        'start',
        'delta',
        'delta',
        'done',
      ]);
      expect(frames[1]['text'], '你好');
      expect(frames[2]['text'], '，世界');
    });

    test('开流前的 403 AI_QUOTA_EXCEEDED 抛 QuotaError', () async {
      final ApiClient client = ApiClient(
        baseUrl: 'http://test.local',
        httpClient: MockClient((http.Request request) async {
          return http.Response(
            '{"success":false,"data":null,"error":{"code":"AI_QUOTA_EXCEEDED",'
            '"message":"AI 对话次数已用完","details":{"quota":'
            '{"total":50,"used":50,"isMember":false}}},"meta":{}}',
            403,
            // 不带 charset 时 http 包按 latin1 编码，中文会直接抛
            // ArgumentError —— 真实后端发的是 utf-8 JSON。
            headers: const <String, String>{
              'content-type': 'application/json; charset=utf-8',
            },
          );
        }),
      );

      await expectLater(
        client.postSse('/api/v1/ai/messages').toList(),
        throwsA(
          isA<QuotaError>()
              .having((QuotaError e) => e.remaining, 'remaining', 0)
              .having((QuotaError e) => e.isRetryable, 'isRetryable', isFalse),
        ),
      );
    });

    test('流中途的 error 帧抛 AIError（与开流前的失败同一条路径）', () async {
      final ApiClient client = ApiClient(
        baseUrl: 'http://test.local',
        httpClient: MockClient.streaming((http.BaseRequest request, _) async {
          return http.StreamedResponse(
            Stream<List<int>>.fromIterable(<List<int>>[
              ..._split('data: {"type":"start"}\n\n'),
              ..._split('data: {"type":"delta","text":"前半句"}\n\n'),
              ..._split(
                'data: {"type":"error","code":"AI_FAILED","message":"AI 回复中断"}\n\n',
              ),
            ]),
            200,
          );
        }),
      );

      await expectLater(
        client.postSse('/api/v1/ai/messages').toList(),
        throwsA(
          isA<AIError>().having((AIError e) => e.message, 'message', 'AI 回复中断'),
        ),
      );
    });
  });
}

/// 逐字节下发，用来制造真实的跨块边界（含多字节汉字被切开的情况）。
List<List<int>> _split(String text) => <List<int>>[
  for (final int byte in utf8.encode(text)) <int>[byte],
];

/// 记录每次请求、按脚本分帧回复的假 Repository。
class _RecordingRepository implements AIRepository {
  final List<AIRequest> requests = <AIRequest>[];

  @override
  Stream<AIStreamEvent> sendMessage(AIRequest request) async* {
    requests.add(request);
    yield const AIStreamStarted();
    yield const AIStreamDelta('好的');
    yield const AIStreamDone();
  }
}
