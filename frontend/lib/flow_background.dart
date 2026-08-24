import 'dart:math' as math;

import 'package:flutter/material.dart';

class FlowBackground extends StatelessWidget {
  const FlowBackground({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _FlowPainter(animation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _FlowPainter extends CustomPainter {
  _FlowPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      Color(0xFFBFE3FF),
      Color(0xFFB8E6DD),
      Color(0xFFFFD9E3),
      Color(0xFFE2D4FF),
    ];

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (var index = 0; index < colors.length; index++) {
      final phase = progress * math.pi * 2 + index * 1.7;
      final baseY = size.height * (0.2 + index * 0.19);
      final amplitude = size.height * 0.07;
      final step = math.max(6.0, size.width / 64);

      final wavePath = Path()..moveTo(-20, baseY);
      for (var x = -20.0; x <= size.width + 20; x += step) {
        final wave = math.sin((x / size.width) * math.pi * 2 + phase);
        wavePath.lineTo(x, baseY + wave * amplitude);
      }

      final ribbonPath = Path.from(wavePath)
        ..lineTo(size.width + 20, baseY + amplitude * 2.6)
        ..lineTo(-20, baseY + amplitude * 2.6)
        ..close();

      fillPaint
        ..color = colors[index].withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      strokePaint.color = colors[index].withValues(alpha: 0.34);
      canvas.drawPath(ribbonPath, fillPaint);
      canvas.drawPath(wavePath, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
