import 'dart:math';
import 'package:flutter/material.dart';
import '../constants.dart';

/// A floating-particle overlay that gives the display a living, deep-space feel.
/// Renders particles plus occasional shooting stars and pulsing orbs.
class ParticleOverlay extends StatefulWidget {
  const ParticleOverlay({super.key});

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  late final List<_ShootingStar> _shootingStars;
  final Random _rng = Random();
  int _frame = 0;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(
      AppConstants.particleCount,
      (_) => _Particle.random(_rng),
    );
    _shootingStars = List.generate(1, (_) => _ShootingStar.random(_rng));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )
      ..addListener(_tick)
      ..repeat();
  }

  void _tick() {
    _frame++;
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;

      // Pulsing opacity
      p.opacity = p.baseOpacity +
          sin(_frame * 0.02 + p.phase) * p.baseOpacity * 0.5;
      p.opacity = p.opacity.clamp(0.02, 0.5);

      // Wrap around
      if (p.x < -0.05) p.x = 1.05;
      if (p.x > 1.05) p.x = -0.05;
      if (p.y < -0.05) p.y = 1.05;
      if (p.y > 1.05) p.y = -0.05;
    }

    // Animate shooting stars
    for (final s in _shootingStars) {
      s.progress += s.speed;
      if (s.progress > 1.2) {
        // Respawn with delay
        s.delay--;
        if (s.delay <= 0) {
          final ns = _ShootingStar.random(_rng);
          s.startX = ns.startX;
          s.startY = ns.startY;
          s.endX = ns.endX;
          s.endY = ns.endY;
          s.progress = ns.progress;
          s.speed = ns.speed;
          s.delay = ns.delay;
          s.tailLength = ns.tailLength;
          s.color = ns.color;
        }
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
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ParticlePainter(_particles, _shootingStars, _controller),
        size: Size.infinite,
      ),
    );
  }
}

class _Particle {
  double x, y, vx, vy, radius, opacity, baseOpacity, phase;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.opacity,
    required this.baseOpacity,
    required this.phase,
    required this.color,
  });

  factory _Particle.random(Random rng) {
    const colors = [
      VividColors.electric,
      VividColors.neonPink,
      VividColors.cyan,
      VividColors.gold,
      VividColors.teal,
      VividColors.lavender,
      VividColors.coral,
      VividColors.emerald,
      VividColors.skyBlue,
    ];
    final baseOp = rng.nextDouble() * 0.3 + 0.05;
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      vx: (rng.nextDouble() - 0.5) * 0.0002,
      vy: (rng.nextDouble() - 0.5) * 0.0002,
      radius: rng.nextDouble() * 2.0 + 0.3,
      opacity: baseOp,
      baseOpacity: baseOp,
      phase: rng.nextDouble() * pi * 2,
      color: colors[rng.nextInt(colors.length)],
    );
  }
}

class _ShootingStar {
  double startX, startY, endX, endY, progress, speed, tailLength;
  int delay;
  Color color;

  _ShootingStar({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.progress,
    required this.speed,
    required this.delay,
    required this.tailLength,
    required this.color,
  });

  factory _ShootingStar.random(Random rng) {
    const colors = [VividColors.white, VividColors.cyan, VividColors.gold];
    return _ShootingStar(
      startX: rng.nextDouble() * 0.6 + 0.2,
      startY: -0.05,
      endX: rng.nextDouble() * 0.8,
      endY: rng.nextDouble() * 0.6 + 0.3,
      progress: -0.1,
      speed: 0.003 + rng.nextDouble() * 0.004,
      delay: rng.nextInt(300) + 100,
      tailLength: 0.08 + rng.nextDouble() * 0.06,
      color: colors[rng.nextInt(colors.length)],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final List<_ShootingStar> shootingStars;

  _ParticlePainter(this.particles, this.shootingStars, Listenable repaint)
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw particles
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity.clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 1.5);

      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
    }

    // Draw shooting stars
    for (final s in shootingStars) {
      if (s.progress < 0 || s.progress > 1.1 || s.delay > 0) continue;

      final headX = s.startX + (s.endX - s.startX) * s.progress;
      final headY = s.startY + (s.endY - s.startY) * s.progress;
      final tailProgress = (s.progress - s.tailLength).clamp(0.0, 1.0);
      final tailX = s.startX + (s.endX - s.startX) * tailProgress;
      final tailY = s.startY + (s.endY - s.startY) * tailProgress;

      final headPos = Offset(headX * size.width, headY * size.height);
      final tailPos = Offset(tailX * size.width, tailY * size.height);

      // Fade based on progress
      final alpha = s.progress < 0.1
          ? s.progress / 0.1
          : s.progress > 0.8
              ? (1.0 - s.progress) / 0.2
              : 1.0;

      final gradient = Paint()
        ..shader = LinearGradient(
          colors: [
            s.color.withOpacity(0.0),
            s.color.withOpacity(0.6 * alpha.clamp(0.0, 1.0)),
          ],
        ).createShader(Rect.fromPoints(tailPos, headPos))
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(tailPos, headPos, gradient);

      // Bright head dot
      final dotPaint = Paint()
        ..color = s.color.withOpacity(0.8 * alpha.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(headPos, 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
