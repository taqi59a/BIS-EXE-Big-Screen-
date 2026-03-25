import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/display_provider.dart';
import 'glass_card.dart';

// ─── Inspirational Quote Card ────────────────────────────────────────────────

class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        final quote = dp.currentQuote;
        if (quote == null) return const SizedBox.shrink();

        return GoldGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opening quote mark with glow
              Text(
                '\u201C',
                style: TextStyle(
                  fontFamily: AppFonts.quote,
                  fontSize: 36,
                  color: BISLColors.schoolGold.withOpacity(0.5),
                  height: 0.8,
                  shadows: [
                    Shadow(
                      color: BISLColors.schoolGold.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              Text(
                quote.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.quote,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: BISLColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      BISLColors.schoolGold.withOpacity(0.0),
                      BISLColors.schoolGold.withOpacity(0.1),
                      BISLColors.schoolGold.withOpacity(0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '— ${quote.author}',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 13,
                    color: BISLColors.textGold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate(key: ValueKey(quote.text))
            .fadeIn(duration: 1200.ms, curve: Curves.easeOut)
            .slideY(begin: 0.05, end: 0, duration: 1200.ms)
            .scaleXY(begin: 0.97, end: 1.0, duration: 1200.ms);
      },
    );
  }
}

// ─── Did You Know? (Fact) Card ──────────────────────────────────────────────

class FactCard extends StatelessWidget {
  const FactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        final fact = dp.currentFact;
        if (fact == null) return const SizedBox.shrink();

        final isDRC = fact.category == 'drc';

        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isDRC ? BISLColors.glowGreen : BISLColors.glowGold)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDRC ? Icons.public : Icons.lightbulb_outline,
                  color: isDRC ? BISLColors.glowGreen : BISLColors.glowGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isDRC ? 'DRC Fact' : 'Did You Know?',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 11,
                        color: isDRC ? BISLColors.glowGreen : BISLColors.glowGold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fact.text,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 14,
                        color: BISLColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate(key: ValueKey(fact.text))
            .fadeIn(duration: 800.ms)
            .slideX(begin: 0.03, end: 0, duration: 800.ms)
            .scaleXY(begin: 0.98, end: 1.0, duration: 800.ms);
      },
    );
  }
}

// ─── Word of the Day Card ───────────────────────────────────────────────────

class WordOfTheDayCard extends StatelessWidget {
  const WordOfTheDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        final word = dp.currentWord;
        if (word == null) return const SizedBox.shrink();

        return GoldGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: BISLColors.glowCopper.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.auto_stories,
                        color: BISLColors.glowCopper, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WORD OF THE DAY',
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontSize: 10,
                      color: BISLColors.glowCopper,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                word.word,
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: BISLColors.textPrimary,
                  shadows: [
                    Shadow(
                      color: BISLColors.glowCopper.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              Text(
                word.phonetic,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  color: BISLColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                word.definition,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  color: BISLColors.textSecondary,
                  height: 1.4,
                ),
              ),
              if (word.example.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '"${word.example}"',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    color: BISLColors.textMuted,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        )
            .animate(key: ValueKey(word.word))
            .fadeIn(duration: 1000.ms)
            .slideY(begin: 0.04, end: 0, duration: 1000.ms);
      },
    );
  }
}

// ─── On This Day Card ───────────────────────────────────────────────────────

class OnThisDayCard extends StatelessWidget {
  const OnThisDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        final historyEvent = dp.currentHistoryEvent;
        if (historyEvent == null) return const SizedBox.shrink();

        final totalToday = dp.todayHistoryEvents.length;

        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BISLColors.glowBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_awesome,
                    color: BISLColors.glowBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'TODAY IN HISTORY — ${historyEvent.year}',
                          style: TextStyle(
                            fontFamily: AppFonts.heading,
                            fontSize: 10,
                            color: BISLColors.glowBlue,
                            letterSpacing: 2,
                          ),
                        ),
                        if (totalToday > 1) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: BISLColors.glowBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$totalToday events today',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 9,
                                color: BISLColors.glowBlue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      historyEvent.event,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 14,
                        color: BISLColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate(key: ValueKey(historyEvent.event))
            .fadeIn(duration: 800.ms)
            .slideX(begin: -0.03, end: 0, duration: 800.ms);
      },
    );
  }
}

// ─── Next Event Spotlight with Live Countdown ───────────────────────────────

class NextEventCard extends StatelessWidget {
  const NextEventCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        final event = dp.nextEvent;
        if (event == null) return const SizedBox.shrink();

        final now = dp.now;
        final eventDay = DateTime(
          event.eventDate.year, event.eventDate.month, event.eventDate.day,
        );
        final todayDay = DateTime(now.year, now.month, now.day);
        final isToday = eventDay.isAtSameMomentAs(todayDay);
        final dateStr = DateFormat('d MMM yyyy').format(event.eventDate);

        // Live countdown: days + HH:MM:SS until midnight of event day
        String countdownStr;
        if (isToday) {
          countdownStr = 'TODAY!';
        } else {
          final untilEvent = eventDay.difference(now);
          final days = untilEvent.inDays;
          final hours = untilEvent.inHours % 24;
          final mins = untilEvent.inMinutes % 60;
          final secs = untilEvent.inSeconds % 60;
          if (days > 0) {
            countdownStr =
                'in $days day${days == 1 ? '' : 's'} ${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
          } else {
            countdownStr =
                'in ${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
          }
        }

        return GoldGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    isToday ? Icons.celebration : Icons.event_available,
                    color: BISLColors.schoolGold,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isToday ? 'TODAY\u2019S EVENT' : 'NEXT EVENT',
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontSize: 10,
                      color: BISLColors.schoolGold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.title,
                style: const TextStyle(
                  fontFamily: AppFonts.heading,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: BISLColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  color: BISLColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isToday
                      ? BISLColors.schoolGold.withOpacity(0.2)
                      : BISLColors.glowBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isToday
                        ? BISLColors.schoolGold.withOpacity(0.5)
                        : BISLColors.glowBlue.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  countdownStr,
                  style: TextStyle(
                    fontFamily: AppFonts.clock,
                    fontSize: isToday ? 16 : 13,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? BISLColors.glowGold : BISLColors.glowBlue,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate(key: ValueKey(event.title))
            .fadeIn(duration: 1000.ms)
            .slideY(begin: 0.04, end: 0, duration: 1000.ms);
      },
    );
  }
}

// ─── Today Banner (shown when today has an event) ───────────────────────────

class TodayBanner extends StatelessWidget {
  const TodayBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        final todayEvents = dp.todayEvents;
        if (todayEvents.isEmpty) return const SizedBox.shrink();

        final titles = todayEvents.map((e) => e.title).join(' \u2022 ');

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                BISLColors.schoolGold.withOpacity(0.15),
                BISLColors.schoolGold.withOpacity(0.05),
                BISLColors.schoolGold.withOpacity(0.15),
              ],
            ),
            border: Border(
              top: BorderSide(color: BISLColors.schoolGold.withOpacity(0.3)),
              bottom: BorderSide(color: BISLColors.schoolGold.withOpacity(0.3)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration, color: BISLColors.glowGold, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'TODAY: $titles',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 13,
                    color: BISLColors.glowGold,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.celebration, color: BISLColors.glowGold, size: 16),
            ],
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(duration: 2000.ms, color: BISLColors.schoolGold.withOpacity(0.3));
      },
    );
  }
}

// ─── Upcoming Events Card (shows events after the spotlight) ─────────────────

class UpcomingEventsCard extends StatelessWidget {
  const UpcomingEventsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        final events = dp.upcomingEvents;
        if (events.length <= 1) return const SizedBox.shrink();

        // Skip first event (shown in NextEventCard), show next 3
        final show = events.skip(1).take(3).toList();
        if (show.isEmpty) return const SizedBox.shrink();

        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.event, color: BISLColors.schoolGold, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'ALSO COMING UP',
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontSize: 10,
                      color: BISLColors.schoolGold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...show.map((e) {
                final days = e.timeUntil.inDays;
                final label = days == 0
                    ? 'TODAY'
                    : days == 1
                        ? '1 day'
                        : '$days days';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: BISLColors.schoolGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: AppFonts.clock,
                            fontSize: 11,
                            color: BISLColors.glowGold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.title,
                          style: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 13,
                            color: BISLColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ─── School Header / Motto ──────────────────────────────────────────────────

class SchoolHeader extends StatelessWidget {
  const SchoolHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              BISLGradients.goldShimmer.createShader(bounds),
          child: const Text(
            AppConstants.schoolName,
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(duration: 4000.ms, color: BISLColors.glowGold.withOpacity(0.3)),
        const SizedBox(height: 2),
        Text(
          AppConstants.schoolCity.toUpperCase(),
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 11,
            color: BISLColors.textMuted,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          AppConstants.schoolMotto,
          style: TextStyle(
            fontFamily: AppFonts.quote,
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: BISLColors.textGold.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// ─── Now Playing Indicator ──────────────────────────────────────────────────

class NowPlayingIndicator extends StatelessWidget {
  const NowPlayingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        if (!dp.musicEnabled) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: BISLColors.glassFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_note, color: BISLColors.textMuted, size: 12)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 0.8, end: 1.1, duration: 800.ms),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  dp.currentTrackName,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 10,
                    color: BISLColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
