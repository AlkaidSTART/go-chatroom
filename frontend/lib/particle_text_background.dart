import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ParticleTextBackground extends StatefulWidget {
  const ParticleTextBackground({
    super.key,
    this.text = '微光',
    this.color = const Color(0xFF6E9DFF),
    this.particleCount = 520,
  });

  final String text;
  final Color color;
  final int particleCount;

  @override
  State<ParticleTextBackground> createState() => _ParticleTextBackgroundState();
}

class _ParticleTextBackgroundState extends State<ParticleTextBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  List<_Particle> _particles = const [];
  Size _sourceSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _generateParticles();
  }

  Future<void> _generateParticles() async {
    try {
      const source = Size(520, 210);
      const fontSize = 150.0;
      final builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          fontSize: fontSize,
          fontWeight: ui.FontWeight.w600,
          textAlign: ui.TextAlign.center,
        ),
      )..addText(widget.text);
      final paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: source.width));

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawParagraph(
        paragraph,
        Offset(
          (source.width - paragraph.width) / 2,
          (source.height - paragraph.height) / 2,
        ),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        source.width.toInt(),
        source.height.toInt(),
      );
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      image.dispose();
      picture.dispose();
      if (byteData == null) {
        return;
      }

      final pixels = byteData.buffer.asUint8List();
      final sampled = <_Particle>[];
      const step = 2;
      for (var y = 0; y < source.height; y += step) {
        for (var x = 0; x < source.width; x += step) {
          final index = (y * source.width.toInt() + x) * 4;
          if (pixels[index + 3] > 60) {
            sampled.add(
              _Particle(
                targetX: x.toDouble(),
                targetY: y.toDouble(),
                radius: 0.8 + (x * 7 + y * 13) % 12 / 10,
                alpha: 0.28 + (x * 3 + y * 5) % 10 / 22,
                phase: (x * 17 + y * 29) % 100 / 100,
                drift: 1.2 + (x * 11 + y * 7) % 16 / 8,
              ),
            );
          }
        }
      }

      if (sampled.length > widget.particleCount) {
        final stride = sampled.length ~/ widget.particleCount;
        _particles = [
          for (var index = 0; index < sampled.length; index += stride)
            sampled[index],
        ];
        if (_particles.length > widget.particleCount) {
          _particles = _particles.sublist(0, widget.particleCount);
        }
      } else {
        _particles = sampled;
      }
      _sourceSize = source;
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticleTextPainter(
              particles: _particles,
              sourceSize: _sourceSize,
              progress: _controller.value,
              color: widget.color,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.targetX,
    required this.targetY,
    required this.radius,
    required this.alpha,
    required this.phase,
    required this.drift,
  });

  final double targetX;
  final double targetY;
  final double radius;
  final double alpha;
  final double phase;
  final double drift;
}

class _ParticleTextPainter extends CustomPainter {
  const _ParticleTextPainter({
    required this.particles,
    required this.sourceSize,
    required this.progress,
    required this.color,
  });

  final List<_Particle> particles;
  final Size sourceSize;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty || sourceSize.isEmpty) {
      return;
    }

    final scale = math.min(
      size.width / sourceSize.width,
      size.height / sourceSize.height,
    );
    final offsetX = (size.width - sourceSize.width * scale) / 2;
    final offsetY = (size.height - sourceSize.height * scale) / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final phase = progress * math.pi * 2 + particle.phase * math.pi * 2;
      final dx = math.sin(phase * particle.drift) * 1.4;
      final dy = math.cos(phase * 0.7 + particle.phase * math.pi) * 1.2;
      final breath = 0.5 + 0.5 * math.sin(phase + particle.phase * math.pi * 2);
      paint.color = color.withValues(alpha: particle.alpha * breath);
      canvas.drawCircle(
        Offset(
          offsetX + (particle.targetX + dx) * scale,
          offsetY + (particle.targetY + dy) * scale,
        ),
        particle.radius * scale * 0.8,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleTextPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles ||
        oldDelegate.sourceSize != sourceSize ||
        oldDelegate.color != color;
  }
}
