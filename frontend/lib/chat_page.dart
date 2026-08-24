import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_boring_avatars/flutter_boring_avatars.dart';

import 'breathing_avatar.dart';
import 'flow_background.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _flowController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm1',
      sender: '林澈',
      text: '早上好，今天的玻璃质感做得很轻。',
      time: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    ChatMessage(
      id: 'm2',
      sender: '我',
      text: '流动背景再慢一点，呼吸感会更舒服。',
      time: DateTime.now().subtract(const Duration(minutes: 9)),
      isMine: true,
    ),
    ChatMessage(
      id: 'm3',
      sender: 'Mia',
      text: '气泡边缘再透一点，就像浮在桌面上。',
      time: DateTime.now().subtract(const Duration(minutes: 6)),
    ),
  ];

  Timer? _replyTimer;
  int _replySeed = 0;

  @override
  void dispose() {
    _replyTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'mine-${DateTime.now().microsecondsSinceEpoch}',
          sender: '我',
          text: text,
          time: DateTime.now(),
          isMine: true,
        ),
      );
    });
    _inputController.clear();
    _scrollToEnd();
    _scheduleReply();
  }

  void _scheduleReply() {
    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) {
        return;
      }

      const replies = [
        '收到，这个节奏很稳。',
        '流动感刚刚好，不抢内容。',
        '继续发，我在看效果。',
        '嗯，玻璃气泡很舒服。',
      ];
      final reply = replies[_replySeed % replies.length];
      _replySeed++;

      setState(() {
        _messages.add(
          ChatMessage(
            id: 'reply-${DateTime.now().microsecondsSinceEpoch}',
            sender: 'Mia',
            text: reply,
            time: DateTime.now(),
          ),
        );
      });
      _scrollToEnd();
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEAF4FF),
                  Color(0xFFF3FBF8),
                  Color(0xFFFFF0EC),
                ],
              ),
            ),
          ),
          FlowBackground(animation: _flowController),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 12),
                      Expanded(child: _buildMessageList()),
                      const SizedBox(height: 12),
                      _buildInput(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const BreathingAvatar(
            name: '微光',
            type: BoringAvatarType.sunset,
            size: 42,
            glowColor: Color(0xFF9ED9FF),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '微光聊天室',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF17233B),
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    SizedBox(
                      width: 7,
                      height: 7,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF34C98B),
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '3 人在线',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('退出'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = (constraints.maxWidth * 0.72)
            .clamp(200.0, 480.0)
            .toDouble();
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            return _MessageTile(
              message: _messages[index],
              maxBubbleWidth: maxWidth,
            );
          },
        );
      },
    );
  }

  Widget _buildInput() {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(
                hintText: '输入消息',
                hintStyle: TextStyle(
                  color: Color(0x8A64748B),
                  fontSize: 14,
                  letterSpacing: 0,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFF7FB6FF), width: 1.2),
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: _send,
            tooltip: '发送',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFE6F2FF),
              foregroundColor: const Color(0xFF2F6FED),
              minimumSize: const Size.square(42),
            ),
            icon: const Icon(Icons.send_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
    this.isMine = false,
  });

  final String id;
  final String sender;
  final String text;
  final DateTime time;
  final bool isMine;
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.radius = 8,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x73FFFFFF), Color(0x33FFFFFF)],
            ),
            borderRadius: borderRadius,
            border: Border.all(color: const Color(0x66FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120D1B2A),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message, required this.maxBubbleWidth});

  final ChatMessage message;
  final double maxBubbleWidth;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final bubble = _MessageBubble(message: message, maxWidth: maxBubbleWidth);
    final avatar = BreathingAvatar(
      name: message.sender,
      type: _avatarTypeFor(message.sender),
      size: 38,
      glowColor: isMine ? const Color(0xFF9ED9FF) : const Color(0xFFFFC8D8),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: isMine
              ? [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                    child: bubble,
                  ),
                  const SizedBox(width: 10),
                  avatar,
                ]
              : [
                  avatar,
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                    child: bubble,
                  ),
                ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.maxWidth});

  final ChatMessage message;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    return Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (!isMine)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              message.sender,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                letterSpacing: 0,
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isMine
                      ? const [Color(0x59EAF4FF), Color(0x24EAF6FF)]
                      : const [Color(0x40FFFFFF), Color(0x14FFFFFF)],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x59FFFFFF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140D1B2A),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatTime(message.time),
          style: const TextStyle(
            fontSize: 10,
            color: Color(0x8A5B6472),
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

BoringAvatarType _avatarTypeFor(String name) {
  const types = [
    BoringAvatarType.beam,
    BoringAvatarType.marble,
    BoringAvatarType.sunset,
    BoringAvatarType.bauhaus,
    BoringAvatarType.ring,
    BoringAvatarType.pixel,
  ];

  var seed = 0;
  for (final unit in name.codeUnits) {
    seed += unit;
  }
  return types[seed % types.length];
}

String _formatTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
