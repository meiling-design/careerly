import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/state/state.dart';
import '../../../data/models/ai_chat.dart';
import '../../../data/models/ai_message.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/ai_provider.dart';
import 'widgets/ai_copilot_character.dart';
import 'widgets/ai_markdown_text.dart';

const LinearGradient _aiChatGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[Color(0xFF5B7CFA), Color(0xFF9B5DE5)],
);

/// AI Chat UI aligned with the Figma welcome and conversation states.
class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final TextEditingController _controller = TextEditingController();
  bool _historyOpen = false;

  static const List<String> _suggestions = <String>[
    '帮我解释最近一次岗位分析结果',
    '我和目标岗位的主要能力差距是什么？',
    '结合已有分析，建议我优先提升什么？',
    '帮我优化简历中的一段项目描述',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    final String message = text.trim();
    if (message.isEmpty) return;
    _controller.clear();
    setState(() {});
    await context.read<AIProvider>().sendMessage(message);
  }

  void _goHome() => context.go(AppRoutes.home);

  void _openHistory() => setState(() => _historyOpen = true);

  void _closeHistory() => setState(() => _historyOpen = false);

  void _startNewConversation() {
    context.read<AIProvider>().startNewConversation();
    _closeHistory();
  }

  void _selectConversation(String conversationId) {
    context.read<AIProvider>().selectConversation(conversationId);
    _closeHistory();
  }

  @override
  Widget build(BuildContext context) {
    final AIProvider provider = context.watch<AIProvider>();
    final AICopilotMotionState copilotState = !provider.isLoading
        ? AICopilotMotionState.idle
        : provider.streamingMessage == null
        ? AICopilotMotionState.thinking
        : AICopilotMotionState.responding;
    final String? completionId = provider.responseState.dataOrNull?.id;
    final bool hasConversation =
        provider.messages.isNotEmpty || provider.streamingMessage != null;

    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: hasConversation
                ? Column(
                    children: <Widget>[
                      _AIHeader(
                        welcome: false,
                        onBack: _startNewConversation,
                        onHistory: _openHistory,
                      ),
                      const _ConversationContext(),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          children: <Widget>[
                            for (final AIMessage message in provider.messages)
                              _MessageBubble(message: message),
                            if (provider.streamingMessage != null)
                              _MessageBubble(
                                message: provider.streamingMessage!,
                              ),
                            if (provider.isLoading &&
                                provider.streamingMessage == null)
                              const _TypingIndicator(),
                            if (provider.responseState
                                case AsyncFailure<AIMessage>())
                              _RetryMessage(onRetry: provider.retryLastMessage),
                          ],
                        ),
                      ),
                      _AIInput(
                        controller: _controller,
                        enabled: !provider.isLoading,
                        onChanged: (_) => setState(() {}),
                        onSend: () => _sendMessage(_controller.text),
                        copilotState: copilotState,
                        completionId: completionId,
                      ),
                    ],
                  )
                : Stack(
                    children: <Widget>[
                      Positioned.fill(
                        top: 44,
                        child: _WelcomePanel(
                          suggestions: _suggestions,
                          onSelect: _sendMessage,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _AIHeader(
                          welcome: true,
                          onBack: _goHome,
                          onHistory: _openHistory,
                        ),
                      ),
                      Positioned(
                        left: 33,
                        right: 33,
                        bottom: 0,
                        child: _AIInput(
                          controller: _controller,
                          enabled: !provider.isLoading,
                          welcome: true,
                          onChanged: (_) => setState(() {}),
                          onSend: () => _sendMessage(_controller.text),
                          copilotState: copilotState,
                          completionId: completionId,
                        ),
                      ),
                    ],
                  ),
          ),
          _AIHistoryDrawer(
            isOpen: _historyOpen,
            conversations: provider.conversations,
            activeConversationId: provider.activeConversationId,
            enabled: !provider.isLoading,
            onClose: _closeHistory,
            onNewConversation: _startNewConversation,
            onSelect: _selectConversation,
          ),
        ],
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.suggestions, required this.onSelect});

  final List<String> suggestions;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x94FFFFFF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xD1FFFFFF), width: 1.2),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x295B7CFA),
                  blurRadius: 40,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xE6FFFFFF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  children: <Widget>[
                    const _Welcome(),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      color: const Color(0x1A635BDB),
                    ),
                    const _SuggestionHeading(),
                    const SizedBox(height: 12),
                    for (int i = 0; i < suggestions.length; i++) ...<Widget>[
                      _SuggestionCard(
                        text: suggestions[i],
                        onTap: () => onSelect(suggestions[i]),
                      ),
                      if (i < suggestions.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AIMessage message;

  @override
  Widget build(BuildContext context) {
    final BorderRadius userRadius = BorderRadius.circular(
      18,
    ).copyWith(topRight: const Radius.circular(4));
    final BorderRadius assistantRadius = BorderRadius.circular(
      18,
    ).copyWith(topLeft: const Radius.circular(4));
    final TextStyle bubbleTextStyle = AppTypography.bodySmall.copyWith(
      fontSize: 13,
      height: 20 / 13,
      color: message.isUser ? Colors.white : AppColors.textPrimary,
    );
    final Widget bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.76,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: message.isUser ? null : const Color(0xCCFFFFFF),
        gradient: message.isUser ? _aiChatGradient : null,
        borderRadius: message.isUser ? userRadius : assistantRadius,
        border: message.isUser
            ? null
            : Border.all(color: const Color(0xB3FFFFFF)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: message.isUser
                ? const Color(0x4D5B7CFA)
                : const Color(0x145B7CFA),
            blurRadius: message.isUser ? 16 : 12,
            offset: Offset(0, message.isUser ? 4 : 2),
          ),
        ],
      ),
      // 用户自己敲的字按纯文本显示；AI 的回答是 Markdown，走
      // [AiMarkdownText] 渲染 —— 否则 `**粗体**`、`* 列表` 的记号
      // 会原样打到屏幕上。
      child: message.isUser
          ? Text(message.text, style: bubbleTextStyle)
          : AiMarkdownText(text: message.text, style: bubbleTextStyle),
    );

    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Align(alignment: Alignment.centerRight, child: bubble),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          const _AssistantAvatar(),
          const SizedBox(width: 10),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: _aiChatGradient,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x595B7CFA),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '∞',
        style: AppTypography.body.copyWith(
          fontSize: 16,
          height: 1,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _AssistantAvatar(),
          SizedBox(width: 10),
          Text('AI 正在思考…', style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _RetryMessage extends StatelessWidget {
  const _RetryMessage({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh, size: 16),
        label: const Text('回复失败，重试'),
      ),
    );
  }
}

class _AIHeader extends StatelessWidget {
  const _AIHeader({
    required this.welcome,
    required this.onBack,
    required this.onHistory,
  });

  final bool welcome;
  final VoidCallback onBack;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final double buttonSize = welcome ? 44 : 36;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _HeaderButton(
            icon: Icons.arrow_back_rounded,
            tooltip: '返回',
            size: buttonSize,
            welcome: welcome,
            onPressed: onBack,
          ),
          Column(
            children: <Widget>[
              Text(
                'Career Copilot',
                style: AppTypography.label.copyWith(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF171827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'AI 职业顾问',
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  height: 16.5 / 11,
                  color: const Color(0xFF626579),
                ),
              ),
            ],
          ),
          _HeaderButton(
            icon: Icons.view_sidebar_outlined,
            tooltip: '聊天记录',
            size: buttonSize,
            welcome: welcome,
            onPressed: onHistory,
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.size,
    required this.welcome,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final double size;
  final bool welcome;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: welcome ? const Color(0xFF0088FF) : const Color(0xFF635BDB),
        ),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0x73FFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: welcome ? AppRadius.borderPill : AppRadius.borderMd,
          ),
          side: const BorderSide(color: Color(0xB3FFFFFF), width: 1.2),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        tooltip: tooltip,
      ),
    );
  }
}

class _ConversationContext extends StatelessWidget {
  const _ConversationContext();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0x125B7CFA),
            border: Border.all(color: const Color(0x1F5B7CFA)),
            borderRadius: AppRadius.borderPill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.auto_awesome,
                size: 13,
                color: Color(0xFF5B7CFA),
              ),
              const SizedBox(width: 8),
              Text(
                '有分析时参考最近一次分析；否则提供通用建议',
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF5B7CFA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF5B7CFA),
                Color(0xFF9B5DE5),
                Color(0xFFC084FC),
              ],
              stops: <double>[0, 0.6, 1],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(color: Color(0x965B66F1), blurRadius: 36.8),
            ],
          ),
          // 对应 Figma `AI` 欢迎态的 88px 渐变圆：
          // 标志不是居中缩小的，而是 **150×100 的白色字标故意越界裁切**
          // （Figma: left -31 / top -6 / opacity 0.94）。
          child: ClipOval(
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  left: -31,
                  top: -6,
                  width: 150,
                  height: 100,
                  child: Opacity(
                    opacity: 0.94,
                    child: SvgPicture.asset(
                      'assets/images/brand/careerly-logo.svg',
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '你好，今天想聊些什么？',
          textAlign: TextAlign.center,
          style: AppTypography.bodyStrong.copyWith(
            fontSize: 16,
            height: 24 / 16,
            color: const Color(0xFF171827),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '我是你的 AI 职业顾问，可以帮你分析岗位、优化简历、制定求职策略。',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 12,
            height: 19.5 / 12,
            color: const Color(0xFF626579),
          ),
        ),
      ],
    );
  }
}

class _SuggestionHeading extends StatelessWidget {
  const _SuggestionHeading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        '你可以问我',
        style: AppTypography.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xB3FFFFFF),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x245B7CFA), width: 1.2),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0D635BDB),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0x195B7CFA), Color(0x199B5DE5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_outward_rounded,
                  size: 12,
                  color: Color(0xFF635BDB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF171827),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AIInput extends StatelessWidget {
  const _AIInput({
    required this.controller,
    required this.enabled,
    required this.onChanged,
    required this.onSend,
    required this.copilotState,
    required this.completionId,
    this.welcome = false,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final AICopilotMotionState copilotState;
  final String? completionId;
  final bool welcome;

  @override
  Widget build(BuildContext context) {
    final bool hasText = controller.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(welcome ? 0 : 33, 0, welcome ? 0 : 33, 0),
      child: SizedBox(
        height: 62,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: 25,
              top: -68,
              child: AICopilotCharacter(
                state: copilotState,
                completionId: completionId,
                welcome: welcome,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xB8FFFFFF),
                borderRadius: AppRadius.borderPill,
                border: Border.all(color: const Color(0xE0FFFFFF), width: 1.2),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x215B7CFA),
                    blurRadius: 24,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  if (welcome) ...<Widget>[
                    const Icon(Icons.add, size: 24, color: Color(0xFFD3CEF4)),
                    Container(
                      height: 24,
                      width: 1,
                      margin: const EdgeInsets.only(left: 8, right: 12),
                      color: const Color(0x80D3CEF4),
                    ),
                  ] else ...<Widget>[
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0x14635BDB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '∞',
                        style: AppTypography.body.copyWith(
                          color: const Color(0xFF635BDB),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: TextField(
                      enabled: enabled,
                      controller: controller,
                      onChanged: onChanged,
                      onSubmitted: (_) => onSend(),
                      textInputAction: TextInputAction.done,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: '输入你想问的问题...',
                        hintStyle: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: hasText && enabled ? onSend : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: hasText ? _aiChatGradient : null,
                        color: hasText ? null : const Color(0x19635BDB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: 16,
                        color: hasText && enabled
                            ? Colors.white
                            : const Color(0x66635BDB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIHistoryDrawer extends StatelessWidget {
  const _AIHistoryDrawer({
    required this.isOpen,
    required this.conversations,
    required this.activeConversationId,
    required this.enabled,
    required this.onClose,
    required this.onNewConversation,
    required this.onSelect,
  });

  final bool isOpen;
  final List<AIConversation> conversations;
  final String? activeConversationId;
  final bool enabled;
  final VoidCallback onClose;
  final VoidCallback onNewConversation;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final double panelWidth = MediaQuery.sizeOf(context).width * 0.78;
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isOpen,
            child: AnimatedOpacity(
              opacity: isOpen ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: const ColoredBox(color: Color(0x4D000000)),
                ),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: const Cubic(0.32, 0.72, 0, 1),
          top: 0,
          bottom: 0,
          right: isOpen ? 0 : -panelWidth,
          width: panelWidth,
          child: Semantics(
            label: '聊天记录',
            hidden: !isOpen,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Color(0xF7E6EBFF), Color(0xF7F0E6FF)],
                    ),
                    border: Border(
                      left: BorderSide(color: Color(0xB3FFFFFF), width: 1),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0x2E5B7CFA),
                        blurRadius: 40,
                        offset: Offset(-8, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      _HistoryHeader(onClose: onClose),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _NewConversationButton(
                          enabled: enabled,
                          onPressed: onNewConversation,
                        ),
                      ),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: const Color(0x1A635BDB),
                      ),
                      Expanded(
                        child: conversations.isEmpty
                            ? const _EmptyHistory()
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  12,
                                  12,
                                  20,
                                ),
                                itemCount: conversations.length,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(height: 8),
                                itemBuilder: (BuildContext context, int index) {
                                  final AIConversation conversation =
                                      conversations[index];
                                  return _ConversationCard(
                                    key: ValueKey<String>(
                                      'ai-history-${conversation.id}',
                                    ),
                                    conversation: conversation,
                                    selected:
                                        conversation.id == activeConversationId,
                                    enabled: enabled,
                                    onTap: () => onSelect(conversation.id),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '聊天记录',
              style: AppTypography.label.copyWith(
                fontSize: 15,
                height: 20 / 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF171827),
              ),
            ),
          ),
          SizedBox(
            width: 30,
            height: 30,
            child: IconButton(
              onPressed: onClose,
              tooltip: '关闭聊天记录',
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0x1A635BDB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Color(0xFF635BDB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewConversationButton extends StatelessWidget {
  const _NewConversationButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? _aiChatGradient : null,
          color: enabled ? null : const Color(0x80635BDB),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x4D5B7CFA),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(14),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add_rounded, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  '新建对话',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0x1A635BDB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.forum_outlined,
                size: 24,
                color: Color(0xFF635BDB),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '暂无聊天记录',
              style: AppTypography.label.copyWith(
                color: const Color(0xFF171827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '开始一段新对话后，会显示在这里',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    super.key,
    required this.conversation,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final AIConversation conversation;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  static Color _colorForTag(String tag) {
    if (RegExp(r'^\d{1,3}%$').hasMatch(tag)) {
      return const Color(0xFF4F7EF5);
    }
    return switch (tag) {
      '简历' => const Color(0xFF34C759),
      '能力' => const Color(0xFFFF9500),
      _ => const Color(0xFF635BDB),
    };
  }

  static String _dateLabel(DateTime date) {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final DateTime day = DateUtils.dateOnly(date);
    if (day == today) return '今天';
    if (day == today.subtract(const Duration(days: 1))) return '昨天';
    return '${date.month}月${date.day}日';
  }

  @override
  Widget build(BuildContext context) {
    final Color tagColor = _colorForTag(conversation.tag);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0x1A5B7CFA) : const Color(0x99FFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0x2E5B7CFA)
                  : const Color(0xCCFFFFFF),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(top: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0x265B7CFA)
                      : const Color(0x14635BDB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 15,
                  color: Color(0xFF635BDB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            conversation.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF171827),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _dateLabel(conversation.updatedAt),
                          style: AppTypography.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      conversation.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.09),
                        borderRadius: AppRadius.borderPill,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 1,
                        ),
                        child: Text(
                          conversation.tag,
                          style: AppTypography.caption.copyWith(
                            fontSize: 10,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: tagColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
