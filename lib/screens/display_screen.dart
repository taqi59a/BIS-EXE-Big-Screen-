import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/display_provider.dart';
import '../widgets/particle_overlay.dart';
import 'admin_screen.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen>
    with TickerProviderStateMixin {
  int _tapCount = 0;
  DateTime _lastTap = DateTime.now();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _handleTap() {
    final now = DateTime.now();
    if (now.difference(_lastTap).inSeconds > 3) _tapCount = 0;
    _tapCount++;
    _lastTap = now;
    if (_tapCount >= 5) {
      _tapCount = 0;
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AdminScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        final slides = dp.activeSlides;
        final current = dp.currentSlide % (slides.isEmpty ? 1 : slides.length);
        final gradientColors = SlideGradients.forIndex(current);

        return GestureDetector(
          onTap: _handleTap,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < -100) {
                dp.goToSlide(current + 1);
              } else if (details.primaryVelocity! > 100) {
                dp.goToSlide(current - 1 < 0 ? slides.length - 1 : current - 1);
              }
            }
          },
          child: Scaffold(
            body: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(child: ParticleOverlay()),
                  Positioned.fill(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          children: [
                            _buildHeader(dp),
                            const SizedBox(height: 12),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 800),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut,
                                    ),
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.05, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _buildSlide(dp, current, slides),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDots(slides.length, current),
                            const SizedBox(height: 8),
                            _buildFooter(dp),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(DisplayProvider dp) {
    final now = dp.now;
    final timeStr = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat('EEE, d MMM').format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.schoolName.toUpperCase(),
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: VividColors.white,
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 4),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                AppConstants.schoolMotto,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: VividColors.gold,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeStr,
              style: TextStyle(
                fontFamily: AppFonts.clock,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: VividColors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 4),
                ],
              ),
            ),
            Text(
              dateStr,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 12,
                color: VividColors.white,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlide(DisplayProvider dp, int current, List<SlideType> slides) {
    if (slides.isEmpty) {
      return const Center(
        key: ValueKey('empty'),
        child: Text('Loading...', style: TextStyle(color: VividColors.white)),
      );
    }
    final type = slides[current % slides.length];
    switch (type) {
      case SlideType.clock:
        return _ClockSlide(key: const ValueKey('clock'), dp: dp);
      case SlideType.quote:
        return _QuoteSlide(key: ValueKey('quote_${dp.currentQuote?.text}'), dp: dp);
      case SlideType.fact:
        return _FactSlide(key: ValueKey('fact_${dp.currentFact?.text}'), dp: dp);
      case SlideType.word:
        return _WordSlide(key: ValueKey('word_${dp.currentWord?.word}'), dp: dp);
      case SlideType.history:
        return _HistorySlide(key: ValueKey('hist_${dp.currentHistoryEvent?.event}'), dp: dp);
      case SlideType.nextEvent:
        return _NextEventSlide(key: ValueKey('event_${dp.nextEvent?.title}'), dp: dp);
      case SlideType.upcomingEvents:
        return _UpcomingSlide(key: const ValueKey('upcoming'), dp: dp);
    }
  }

  Widget _buildDots(int count, int current) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive ? VividColors.white : VividColors.white30,
            boxShadow: isActive
                ? [
                    BoxShadow(color: VividColors.white.withOpacity(0.5), blurRadius: 8),
                    BoxShadow(color: VividColors.cyan.withOpacity(0.3), blurRadius: 16),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildFooter(DisplayProvider dp) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Website
        Text(
          AppConstants.schoolWebsite,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 13,
            color: VividColors.gold,
            letterSpacing: 0.5,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Developed by
        Text(
          AppConstants.developedBy,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 11,
            color: VividColors.white70,
            letterSpacing: 0.5,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 4),
            ],
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  SCHOOL NAME BANNER (shown on every content slide)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SchoolNameBanner extends StatelessWidget {
  const _SchoolNameBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        AppConstants.schoolName.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppFonts.heading,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: VividColors.gold,
          letterSpacing: 2,
          shadows: [
            Shadow(color: Colors.black.withOpacity(0.9), blurRadius: 6),
            Shadow(color: Colors.black.withOpacity(0.9), blurRadius: 2),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ─── Dynamic font-size helper for variable-length text ───────────────────────
double _dynamicFontSize(String text, {
  double maxSize = 24,
  double midSize = 20,
  double minSize = 16,
  int midThreshold = 120,
  int minThreshold = 220,
}) {
  if (text.length >= minThreshold) return minSize;
  if (text.length >= midThreshold) return midSize;
  return maxSize;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  GLASS BOX — dark frosted-glass card, text always readable
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _GlassBox extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  const _GlassBox({required this.child, this.accentColor = VividColors.white});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.52),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accentColor.withOpacity(0.55), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.18),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .scaleXY(begin: 0.97, end: 1.0, duration: 600.ms, curve: Curves.easeOut);
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  SLIDE WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ClockSlide extends StatelessWidget {
  final DisplayProvider dp;
  const _ClockSlide({super.key, required this.dp});

  @override
  Widget build(BuildContext context) {
    final now = dp.now;
    final timeStr = DateFormat('HH:mm').format(now);
    final secStr = DateFormat('ss').format(now);
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);
    final todayEvents = dp.todayEvents;
    final periodDetail = dp.periodDetailLabel;
    final progress = dp.currentPeriod?.progressAt(now);

    // Determine accent color for period status
    Color periodColor;
    IconData periodIcon;
    if (dp.currentPeriod != null) {
      periodColor = VividColors.cyan;
      periodIcon = Icons.schedule;
    } else if (periodDetail.contains('End of School')) {
      periodColor = VividColors.coral;
      periodIcon = Icons.nightlight_round;
    } else if (periodDetail.contains('Break')) {
      periodColor = VividColors.emerald;
      periodIcon = Icons.coffee;
    } else {
      periodColor = VividColors.gold;
      periodIcon = Icons.wb_sunny_outlined;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // School name banner
          Text(
            AppConstants.schoolName.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: VividColors.gold,
              letterSpacing: 2,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 6),
                Shadow(color: VividColors.gold.withOpacity(0.3), blurRadius: 12),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 5000.ms, color: VividColors.gold.withOpacity(0.15)),
          const SizedBox(height: 6),
          Text(
            AppConstants.schoolMotto,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: VividColors.gold.withOpacity(0.8),
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Time display with neon glow
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeStr,
                style: TextStyle(
                  fontFamily: AppFonts.clock,
                  fontSize: 72,
                  fontWeight: FontWeight.w700,
                  color: VividColors.white,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(color: VividColors.cyan.withOpacity(0.6), blurRadius: 20),
                    Shadow(color: VividColors.electric.withOpacity(0.3), blurRadius: 40),
                    Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  secStr,
                  style: TextStyle(
                    fontFamily: AppFonts.clock,
                    fontSize: 28,
                    color: VividColors.white50,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: VividColors.cyan.withOpacity(0.3), blurRadius: 10),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 1000.ms)
                    .then()
                    .fadeOut(duration: 1000.ms),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date with shimmer
          Text(
            dateStr,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 18,
              color: VividColors.white,
              letterSpacing: 1,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 4),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 4000.ms, color: VividColors.gold.withOpacity(0.2)),

          // Period / Break info — status text, not a button
          if (periodDetail.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(periodIcon, color: periodColor, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    periodDetail,
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontSize: 16,
                      color: periodColor,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 4),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.1, end: 0, duration: 600.ms),
          ],

          // Period progress bar
          if (progress != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: VividColors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress < 0.7
                        ? VividColors.emerald
                        : progress < 0.9
                            ? VividColors.gold
                            : VividColors.coral,
                  ),
                  minHeight: 3,
                ),
              ),
            ),
          ],

          // Today's events
          if (todayEvents.isNotEmpty) ...[
            const SizedBox(height: 20),
            _GlassBox(
              accentColor: VividColors.neonPink,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.celebration, color: VividColors.neonPink, size: 18)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .rotate(begin: -0.05, end: 0.05, duration: 1500.ms),
                      const SizedBox(width: 6),
                      Text(
                        "TODAY'S EVENTS",
                        style: TextStyle(
                          fontFamily: AppFonts.heading,
                          fontSize: 11,
                          color: VividColors.neonPink,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...todayEvents.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      e.title,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 14,
                        color: VividColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.1, end: 0, duration: 800.ms),
          ],
        ],
      ),
    );
  }
}

class _QuoteSlide extends StatelessWidget {
  final DisplayProvider dp;
  const _QuoteSlide({super.key, required this.dp});

  @override
  Widget build(BuildContext context) {
    final quote = dp.currentQuote;
    if (quote == null) return const SizedBox.shrink();

    final quoteFontSize = _dynamicFontSize(
      quote.text,
      maxSize: 26,
      midSize: 21,
      minSize: 17,
      midThreshold: 100,
      minThreshold: 200,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SchoolNameBanner(),
        Expanded(
          child: _GlassBox(
            accentColor: VividColors.gold,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\u201C',
                  style: TextStyle(
                    fontFamily: AppFonts.quote,
                    fontSize: 64,
                    color: VividColors.gold,
                    height: 0.7,
                    shadows: [
                      Shadow(color: VividColors.gold.withOpacity(0.4), blurRadius: 16),
                      Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.12, duration: 2000.ms, curve: Curves.easeInOut),
                const SizedBox(height: 16),
                Text(
                  quote.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.quote,
                    fontSize: quoteFontSize,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.55,
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 1200.ms, delay: 200.ms)
                    .slideY(begin: 0.05, end: 0, duration: 1200.ms),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: VividColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VividColors.gold.withOpacity(0.3)),
                  ),
                  child: Text(
                    '\u2014 ${quote.author}',
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 16,
                      color: VividColors.gold,
                      letterSpacing: 1.5,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 600.ms)
                    .shimmer(duration: 3000.ms, delay: 1000.ms, color: VividColors.gold.withOpacity(0.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FactSlide extends StatelessWidget {
  final DisplayProvider dp;
  const _FactSlide({super.key, required this.dp});

  @override
  Widget build(BuildContext context) {
    final fact = dp.currentFact;
    if (fact == null) return const SizedBox.shrink();
    final isDRC = fact.category == 'drc';
    final accent = isDRC ? VividColors.emerald : VividColors.cyan;
    final factFontSize = _dynamicFontSize(fact.text, maxSize: 22, midSize: 19, minSize: 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SchoolNameBanner(),
        Expanded(
          child: _GlassBox(
            accentColor: accent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: accent.withOpacity(0.3), blurRadius: 24, spreadRadius: 2),
                    ],
                  ),
                  child: Icon(
                    isDRC ? Icons.public : Icons.lightbulb_outline,
                    color: accent,
                    size: 40,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.1, duration: 2000.ms),
                const SizedBox(height: 20),
                Text(
                  isDRC ? 'DRC FACT' : 'DID YOU KNOW?',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 16,
                    color: accent,
                    letterSpacing: 4,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .shimmer(duration: 2000.ms, color: accent.withOpacity(0.5)),
                const SizedBox(height: 20),
                Text(
                  fact.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: factFontSize,
                    color: Colors.white,
                    height: 1.55,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 1000.ms, delay: 300.ms)
                    .slideY(begin: 0.05, end: 0, duration: 1000.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WordSlide extends StatelessWidget {
  final DisplayProvider dp;
  const _WordSlide({super.key, required this.dp});

  @override
  Widget build(BuildContext context) {
    final word = dp.currentWord;
    if (word == null) return const SizedBox.shrink();
    final defFontSize = _dynamicFontSize(word.definition, maxSize: 20, midSize: 17, minSize: 15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SchoolNameBanner(),
        Expanded(
          child: _GlassBox(
            accentColor: VividColors.lavender,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: VividColors.lavender.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: VividColors.lavender.withOpacity(0.3), blurRadius: 24),
                    ],
                  ),
                  child: const Icon(Icons.auto_stories, color: VividColors.lavender, size: 36),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .rotate(begin: -0.02, end: 0.02, duration: 3000.ms),
                const SizedBox(height: 14),
                Text(
                  'WORD OF THE DAY',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 14,
                    color: VividColors.lavender,
                    letterSpacing: 4,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 18),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    word.word,
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: VividColors.lavender.withOpacity(0.6), blurRadius: 16),
                        Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scaleXY(begin: 0.8, end: 1.0, duration: 800.ms, curve: Curves.elasticOut),
                const SizedBox(height: 6),
                Text(
                  word.phonetic,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    color: VividColors.lavender,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms),
                const SizedBox(height: 18),
                Text(
                  word.definition,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: defFontSize,
                    color: Colors.white,
                    height: 1.5,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 500.ms)
                    .slideY(begin: 0.05, end: 0, duration: 800.ms),
                if (word.example.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    '"${word.example}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: (defFontSize - 2).clamp(13, 18),
                      fontStyle: FontStyle.italic,
                      color: VividColors.lavender,
                      height: 1.4,
                      shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 800.ms),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistorySlide extends StatelessWidget {
  final DisplayProvider dp;
  const _HistorySlide({super.key, required this.dp});

  @override
  Widget build(BuildContext context) {
    final he = dp.currentHistoryEvent;
    if (he == null) return const SizedBox.shrink();
    final eventFontSize = _dynamicFontSize(he.event, maxSize: 22, midSize: 19, minSize: 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SchoolNameBanner(),
        Expanded(
          child: _GlassBox(
            accentColor: VividColors.skyBlue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: VividColors.skyBlue.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: VividColors.skyBlue.withOpacity(0.3), blurRadius: 24),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome, color: VividColors.skyBlue, size: 36),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .rotate(begin: 0, end: 0.5, duration: 8000.ms),
                const SizedBox(height: 16),
                Text(
                  'TODAY IN HISTORY',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 16,
                    color: VividColors.skyBlue,
                    letterSpacing: 4,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                  ),
                )
                    .animate()
                    .shimmer(duration: 2500.ms, color: VividColors.skyBlue.withOpacity(0.5)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    color: VividColors.skyBlue.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: VividColors.skyBlue.withOpacity(0.5)),
                  ),
                  child: Text(
                    '${he.year}',
                    style: TextStyle(
                      fontFamily: AppFonts.clock,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scaleXY(begin: 0.5, end: 1.0, duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 20),
                Text(
                  he.event,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: eventFontSize,
                    color: Colors.white,
                    height: 1.55,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 1000.ms, delay: 400.ms)
                    .slideY(begin: 0.05, end: 0, duration: 1000.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NextEventSlide extends StatelessWidget {
  final DisplayProvider dp;
  const _NextEventSlide({super.key, required this.dp});

  @override
  Widget build(BuildContext context) {
    final event = dp.nextEvent;
    if (event == null) return const SizedBox.shrink();

    final now = dp.now;
    final eventDay = DateTime(event.eventDate.year, event.eventDate.month, event.eventDate.day);
    final todayDay = DateTime(now.year, now.month, now.day);
    final isToday = eventDay.isAtSameMomentAs(todayDay);
    final dateStr = DateFormat('d MMMM yyyy').format(event.eventDate);
    final titleFontSize = _dynamicFontSize(event.title, maxSize: 28, midSize: 23, minSize: 19, midThreshold: 40, minThreshold: 70);

    String countdownStr;
    if (isToday) {
      countdownStr = 'TODAY!';
    } else {
      final days = eventDay.difference(todayDay).inDays;
      countdownStr = '$days day${days == 1 ? '' : 's'} away';
    }

    final accent = isToday ? VividColors.neonPink : VividColors.coral;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SchoolNameBanner(),
        Expanded(
          child: _GlassBox(
            accentColor: accent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: accent.withOpacity(0.3), blurRadius: 24),
                    ],
                  ),
                  child: Icon(
                    isToday ? Icons.celebration : Icons.event_available,
                    color: accent,
                    size: 40,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.15, duration: 1500.ms)
                    .rotate(begin: -0.05, end: 0.05, duration: 1500.ms),
                const SizedBox(height: 16),
                Text(
                  isToday ? "TODAY'S EVENT" : 'NEXT EVENT',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 16,
                    color: accent,
                    letterSpacing: 4,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  event.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .slideY(begin: 0.05, end: 0, duration: 800.ms),
                const SizedBox(height: 10),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 16,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: accent.withOpacity(0.7), width: 2),
                    boxShadow: [BoxShadow(color: accent.withOpacity(0.2), blurRadius: 16)],
                  ),
                  child: Text(
                    countdownStr,
                    style: TextStyle(
                      fontFamily: AppFonts.clock,
                      fontSize: isToday ? 26 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 2000.ms, color: accent.withOpacity(0.4))
                    .scaleXY(begin: 1.0, end: 1.05, duration: 2000.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UpcomingSlide extends StatelessWidget {
  final DisplayProvider dp;
  const _UpcomingSlide({super.key, required this.dp});

  @override
  Widget build(BuildContext context) {
    final events = dp.upcomingEvents;
    final show = events.skip(1).take(5).toList();
    if (show.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SchoolNameBanner(),
        Expanded(
          child: _GlassBox(
            accentColor: VividColors.teal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month, color: VividColors.teal, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'COMING UP',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 18,
                        color: VividColors.teal,
                        letterSpacing: 4,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...show.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final days = e.timeUntil.inDays;
                  final label = days <= 0 ? 'TODAY' : days == 1 ? '1 day' : '$days days';
                  final titleFontSize = _dynamicFontSize(e.title, maxSize: 18, midSize: 16, minSize: 14, midThreshold: 40, minThreshold: 70);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: VividColors.teal.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: VividColors.teal.withOpacity(0.6)),
                          ),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppFonts.clock,
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            e.title,
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: titleFontSize,
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4)],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: Duration(milliseconds: 200 * i))
                      .slideX(begin: 0.1, end: 0, duration: 600.ms);
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
