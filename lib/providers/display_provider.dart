import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/models.dart';
import '../constants.dart';
import '../services/music_service.dart';

/// Slide types for the slideshow.
enum SlideType { clock, quote, fact, word, history, nextEvent, upcomingEvents }

/// Central provider — manages slideshow, content, and settings.
class DisplayProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Random _random = Random();

  // ─── Clock ──────────────────────────────────────────────────────────────
  DateTime _now = DateTime.now();
  DateTime get now => _now;

  // ─── Content pools ──────────────────────────────────────────────────────
  List<Quote> _quotes = [];
  List<Fact> _facts = [];
  List<Word> _words = [];
  List<HistoryEvent> _todayHistoryEvents = [];
  List<SchoolEvent> _upcomingEvents = [];
  List<Period> _periods = [];

  // Current items
  Quote? _currentQuote;
  Fact? _currentFact;
  Word? _currentWord;
  HistoryEvent? _currentHistoryEvent;
  int _historyEventIndex = 0;

  Quote? get currentQuote => _currentQuote;
  Fact? get currentFact => _currentFact;
  Word? get currentWord => _currentWord;
  HistoryEvent? get currentHistoryEvent => _currentHistoryEvent;
  List<HistoryEvent> get todayHistoryEvents => _todayHistoryEvents;
  List<SchoolEvent> get upcomingEvents => _upcomingEvents;
  List<Period> get periods => _periods;

  // ─── Slideshow ──────────────────────────────────────────────────────────
  int _currentSlide = 0;
  int get currentSlide => _currentSlide;

  int _slideSeconds = AppConstants.defaultSlideSeconds;
  int get slideSeconds => _slideSeconds;

  List<SlideType> get activeSlides {
    final slides = <SlideType>[SlideType.clock];
    if (_currentQuote != null) slides.add(SlideType.quote);
    if (_currentFact != null) slides.add(SlideType.fact);
    if (_currentWord != null) slides.add(SlideType.word);
    if (_currentHistoryEvent != null) slides.add(SlideType.history);
    if (nextEvent != null) slides.add(SlideType.nextEvent);
    if (_upcomingEvents.length > 1) slides.add(SlideType.upcomingEvents);
    return slides;
  }

  int get slideCount => activeSlides.length;
  SlideType get currentSlideType =>
      activeSlides.isNotEmpty ? activeSlides[_currentSlide % activeSlides.length] : SlideType.clock;

  // ─── Music ──────────────────────────────────────────────────────────────
  bool _musicEnabled = true;
  bool get musicEnabled => _musicEnabled;
  String get currentTrackName =>
      MusicService.instance.currentTrack?.name ?? 'No music';
  List<MusicTrack> get musicTracks => MusicService.instance.tracks;

  // ─── Timers ─────────────────────────────────────────────────────────────
  Timer? _clockTimer;
  Timer? _quoteTimer;
  Timer? _factTimer;
  Timer? _historyTimer;
  Timer? _slideTimer;
  int _lastDay = -1;

  // ─── Initialisation ─────────────────────────────────────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _musicEnabled = prefs.getBool('music_enabled') ?? true;
    _slideSeconds = prefs.getInt('slide_seconds') ?? AppConstants.defaultSlideSeconds;
    _slideSeconds = _slideSeconds.clamp(AppConstants.minSlideSeconds, AppConstants.maxSlideSeconds);

    await _loadAllContent();

    _rotateQuote();
    _rotateFact();
    _rotateWord();
    _rotateHistory();

    // Clock tick
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now = DateTime.now();
      if (_now.day != _lastDay) {
        _lastDay = _now.day;
        _refreshTodayEvents();
      }
      notifyListeners();
    });

    // Content rotation timers
    _quoteTimer = Timer.periodic(
      Duration(seconds: AppConstants.quoteRotationSeconds),
      (_) => _rotateQuote(),
    );
    _factTimer = Timer.periodic(
      Duration(seconds: AppConstants.factRotationSeconds),
      (_) => _rotateFact(),
    );
    _historyTimer = Timer.periodic(
      Duration(seconds: AppConstants.onThisDayDuration),
      (_) => _rotateHistory(),
    );

    // Slideshow auto-advance
    _startSlideTimer();

    // Music
    await MusicService.instance.init();
    MusicService.instance.setEnabled(_musicEnabled);
    if (_musicEnabled) {
      MusicService.instance.play();
    }
  }

  void _startSlideTimer() {
    _slideTimer?.cancel();
    _slideTimer = Timer.periodic(
      Duration(seconds: _slideSeconds),
      (_) => nextSlide(),
    );
  }

  void nextSlide() {
    if (activeSlides.isEmpty) return;
    _currentSlide = (_currentSlide + 1) % activeSlides.length;
    notifyListeners();
  }

  void goToSlide(int index) {
    _currentSlide = index % activeSlides.length;
    _startSlideTimer(); // reset timer on manual navigation
    notifyListeners();
  }

  Future<void> setSlideSeconds(int seconds) async {
    _slideSeconds = seconds.clamp(AppConstants.minSlideSeconds, AppConstants.maxSlideSeconds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('slide_seconds', _slideSeconds);
    _startSlideTimer();
    notifyListeners();
  }

  Future<void> _loadAllContent() async {
    _quotes = await _db.getActiveQuotes();
    _facts = await _db.getActiveFacts();
    _words = await _db.getActiveWords();
    _todayHistoryEvents = await _db.getEventsForToday();
    _upcomingEvents = await _db.getUpcomingSchoolEvents();
    _periods = await _db.getPeriods();
    _lastDay = DateTime.now().day;
  }

  Future<void> _refreshTodayEvents() async {
    _todayHistoryEvents = await _db.getEventsForToday();
    _upcomingEvents = await _db.getUpcomingSchoolEvents();
    _historyEventIndex = 0;
    _rotateHistory();
    notifyListeners();
  }

  // ─── Content Rotation ───────────────────────────────────────────────────

  void _rotateQuote() {
    if (_quotes.isEmpty) return;
    _currentQuote = _quotes[_random.nextInt(_quotes.length)];
    notifyListeners();
  }

  void _rotateFact() {
    if (_facts.isEmpty) return;
    _currentFact = _facts[_random.nextInt(_facts.length)];
    notifyListeners();
  }

  void _rotateWord() {
    if (_words.isEmpty) return;
    final daySeed = _now.year * 1000 + _now.month * 100 + _now.day;
    _currentWord = _words[daySeed % _words.length];
    notifyListeners();
  }

  void _rotateHistory() {
    if (_todayHistoryEvents.isEmpty) {
      _currentHistoryEvent = null;
    } else {
      _currentHistoryEvent =
          _todayHistoryEvents[_historyEventIndex % _todayHistoryEvents.length];
      _historyEventIndex++;
    }
    notifyListeners();
  }

  // ─── Period Helpers ─────────────────────────────────────────────────────

  Period? get currentPeriod {
    for (final p in _periods) {
      if (p.isCurrentPeriod(_now)) return p;
    }
    return null;
  }

  Period? get nextPeriod {
    final nowMins = _now.hour * 60 + _now.minute;
    for (final p in _periods) {
      final startMins = p.startHour * 60 + p.startMinute;
      if (startMins > nowMins) return p;
    }
    return null;
  }

  SchoolEvent? get nextEvent =>
      _upcomingEvents.isNotEmpty ? _upcomingEvents.first : null;

  List<SchoolEvent> get todayEvents {
    final today = DateTime(_now.year, _now.month, _now.day);
    return _upcomingEvents.where((e) {
      final eDate = DateTime(e.eventDate.year, e.eventDate.month, e.eventDate.day);
      return eDate.isAtSameMomentAs(today);
    }).toList();
  }

  String get periodStatusLabel {
    final cp = currentPeriod;
    if (cp != null) return cp.name;
    if (_periods.isEmpty) return '';
    final firstStart = _periods.first.startHour * 60 + _periods.first.startMinute;
    final lastEnd = _periods.last.endHour * 60 + _periods.last.endMinute;
    final nowMins = _now.hour * 60 + _now.minute;
    if (nowMins < firstStart) {
      return 'School starts at ${_periods.first.startTimeLabel}';
    }
    if (nowMins >= lastEnd) return 'End of School';
    // Between periods — find which break
    for (int i = 0; i < _periods.length - 1; i++) {
      final endMins = _periods[i].endHour * 60 + _periods[i].endMinute;
      final nextStartMins = _periods[i + 1].startHour * 60 + _periods[i + 1].startMinute;
      if (nowMins >= endMins && nowMins < nextStartMins) {
        return 'Break';
      }
    }
    return 'Between Periods';
  }

  /// Detailed period info for the clock slide: shows break name, countdown to next, etc.
  String get periodDetailLabel {
    final cp = currentPeriod;
    if (cp != null) {
      final remaining = periodTimeRemaining;
      return remaining != null ? '${cp.name} \u2022 $remaining remaining' : cp.name;
    }
    if (_periods.isEmpty) return '';
    final firstStart = _periods.first.startHour * 60 + _periods.first.startMinute;
    final lastEnd = _periods.last.endHour * 60 + _periods.last.endMinute;
    final nowMins = _now.hour * 60 + _now.minute;
    // After midnight and before school
    if (nowMins < firstStart) {
      return '1st Period at ${_periods.first.startTimeLabel}';
    }
    // After school ends
    if (nowMins >= lastEnd) return 'End of School';
    // Between periods — find which break and when next starts
    for (int i = 0; i < _periods.length - 1; i++) {
      final endMins = _periods[i].endHour * 60 + _periods[i].endMinute;
      final nextStartMins = _periods[i + 1].startHour * 60 + _periods[i + 1].startMinute;
      if (nowMins >= endMins && nowMins < nextStartMins) {
        final minsLeft = nextStartMins - nowMins;
        return 'Break \u2022 ${_periods[i + 1].name} in ${minsLeft}min';
      }
    }
    return 'Between Periods';
  }

  String? get periodTimeRemaining {
    final cp = currentPeriod;
    if (cp == null) return null;
    final remaining = cp.remainingAt(_now);
    if (remaining == null) return null;
    final mins = remaining.inMinutes;
    final secs = remaining.inSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ─── Settings ───────────────────────────────────────────────────────────

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', value);
    MusicService.instance.setEnabled(value);
    if (value) {
      MusicService.instance.play();
    }
    notifyListeners();
  }

  Future<void> skipTrack() async {
    await MusicService.instance.skipNext();
    notifyListeners();
  }

  Future<void> rescanMusic() async {
    await MusicService.instance.rescan();
    notifyListeners();
  }

  Future<void> reload() async {
    await _loadAllContent();
    _rotateQuote();
    _rotateFact();
    _rotateWord();
    _rotateHistory();
    _currentSlide = 0;
    notifyListeners();
  }

  // ─── Cleanup ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _clockTimer?.cancel();
    _quoteTimer?.cancel();
    _factTimer?.cancel();
    _historyTimer?.cancel();
    _slideTimer?.cancel();
    MusicService.instance.dispose();
    super.dispose();
  }
}
