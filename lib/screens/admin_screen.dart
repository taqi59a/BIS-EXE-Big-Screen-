import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../database/database_helper.dart';
import '../models/models.dart';
import '../providers/display_provider.dart';
import '../services/music_service.dart';

/// Password-protected admin panel for managing display content.
/// Accessed by tapping the display screen 5 times quickly.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _authenticated = false;
  final _pwController = TextEditingController();
  String _error = '';

  @override
  void dispose() {
    _pwController.dispose();
    super.dispose();
  }

  void _authenticate() {
    if (_pwController.text == AppConstants.adminPassword) {
      setState(() {
        _authenticated = true;
        _error = '';
      });
    } else {
      setState(() => _error = 'Incorrect password');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) return _buildLoginScreen();
    return _buildAdminPanel();
  }

  // ─── Login ──────────────────────────────────────────────────────────────

  Widget _buildLoginScreen() {
    return Scaffold(
      backgroundColor: BISLColors.bgDeepNavy,
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: BISLColors.bgMidBlue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BISLColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.admin_panel_settings,
                  color: BISLColors.schoolGold, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Admin Access',
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontSize: 20,
                  color: BISLColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pwController,
                obscureText: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: BISLColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  hintStyle: TextStyle(color: BISLColors.textMuted),
                  filled: true,
                  fillColor: BISLColors.bgDeepNavy,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: BISLColors.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: BISLColors.glassBorder),
                  ),
                ),
                onSubmitted: (_) => _authenticate(),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_error,
                    style: const TextStyle(
                        color: BISLColors.periodRed, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel',
                          style: TextStyle(color: BISLColors.textMuted)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _authenticate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BISLColors.royalBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Admin Panel ────────────────────────────────────────────────────────

  Widget _buildAdminPanel() {
    return Scaffold(
      backgroundColor: BISLColors.bgDeepNavy,
      appBar: AppBar(
        title: const Text('Admin Panel',
            style: TextStyle(fontFamily: AppFonts.heading, letterSpacing: 2)),
        backgroundColor: BISLColors.bgMidBlue,
        foregroundColor: BISLColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Reload display content and go back
            context.read<DisplayProvider>().reload();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: DefaultTabController(
        length: 8,
        child: Column(
          children: [
            Container(
              color: BISLColors.bgMidBlue,
              child: TabBar(
                isScrollable: true,
                indicatorColor: BISLColors.schoolGold,
                labelColor: BISLColors.schoolGold,
                unselectedLabelColor: BISLColors.textMuted,
                labelStyle: const TextStyle(
                    fontFamily: AppFonts.body, fontSize: 12),
                tabs: const [
                  Tab(text: 'Quotes'),
                  Tab(text: 'Facts'),
                  Tab(text: 'Words'),
                  Tab(text: 'History'),
                  Tab(text: 'Events'),
                  Tab(text: 'Schedule'),
                  Tab(text: 'Music'),
                  Tab(text: 'Settings'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _QuotesTab(),
                  _FactsTab(),
                  _WordsTab(),
                  _HistoryTab(),
                  _EventsTab(),
                  _ScheduleTab(),
                  _MusicTab(),
                  _SettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quotes Tab ─────────────────────────────────────────────────────────────

class _QuotesTab extends StatefulWidget {
  @override
  State<_QuotesTab> createState() => _QuotesTabState();
}

class _QuotesTabState extends State<_QuotesTab> {
  List<Quote> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DatabaseHelper.instance.getAllQuotes();
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        _addButton(onPressed: () => _showAddDialog()),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final q = _items[i];
              return _AdminListTile(
                title: q.text,
                subtitle: '— ${q.author}',
                isActive: q.isActive,
                onToggle: () async {
                  await DatabaseHelper.instance
                      .updateQuote(q.copyWith(isActive: !q.isActive));
                  _load();
                },
                onDelete: () async {
                  await DatabaseHelper.instance.deleteQuote(q.id!);
                  _load();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDialog() {
    final textC = TextEditingController();
    final authorC = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => _AdminDialog(
        title: 'Add Quote',
        fields: [
          _AdminField(controller: textC, hint: 'Quote text'),
          _AdminField(controller: authorC, hint: 'Author'),
        ],
        onSave: () async {
          if (textC.text.isEmpty || authorC.text.isEmpty) return;
          await DatabaseHelper.instance.insertQuote(
            Quote(text: textC.text, author: authorC.text),
          );
          if (mounted) {
            Navigator.of(context).pop();
            _load();
          }
        },
      ),
    );
  }
}

// ─── Facts Tab ──────────────────────────────────────────────────────────────

class _FactsTab extends StatefulWidget {
  @override
  State<_FactsTab> createState() => _FactsTabState();
}

class _FactsTabState extends State<_FactsTab> {
  List<Fact> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DatabaseHelper.instance.getAllFacts();
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        _addButton(onPressed: () => _showAddDialog()),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final f = _items[i];
              return _AdminListTile(
                title: f.text,
                subtitle: f.category.toUpperCase(),
                isActive: f.isActive,
                onToggle: () async {
                  final updated = Fact(
                    id: f.id,
                    text: f.text,
                    category: f.category,
                    isActive: !f.isActive,
                  );
                  await DatabaseHelper.instance.updateFact(updated);
                  _load();
                },
                onDelete: () async {
                  await DatabaseHelper.instance.deleteFact(f.id!);
                  _load();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDialog() {
    final textC = TextEditingController();
    String category = 'global';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => _AdminDialog(
          title: 'Add Fact',
          fields: [
            _AdminField(controller: textC, hint: 'Fact text'),
          ],
          extra: DropdownButton<String>(
            value: category,
            dropdownColor: BISLColors.bgMidBlue,
            style: const TextStyle(color: BISLColors.textPrimary, fontSize: 14),
            items: const [
              DropdownMenuItem(value: 'global', child: Text('Global')),
              DropdownMenuItem(value: 'drc', child: Text('DRC')),
            ],
            onChanged: (v) => setDialogState(() => category = v ?? 'global'),
          ),
          onSave: () async {
            if (textC.text.isEmpty) return;
            await DatabaseHelper.instance.insertFact(
              Fact(text: textC.text, category: category),
            );
            if (mounted) {
              Navigator.of(context).pop();
              _load();
            }
          },
        ),
      ),
    );
  }
}

// ─── Words Tab ──────────────────────────────────────────────────────────────

class _WordsTab extends StatefulWidget {
  @override
  State<_WordsTab> createState() => _WordsTabState();
}

class _WordsTabState extends State<_WordsTab> {
  List<Word> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DatabaseHelper.instance.getAllWords();
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        _addButton(onPressed: () => _showAddDialog()),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final w = _items[i];
              return _AdminListTile(
                title: w.word,
                subtitle: w.definition,
                isActive: w.isActive,
                onToggle: () async {
                  final updated = Word(
                    id: w.id,
                    word: w.word,
                    phonetic: w.phonetic,
                    definition: w.definition,
                    example: w.example,
                    isActive: !w.isActive,
                  );
                  await DatabaseHelper.instance.updateWord(updated);
                  _load();
                },
                onDelete: () async {
                  await DatabaseHelper.instance.deleteWord(w.id!);
                  _load();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDialog() {
    final wordC = TextEditingController();
    final phoneticC = TextEditingController();
    final defC = TextEditingController();
    final exampleC = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => _AdminDialog(
        title: 'Add Word',
        fields: [
          _AdminField(controller: wordC, hint: 'Word'),
          _AdminField(controller: phoneticC, hint: 'Phonetic (e.g. /wɜːrd/)'),
          _AdminField(controller: defC, hint: 'Definition'),
          _AdminField(controller: exampleC, hint: 'Example sentence (optional)'),
        ],
        onSave: () async {
          if (wordC.text.isEmpty || defC.text.isEmpty) return;
          await DatabaseHelper.instance.insertWord(Word(
            word: wordC.text,
            phonetic: phoneticC.text,
            definition: defC.text,
            example: exampleC.text,
          ));
          if (mounted) {
            Navigator.of(context).pop();
            _load();
          }
        },
      ),
    );
  }
}

// ─── History Events Tab ─────────────────────────────────────────────────────

class _HistoryTab extends StatefulWidget {
  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  List<HistoryEvent> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DatabaseHelper.instance.getAllHistoryEvents();
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        _addButton(onPressed: () => _showAddDialog()),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final h = _items[i];
              return _AdminListTile(
                title: '${h.month}/${h.day}/${h.year}',
                subtitle: h.event,
                isActive: h.isActive,
                onToggle: () async {
                  final updated = HistoryEvent(
                    id: h.id,
                    month: h.month,
                    day: h.day,
                    year: h.year,
                    event: h.event,
                    isActive: !h.isActive,
                  );
                  await DatabaseHelper.instance.updateHistoryEvent(updated);
                  _load();
                },
                onDelete: () async {
                  await DatabaseHelper.instance.deleteHistoryEvent(h.id!);
                  _load();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDialog() {
    final monthC = TextEditingController();
    final dayC = TextEditingController();
    final yearC = TextEditingController();
    final eventC = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => _AdminDialog(
        title: 'Add History Event',
        fields: [
          _AdminField(controller: monthC, hint: 'Month (1–12)', isNumber: true),
          _AdminField(controller: dayC, hint: 'Day (1–31)', isNumber: true),
          _AdminField(controller: yearC, hint: 'Year', isNumber: true),
          _AdminField(controller: eventC, hint: 'What happened?'),
        ],
        onSave: () async {
          final m = int.tryParse(monthC.text);
          final d = int.tryParse(dayC.text);
          final y = int.tryParse(yearC.text);
          if (m == null || d == null || y == null || eventC.text.isEmpty) return;
          await DatabaseHelper.instance.insertHistoryEvent(
            HistoryEvent(month: m, day: d, year: y, event: eventC.text),
          );
          if (mounted) {
            Navigator.of(context).pop();
            _load();
          }
        },
      ),
    );
  }
}

// ─── School Events Tab ──────────────────────────────────────────────────────

class _EventsTab extends StatefulWidget {
  @override
  State<_EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<_EventsTab> {
  List<SchoolEvent> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DatabaseHelper.instance.getAllSchoolEvents();
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        _addButton(onPressed: () => _showAddDialog()),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final e = _items[i];
              final dateStr = DateFormat('d MMM yyyy').format(e.eventDate);
              return _AdminListTile(
                title: e.title,
                subtitle: dateStr,
                isActive: e.isActive,
                onToggle: () async {
                  final updated = SchoolEvent(
                    id: e.id,
                    title: e.title,
                    eventDate: e.eventDate,
                    isActive: !e.isActive,
                  );
                  await DatabaseHelper.instance.updateSchoolEvent(updated);
                  _load();
                },
                onDelete: () async {
                  await DatabaseHelper.instance.deleteSchoolEvent(e.id!);
                  _load();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDialog() {
    final titleC = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => _AdminDialog(
          title: 'Add School Event',
          fields: [
            _AdminField(controller: titleC, hint: 'Event title'),
          ],
          extra: Row(
            children: [
              Text(
                DateFormat('d MMM yyyy').format(selectedDate),
                style: const TextStyle(
                    color: BISLColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
                child: const Text('Pick Date',
                    style: TextStyle(color: BISLColors.glowBlue)),
              ),
            ],
          ),
          onSave: () async {
            if (titleC.text.isEmpty) return;
            await DatabaseHelper.instance.insertSchoolEvent(
              SchoolEvent(title: titleC.text, eventDate: selectedDate),
            );
            if (mounted) {
              Navigator.of(context).pop();
              _load();
            }
          },
        ),
      ),
    );
  }
}

// ─── Schedule (Periods) Tab ─────────────────────────────────────────────────

class _ScheduleTab extends StatefulWidget {
  @override
  State<_ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<_ScheduleTab> {
  List<Period> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DatabaseHelper.instance.getPeriods();
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        _addButton(onPressed: () => _showAddDialog()),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final p = _items[i];
              return Card(
                color: BISLColors.bgMidBlue,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(
                    p.name,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14,
                      color: BISLColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${p.startTimeLabel} – ${p.endTimeLabel}',
                    style: const TextStyle(
                      fontFamily: AppFonts.clock,
                      fontSize: 12,
                      color: BISLColors.textMuted,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: BISLColors.glowBlue, size: 20),
                        onPressed: () => _showEditDialog(p),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: BISLColors.periodRed, size: 20),
                        onPressed: () async {
                          await DatabaseHelper.instance.deletePeriod(p.id!);
                          _load();
                        },
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDialog() {
    final nameC = TextEditingController();
    final startHC = TextEditingController();
    final startMC = TextEditingController();
    final endHC = TextEditingController();
    final endMC = TextEditingController();
    final sortC = TextEditingController(text: '${_items.length}');
    showDialog(
      context: context,
      builder: (_) => _AdminDialog(
        title: 'Add Period / Break',
        fields: [
          _AdminField(controller: nameC, hint: 'Name (e.g. Period 1, Break)'),
          _AdminField(controller: startHC, hint: 'Start hour (0–23)', isNumber: true),
          _AdminField(controller: startMC, hint: 'Start minute (0–59)', isNumber: true),
          _AdminField(controller: endHC, hint: 'End hour (0–23)', isNumber: true),
          _AdminField(controller: endMC, hint: 'End minute (0–59)', isNumber: true),
          _AdminField(controller: sortC, hint: 'Sort order', isNumber: true),
        ],
        onSave: () async {
          final name = nameC.text;
          final sH = int.tryParse(startHC.text);
          final sM = int.tryParse(startMC.text);
          final eH = int.tryParse(endHC.text);
          final eM = int.tryParse(endMC.text);
          final sort = int.tryParse(sortC.text) ?? _items.length;
          if (name.isEmpty || sH == null || sM == null || eH == null || eM == null) return;
          await DatabaseHelper.instance.insertPeriod(Period(
            name: name,
            startHour: sH,
            startMinute: sM,
            endHour: eH,
            endMinute: eM,
            sortOrder: sort,
          ));
          if (mounted) {
            Navigator.of(context).pop();
            _load();
          }
        },
      ),
    );
  }

  void _showEditDialog(Period p) {
    final nameC = TextEditingController(text: p.name);
    final startHC = TextEditingController(text: '${p.startHour}');
    final startMC = TextEditingController(text: '${p.startMinute}');
    final endHC = TextEditingController(text: '${p.endHour}');
    final endMC = TextEditingController(text: '${p.endMinute}');
    final sortC = TextEditingController(text: '${p.sortOrder}');
    showDialog(
      context: context,
      builder: (_) => _AdminDialog(
        title: 'Edit Period',
        fields: [
          _AdminField(controller: nameC, hint: 'Name'),
          _AdminField(controller: startHC, hint: 'Start hour (0–23)', isNumber: true),
          _AdminField(controller: startMC, hint: 'Start minute (0–59)', isNumber: true),
          _AdminField(controller: endHC, hint: 'End hour (0–23)', isNumber: true),
          _AdminField(controller: endMC, hint: 'End minute (0–59)', isNumber: true),
          _AdminField(controller: sortC, hint: 'Sort order', isNumber: true),
        ],
        onSave: () async {
          final name = nameC.text;
          final sH = int.tryParse(startHC.text);
          final sM = int.tryParse(startMC.text);
          final eH = int.tryParse(endHC.text);
          final eM = int.tryParse(endMC.text);
          final sort = int.tryParse(sortC.text) ?? p.sortOrder;
          if (name.isEmpty || sH == null || sM == null || eH == null || eM == null) return;
          await DatabaseHelper.instance.updatePeriod(Period(
            id: p.id,
            name: name,
            startHour: sH,
            startMinute: sM,
            endHour: eH,
            endMinute: eM,
            sortOrder: sort,
          ));
          if (mounted) {
            Navigator.of(context).pop();
            _load();
          }
        },
      ),
    );
  }
}

// ─── Music Tab ──────────────────────────────────────────────────────────────

class _MusicTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        final tracks = dp.musicTracks;
        return Column(
          children: [
            // Now playing
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BISLColors.bgMidBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dp.musicEnabled
                      ? BISLColors.schoolGold.withOpacity(0.3)
                      : BISLColors.glassBorder,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        dp.musicEnabled ? Icons.music_note : Icons.music_off,
                        color: dp.musicEnabled
                            ? BISLColors.glowGold
                            : BISLColors.textMuted,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NOW PLAYING',
                              style: TextStyle(
                                fontFamily: AppFonts.heading,
                                fontSize: 10,
                                color: BISLColors.textMuted,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dp.currentTrackName,
                              style: const TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 14,
                                color: BISLColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next,
                            color: BISLColors.glowBlue),
                        onPressed: dp.musicEnabled ? () => dp.skipTrack() : null,
                        tooltip: 'Skip',
                      ),
                      Switch(
                        value: dp.musicEnabled,
                        activeColor: BISLColors.schoolGold,
                        onChanged: (v) => dp.setMusicEnabled(v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Rescan button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await dp.rescanMusic();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Found ${dp.musicTracks.length} track(s)'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Rescan Music Files'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BISLColors.glowBlue,
                    side: BorderSide(
                        color: BISLColors.glowBlue.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Track list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'PLAYLIST (${tracks.length} tracks)',
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontSize: 11,
                      color: BISLColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: tracks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.library_music,
                              color: BISLColors.textMuted, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No music files found',
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              color: BISLColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add .mp3 files to BISL_Display/music folder',
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 12,
                              color: BISLColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: tracks.length,
                      itemBuilder: (_, i) {
                        final t = tracks[i];
                        final isCurrent =
                            MusicService.instance.currentTrack?.path == t.path;
                        return Card(
                          color: isCurrent
                              ? BISLColors.schoolGold.withOpacity(0.12)
                              : BISLColors.bgMidBlue,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: isCurrent
                                ? BorderSide(
                                    color:
                                        BISLColors.schoolGold.withOpacity(0.4))
                                : BorderSide.none,
                          ),
                          child: ListTile(
                            leading: Icon(
                              isCurrent
                                  ? Icons.equalizer
                                  : Icons.audio_file,
                              color: isCurrent
                                  ? BISLColors.glowGold
                                  : BISLColors.textMuted,
                            ),
                            title: Text(
                              t.name,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 13,
                                color: isCurrent
                                    ? BISLColors.textPrimary
                                    : BISLColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              t.source == TrackSource.asset
                                  ? 'Built-in'
                                  : 'External',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 10,
                                color: BISLColors.textMuted,
                              ),
                            ),
                            trailing: t.source == TrackSource.file
                                ? IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: BISLColors.periodRed, size: 20),
                                    onPressed: () {
                                      MusicService.instance.removeTrack(i);
                                      dp.rescanMusic();
                                    },
                                    tooltip: 'Remove',
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Settings Tab ───────────────────────────────────────────────────────────

class _SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayProvider>(
      builder: (context, dp, _) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _settingTile(
              icon: Icons.timer,
              title: 'Slide Transition Time',
              subtitle: '${dp.slideSeconds} seconds (5–60)',
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: dp.slideSeconds.toDouble(),
                  min: AppConstants.minSlideSeconds.toDouble(),
                  max: AppConstants.maxSlideSeconds.toDouble(),
                  divisions: (AppConstants.maxSlideSeconds - AppConstants.minSlideSeconds),
                  activeColor: BISLColors.schoolGold,
                  label: '${dp.slideSeconds}s',
                  onChanged: (v) => dp.setSlideSeconds(v.round()),
                ),
              ),
            ),
            const Divider(color: BISLColors.glassBorder),
            _settingTile(
              icon: Icons.music_note,
              title: 'Background Music',
              subtitle: 'Enable/disable ambient music playback',
              trailing: Switch(
                value: dp.musicEnabled,
                activeColor: BISLColors.schoolGold,
                onChanged: (v) => dp.setMusicEnabled(v),
              ),
            ),
            const Divider(color: BISLColors.glassBorder),
            _settingTile(
              icon: Icons.restore,
              title: 'Reset All Data',
              subtitle: 'Restore all content to factory defaults',
              trailing: IconButton(
                icon: const Icon(Icons.restore, color: BISLColors.periodRed),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: BISLColors.bgMidBlue,
                      title: const Text('Reset All Data?',
                          style: TextStyle(color: BISLColors.textPrimary)),
                      content: const Text(
                        'This will delete all custom content and restore defaults.',
                        style: TextStyle(color: BISLColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset',
                              style: TextStyle(color: BISLColors.periodRed)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await DatabaseHelper.instance.resetToDefaults();
                    if (context.mounted) {
                      dp.reload();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data reset to defaults')),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: BISLColors.textSecondary),
      title: Text(title,
          style: const TextStyle(
              color: BISLColors.textPrimary, fontFamily: AppFonts.body)),
      subtitle: Text(subtitle,
          style:
              const TextStyle(color: BISLColors.textMuted, fontSize: 12)),
      trailing: trailing,
    );
  }
}

// ─── Reusable Admin Widgets ─────────────────────────────────────────────────

Widget _addButton({required VoidCallback onPressed}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add New'),
        style: OutlinedButton.styleFrom(
          foregroundColor: BISLColors.schoolGold,
          side: BorderSide(color: BISLColors.schoolGold.withOpacity(0.4)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ),
  );
}

class _AdminListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _AdminListTile({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: BISLColors.bgMidBlue,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 13,
            color: isActive ? BISLColors.textPrimary : BISLColors.textMuted,
            decoration: isActive ? null : TextDecoration.lineThrough,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11,
              color: BISLColors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isActive ? Icons.visibility : Icons.visibility_off,
                color: isActive ? BISLColors.glowGreen : BISLColors.textMuted,
                size: 20,
              ),
              onPressed: onToggle,
              tooltip: isActive ? 'Deactivate' : 'Activate',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: BISLColors.periodRed, size: 20),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDialog extends StatelessWidget {
  final String title;
  final List<_AdminField> fields;
  final Widget? extra;
  final VoidCallback onSave;

  const _AdminDialog({
    required this.title,
    required this.fields,
    this.extra,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BISLColors.bgMidBlue,
      title: Text(title,
          style: const TextStyle(
              fontFamily: AppFonts.heading,
              color: BISLColors.textPrimary,
              fontSize: 16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...fields.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: f.controller,
                    keyboardType: f.isNumber
                        ? TextInputType.number
                        : TextInputType.text,
                    inputFormatters: f.isNumber
                        ? [FilteringTextInputFormatter.digitsOnly]
                        : null,
                    style: const TextStyle(
                        color: BISLColors.textPrimary, fontSize: 14),
                    maxLines: f.isNumber ? 1 : 3,
                    decoration: InputDecoration(
                      hintText: f.hint,
                      hintStyle: TextStyle(color: BISLColors.textMuted),
                      filled: true,
                      fillColor: BISLColors.bgDeepNavy,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: BISLColors.glassBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: BISLColors.glassBorder),
                      ),
                    ),
                  ),
                )),
            if (extra != null) extra!,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: BISLColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: BISLColors.royalBlue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _AdminField {
  final TextEditingController controller;
  final String hint;
  final bool isNumber;

  const _AdminField({
    required this.controller,
    required this.hint,
    this.isNumber = false,
  });
}
