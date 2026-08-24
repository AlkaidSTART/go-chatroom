import 'package:flutter/material.dart';
import 'package:flutter_boring_avatars/flutter_boring_avatars.dart';

class BreathingAvatar extends StatefulWidget {
  const BreathingAvatar({
    super.key,
    required this.name,
    this.type = BoringAvatarType.beam,
    this.size = 40,
    this.glowColor = const Color(0xFF7CC7F2),
  });

  final String name;
  final BoringAvatarType type;
  final double size;
  final Color glowColor;

  @override
  State<BreathingAvatar> createState() => _BreathingAvatarState();
}

class _BreathingAvatarState extends State<BreathingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween<double>(
    begin: 0.96,
    end: 1.05,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  late final Animation<double> _glow = Tween<double>(
    begin: 0.18,
    end: 0.48,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: _glow.value),
                  blurRadius: widget.size * 0.38,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: BoringAvatar(
                  name: widget.name,
                  type: widget.type,
                  shape: const OvalBorder(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
