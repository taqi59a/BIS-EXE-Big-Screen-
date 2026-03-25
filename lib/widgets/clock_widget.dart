import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/display_provider.dart';
import 'glass_card.dart';

/// A large centrepiece clock with date, and a glowing period-progress ring.
class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        final now = dp.now;
        final timeStr = DateFormat('HH:mm').format(now);
        final secStr = DateFormat('ss').format(now);
        final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);

        final period = dp.currentPeriod;
        final nextPeriod = dp.nextPeriod;
        final progress = period?.progressAt(now);
        final statusLabel = dp.periodStatusLabel;
        final remaining = dp.periodTimeRemaining;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Period ring + time
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ring
                  if (progress != null)
                    CustomPaint(
                      size: const Size(260, 260),
                      painter: _PeriodRingPainter(progress: progress),
                    ),
                  // Time
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontFamily: AppFonts.clock,
                              fontSize: 64,
                              fontWeight: FontWeight.w700,
                              color: BISLColors.textPrimary,
                              letterSpacing: 2,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              secStr,
                              style: TextStyle(
                                fontFamily: AppFonts.clock,
                                fontSize: 24,
                                color: BISLColors.textMuted,
                                letterSpacing: 1,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Current period / status label
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontFamily: AppFonts.heading,
                          fontSize: 16,
                          color: period != null
                              ? BISLColors.schoolGold
                              : BISLColors.textMuted,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Countdown to period end
            if (remaining != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: BISLColors.schoolGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: BISLColors.schoolGold.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined,
                        color: BISLColors.glowGold, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Ends in $remaining',
                      style: TextStyle(
                        fontFamily: AppFonts.clock,
                        fontSize: 14,
                        color: BISLColors.glowGold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Date
            Text(
              dateStr,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 16,
                color: BISLColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),

            // Next period hint if between periods
            if (period == null && nextPeriod != null) ...[
              const SizedBox(height: 6),
              Text(
                'Next: ${nextPeriod.name} at ${nextPeriod.startTimeLabel}',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  color: BISLColors.textMuted,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ─── Period Ring Painter ──────────────────────────────────────────────────────

class _PeriodRingPainter extends CustomPainter {
  final double progress;

  _PeriodRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background ring
    final bgPaint = Paint()
      ..color = BISLColors.glassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final color = progress < 0.7
        ? BISLColors.periodGreen
        : progress < 0.9
            ? BISLColors.periodYellow
            : BISLColors.periodRed;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // start from top
      2 * pi * progress,
      false,
      arcPaint,
    );

    // Bright dot at end of arc
    final dotAngle = -pi / 2 + 2 * pi * progress;
    final dotPos = Offset(
      center.dx + radius * cos(dotAngle),
      center.dy + radius * sin(dotAngle),
    );
    final dotPaint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(dotPos, 4, dotPaint);
  }

  @override
  bool shouldRepaint(_PeriodRingPainter old) => old.progress != progress;
}

// ─── Period Bar (bottom schedule strip) ──────────────────────────────────────

class PeriodBar extends StatelessWidget {
  const PeriodBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        if (dp.periods.isEmpty) return const SizedBox.shrink();

        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          borderRadius: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: dp.periods.map((p) {
              final isCurrent = p.isCurrentPeriod(dp.now);
              return Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    padding: isCurrent
                        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4)
                        : EdgeInsets.zero,
                    decoration: isCurrent
                        ? BoxDecoration(
                            color: BISLColors.schoolGold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: BISLColors.schoolGold.withOpacity(0.4),
                            ),
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.name,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 10,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent
                                ? BISLColors.schoolGold
                                : BISLColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${p.startTimeLabel}–${p.endTimeLabel}',
                          style: TextStyle(
                            fontFamily: AppFonts.clock,
                            fontSize: 8,
                            color: isCurrent
                                ? BISLColors.glowGold
                                : BISLColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
