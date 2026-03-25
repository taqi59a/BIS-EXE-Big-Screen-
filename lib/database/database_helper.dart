import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants.dart';
import '../models/models.dart';
import 'seed_data.dart';

/// Singleton database helper — manages all SQLite operations for the display.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // ─── Initialisation ─────────────────────────────────────────────────────

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE quotes (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        text        TEXT    NOT NULL,
        author      TEXT    NOT NULL,
        is_active   INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE facts (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        text        TEXT    NOT NULL,
        category    TEXT    NOT NULL DEFAULT 'global',
        is_active   INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE words (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        word        TEXT    NOT NULL,
        phonetic    TEXT    NOT NULL,
        definition  TEXT    NOT NULL,
        example     TEXT    NOT NULL DEFAULT '',
        is_active   INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE history_events (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        month       INTEGER NOT NULL,
        day         INTEGER NOT NULL,
        year        INTEGER NOT NULL,
        event       TEXT    NOT NULL,
        is_active   INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE school_events (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        event_date  TEXT    NOT NULL,
        is_active   INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE periods (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        name          TEXT    NOT NULL,
        start_hour    INTEGER NOT NULL,
        start_minute  INTEGER NOT NULL,
        end_hour      INTEGER NOT NULL,
        end_minute    INTEGER NOT NULL,
        sort_order    INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Seed all tables
    await _seed(db);
  }

  // ─── Upgrade ──────────────────────────────────────────────────────────────

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS quotes');
    await db.execute('DROP TABLE IF EXISTS facts');
    await db.execute('DROP TABLE IF EXISTS words');
    await db.execute('DROP TABLE IF EXISTS history_events');
    await db.execute('DROP TABLE IF EXISTS school_events');
    await db.execute('DROP TABLE IF EXISTS periods');
    await _onCreate(db, newVersion);
  }

  // ─── Seeding ────────────────────────────────────────────────────────────

  Future<void> _seed(Database db) async {
    final batch = db.batch();

    for (final q in SeedData.quotes) {
      batch.insert('quotes', q.toMap()..remove('id'));
    }
    for (final f in SeedData.facts) {
      batch.insert('facts', f.toMap()..remove('id'));
    }
    for (final w in SeedData.words) {
      batch.insert('words', w.toMap()..remove('id'));
    }
    for (final h in SeedData.historyEvents) {
      batch.insert('history_events', h.toMap()..remove('id'));
    }
    for (final e in SeedData.schoolEvents) {
      batch.insert('school_events', e.toMap()..remove('id'));
    }
    for (final p in SeedData.periods) {
      batch.insert('periods', p.toMap()..remove('id'));
    }

    await batch.commit(noResult: true);
  }

  /// Wipes and re-seeds all data (callable from admin).
  Future<void> resetToDefaults() async {
    final db = await database;
    await db.delete('quotes');
    await db.delete('facts');
    await db.delete('words');
    await db.delete('history_events');
    await db.delete('school_events');
    await db.delete('periods');
    await _seed(db);
  }

  // ─── Quotes CRUD ────────────────────────────────────────────────────────

  Future<List<Quote>> getActiveQuotes() async {
    final db = await database;
    final maps = await db.query('quotes', where: 'is_active = 1');
    return maps.map((m) => Quote.fromMap(m)).toList();
  }

  Future<List<Quote>> getAllQuotes() async {
    final db = await database;
    final maps = await db.query('quotes');
    return maps.map((m) => Quote.fromMap(m)).toList();
  }

  Future<int> insertQuote(Quote q) async {
    final db = await database;
    return db.insert('quotes', q.toMap()..remove('id'));
  }

  Future<int> updateQuote(Quote q) async {
    final db = await database;
    return db.update('quotes', q.toMap(), where: 'id = ?', whereArgs: [q.id]);
  }

  Future<int> deleteQuote(int id) async {
    final db = await database;
    return db.delete('quotes', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Facts CRUD ─────────────────────────────────────────────────────────

  Future<List<Fact>> getActiveFacts() async {
    final db = await database;
    final maps = await db.query('facts', where: 'is_active = 1');
    return maps.map((m) => Fact.fromMap(m)).toList();
  }

  Future<List<Fact>> getAllFacts() async {
    final db = await database;
    final maps = await db.query('facts');
    return maps.map((m) => Fact.fromMap(m)).toList();
  }

  Future<int> insertFact(Fact f) async {
    final db = await database;
    return db.insert('facts', f.toMap()..remove('id'));
  }

  Future<int> updateFact(Fact f) async {
    final db = await database;
    return db.update('facts', f.toMap(), where: 'id = ?', whereArgs: [f.id]);
  }

  Future<int> deleteFact(int id) async {
    final db = await database;
    return db.delete('facts', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Words CRUD ─────────────────────────────────────────────────────────

  Future<List<Word>> getActiveWords() async {
    final db = await database;
    final maps = await db.query('words', where: 'is_active = 1');
    return maps.map((m) => Word.fromMap(m)).toList();
  }

  Future<List<Word>> getAllWords() async {
    final db = await database;
    final maps = await db.query('words');
    return maps.map((m) => Word.fromMap(m)).toList();
  }

  Future<int> insertWord(Word w) async {
    final db = await database;
    return db.insert('words', w.toMap()..remove('id'));
  }

  Future<int> updateWord(Word w) async {
    final db = await database;
    return db.update('words', w.toMap(), where: 'id = ?', whereArgs: [w.id]);
  }

  Future<int> deleteWord(int id) async {
    final db = await database;
    return db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  // ─── History Events CRUD ────────────────────────────────────────────────

  Future<List<HistoryEvent>> getEventsForToday() async {
    final db = await database;
    final now = DateTime.now();
    final maps = await db.query(
      'history_events',
      where: 'month = ? AND day = ? AND is_active = 1',
      whereArgs: [now.month, now.day],
    );
    return maps.map((m) => HistoryEvent.fromMap(m)).toList();
  }

  Future<List<HistoryEvent>> getAllHistoryEvents() async {
    final db = await database;
    final maps = await db.query('history_events', orderBy: 'month, day');
    return maps.map((m) => HistoryEvent.fromMap(m)).toList();
  }

  Future<int> insertHistoryEvent(HistoryEvent h) async {
    final db = await database;
    return db.insert('history_events', h.toMap()..remove('id'));
  }

  Future<int> updateHistoryEvent(HistoryEvent h) async {
    final db = await database;
    return db.update('history_events', h.toMap(), where: 'id = ?', whereArgs: [h.id]);
  }

  Future<int> deleteHistoryEvent(int id) async {
    final db = await database;
    return db.delete('history_events', where: 'id = ?', whereArgs: [id]);
  }

  // ─── School Events CRUD ─────────────────────────────────────────────────

  Future<List<SchoolEvent>> getUpcomingSchoolEvents() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'school_events',
      where: 'event_date >= ? AND is_active = 1',
      whereArgs: [now],
      orderBy: 'event_date ASC',
    );
    return maps.map((m) => SchoolEvent.fromMap(m)).toList();
  }

  Future<List<SchoolEvent>> getAllSchoolEvents() async {
    final db = await database;
    final maps = await db.query('school_events', orderBy: 'event_date ASC');
    return maps.map((m) => SchoolEvent.fromMap(m)).toList();
  }

  Future<int> insertSchoolEvent(SchoolEvent e) async {
    final db = await database;
    return db.insert('school_events', e.toMap()..remove('id'));
  }

  Future<int> updateSchoolEvent(SchoolEvent e) async {
    final db = await database;
    return db.update('school_events', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<int> deleteSchoolEvent(int id) async {
    final db = await database;
    return db.delete('school_events', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Periods CRUD ──────────────────────────────────────────────────────

  Future<List<Period>> getPeriods() async {
    final db = await database;
    final maps = await db.query('periods', orderBy: 'sort_order ASC');
    return maps.map((m) => Period.fromMap(m)).toList();
  }

  Future<int> updatePeriod(Period p) async {
    final db = await database;
    return db.update('periods', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> insertPeriod(Period p) async {
    final db = await database;
    return db.insert('periods', p.toMap()..remove('id'));
  }

  Future<int> deletePeriod(int id) async {
    final db = await database;
    return db.delete('periods', where: 'id = ?', whereArgs: [id]);
  }
}
