// ─── Data Models ──────────────────────────────────────────────────────────────

class Quote {
  final int? id;
  final String text;
  final String author;
  final bool isActive;

  const Quote({
    this.id,
    required this.text,
    required this.author,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'author': author,
    'is_active': isActive ? 1 : 0,
  };

  factory Quote.fromMap(Map<String, dynamic> m) => Quote(
    id: m['id'] as int?,
    text: m['text'] as String,
    author: m['author'] as String,
    isActive: (m['is_active'] as int) == 1,
  );

  Quote copyWith({int? id, String? text, String? author, bool? isActive}) =>
      Quote(
        id: id ?? this.id,
        text: text ?? this.text,
        author: author ?? this.author,
        isActive: isActive ?? this.isActive,
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class Fact {
  final int? id;
  final String text;
  final String category; // 'global' | 'drc'
  final bool isActive;

  const Fact({
    this.id,
    required this.text,
    this.category = 'global',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'category': category,
    'is_active': isActive ? 1 : 0,
  };

  factory Fact.fromMap(Map<String, dynamic> m) => Fact(
    id: m['id'] as int?,
    text: m['text'] as String,
    category: m['category'] as String? ?? 'global',
    isActive: (m['is_active'] as int) == 1,
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class Word {
  final int? id;
  final String word;
  final String phonetic;
  final String definition;
  final String example;
  final bool isActive;

  const Word({
    this.id,
    required this.word,
    required this.phonetic,
    required this.definition,
    this.example = '',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'word': word,
    'phonetic': phonetic,
    'definition': definition,
    'example': example,
    'is_active': isActive ? 1 : 0,
  };

  factory Word.fromMap(Map<String, dynamic> m) => Word(
    id: m['id'] as int?,
    word: m['word'] as String,
    phonetic: m['phonetic'] as String,
    definition: m['definition'] as String,
    example: m['example'] as String? ?? '',
    isActive: (m['is_active'] as int) == 1,
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class HistoryEvent {
  final int? id;
  final int month;
  final int day;
  final int year;
  final String event;
  final bool isActive;

  const HistoryEvent({
    this.id,
    required this.month,
    required this.day,
    required this.year,
    required this.event,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'month': month,
    'day': day,
    'year': year,
    'event': event,
    'is_active': isActive ? 1 : 0,
  };

  factory HistoryEvent.fromMap(Map<String, dynamic> m) => HistoryEvent(
    id: m['id'] as int?,
    month: m['month'] as int,
    day: m['day'] as int,
    year: m['year'] as int,
    event: m['event'] as String,
    isActive: (m['is_active'] as int) == 1,
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class SchoolEvent {
  final int? id;
  final String title;
  final DateTime eventDate;
  final bool isActive;

  const SchoolEvent({
    this.id,
    required this.title,
    required this.eventDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'event_date': eventDate.toIso8601String(),
    'is_active': isActive ? 1 : 0,
  };

  factory SchoolEvent.fromMap(Map<String, dynamic> m) => SchoolEvent(
    id: m['id'] as int?,
    title: m['title'] as String,
    eventDate: DateTime.parse(m['event_date'] as String),
    isActive: (m['is_active'] as int) == 1,
  );

  Duration get timeUntil => eventDate.difference(DateTime.now());
  bool get isFuture => eventDate.isAfter(DateTime.now());
}

// ─────────────────────────────────────────────────────────────────────────────

class Period {
  final int? id;
  final String name;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final int sortOrder;

  const Period({
    this.id,
    required this.name,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'start_hour': startHour,
    'start_minute': startMinute,
    'end_hour': endHour,
    'end_minute': endMinute,
    'sort_order': sortOrder,
  };

  factory Period.fromMap(Map<String, dynamic> m) => Period(
    id: m['id'] as int?,
    name: m['name'] as String,
    startHour: m['start_hour'] as int,
    startMinute: m['start_minute'] as int,
    endHour: m['end_hour'] as int,
    endMinute: m['end_minute'] as int,
    sortOrder: m['sort_order'] as int? ?? 0,
  );

  String get startTimeLabel =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  String get endTimeLabel =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  /// Returns progress 0.0–1.0 if [now] is within the period, else null.
  double? progressAt(DateTime now) {
    final startMins = startHour * 60 + startMinute;
    final endMins   = endHour   * 60 + endMinute;
    final nowMins   = now.hour  * 60 + now.minute;

    if (nowMins < startMins || nowMins >= endMins) return null;
    final total = endMins - startMins;
    if (total <= 0) return null;
    return (nowMins - startMins) / total;
  }

  bool isCurrentPeriod(DateTime now) => progressAt(now) != null;

  /// Returns remaining time in this period, or null if not current.
  Duration? remainingAt(DateTime now) {
    if (!isCurrentPeriod(now)) return null;
    final endTime = DateTime(now.year, now.month, now.day, endHour, endMinute);
    return endTime.difference(now);
  }
}
