import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/state.dart';
import '../../../data/models/ai_message.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/ai_provider.dart';

/// AI Chat UI（Phase 7 · 第一步）。
///
/// 当前只实现 Figma 的空会话界面与输入交互。
/// Mock Response、Career Context、真实 API 与会话历史均留到后续步骤。
class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final TextEditingController _controller = TextEditingController();

  static const List<String> _suggestions = <String>[
    '为什么这个岗位匹配度只有 82%？',
    '帮我优化这个项目的描述',
    '我目前最需要提升什么能力？',
    '下一步我应该做什么？',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectSuggestion(String value) {
    _controller
      ..text = value
      ..selection = TextSelection.collapsed(offset: value.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AIProvider provider = context.watch<AIProvider>();
    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          const _AIHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: <Widget>[
                if (provider.messages.isEmpty) ...<Widget>[
                  const _Welcome(),
                  const SizedBox(height: 20),
                  const _SuggestionHeading(),
                  const SizedBox(height: 12),
                  for (final String suggestion in _suggestions) ...<Widget>[
                    _SuggestionCard(
                      text: suggestion,
                      onTap: () => _selectSuggestion(suggestion),
                    ),
                    const SizedBox(height: 10),
                  ],
                ] else ...<Widget>[
                  for (final AIMessage message in provider.messages)
                    _MessageBubble(message: message),
                  if (provider.isLoading)
                    const _TypingIndicator(),
                  if (provider.responseState case AsyncFailure<AIMessage>())
                    _RetryMessage(onRetry: provider.retryLastMessage),
                ],
              ],
            ),
          ),
          _AIInput(
            controller: _controller,
            enabled: !provider.isLoading,
            onChanged: (_) => setState(() {}),
            onSend: () async {
              final String text = _controller.text;
              _controller.clear();
              setState(() {});
              await context.read<AIProvider>().sendMessage(text);
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AIMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primaryBlue : AppColors.glassFill,
          borderRadius: BorderRadius.only(
            topLeft: AppRadius.borderMd.topLeft,
            topRight: AppRadius.borderMd.topRight,
            bottomLeft: Radius.circular(message.isUser ? 14 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 14),
          ),
          border: message.isUser
              ? null
              : Border.all(color: const Color(0x245B7CFA), width: 1.2),
        ),
        child: Text(
          message.text,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 12,
            color: message.isUser ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text('AI 正在思考…', style: AppTypography.caption),
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
  const _AIHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const _HeaderButton(icon: Icons.close, tooltip: '关闭'),
          Column(
            children: <Widget>[
              Text('Career Copilot', style: AppTypography.label.copyWith(fontSize: 14)),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF00BC7D), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text('AI 职业顾问 · 在线', style: AppTypography.caption),
                ],
              ),
            ],
          ),
          const _HeaderButton(icon: Icons.view_sidebar_outlined, tooltip: '对话面板'),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.tooltip});

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: AppColors.primaryPurple),
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.glassFillLight,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        side: const BorderSide(color: AppColors.glassBorder, width: 1.2),
      ),
      tooltip: tooltip,
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
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF5B7CFA), Color(0xFF9B5DE5), Color(0xFFC084FC)],
            ),
            boxShadow: <BoxShadow>[BoxShadow(color: Color(0x965B66F1), blurRadius: 36.8)],
          ),
          child: Text('✦', style: AppTypography.navAiGlyph.copyWith(fontSize: 34, color: Colors.white)),
        ),
        const SizedBox(height: 16),
        Text('我是你的 AI 职业顾问', textAlign: TextAlign.center, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Text('可以帮你分析岗位、优化简历、制定求职策略。', textAlign: TextAlign.center, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _SuggestionHeading extends StatelessWidget {
  const _SuggestionHeading();

  @override
  Widget build(BuildContext context) {
    return Text(
      '你可以问我',
      style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 0.3),
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
      color: AppColors.glassFill,
      borderRadius: AppRadius.borderMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: const Color(0x245B7CFA), width: 1.2),
            boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x0D635BDB), blurRadius: 10, offset: Offset(0, 2))],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: <Color>[Color(0x195B7CFA), Color(0x199B5DE5)]),
                  borderRadius: AppRadius.borderMd,
                ),
                child: const Icon(Icons.auto_awesome_outlined, size: 14, color: Color(0xFF635BDB)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: AppTypography.bodySmall.copyWith(fontSize: 12, color: AppColors.textPrimary))),
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
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final bool hasText = controller.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(33, 0, 33, 112),
      child: Container(
        height: 62,
        padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
        decoration: BoxDecoration(
          color: const Color(0xB8FFFFFF),
          borderRadius: AppRadius.borderPill,
          border: Border.all(color: const Color(0xE0FFFFFF), width: 1.2),
          boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x215B7CFA), blurRadius: 24, offset: Offset(0, 4))],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.primaryPurpleSurface, borderRadius: AppRadius.borderMd),
              child: Text('∞', style: AppTypography.body.copyWith(color: const Color(0xFF635BDB), fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                enabled: enabled,
                controller: controller,
                onChanged: onChanged,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.done,
                style: AppTypography.bodySmall.copyWith(fontSize: 12, color: AppColors.textPrimary),
                decoration: InputDecoration.collapsed(
                  hintText: '输入你想问的问题...',
                  hintStyle: AppTypography.bodySmall.copyWith(fontSize: 12),
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
                gradient: hasText ? const LinearGradient(colors: <Color>[Color(0xFF5B7CFA), Color(0xFF9B5DE5)]) : null,
                color: hasText ? null : const Color(0x19635BDB),
                borderRadius: AppRadius.borderMd,
              ),
                child: Icon(Icons.send_rounded, size: 16, color: hasText && enabled ? Colors.white : const Color(0x66635BDB)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
