import '../models/models.dart';
import 'education_history_data.dart';

// ─── Seed Data ────────────────────────────────────────────────────────────────
// Pre-loaded content for the BISL digital signage display.
// Admin can add / edit / deactivate entries from the admin panel.

class SeedData {
  SeedData._();

  // ── Inspirational Quotes ──────────────────────────────────────────────────

  static const List<Quote> quotes = [
    Quote(
      text: 'Education is the most powerful weapon which you can use to change the world.',
      author: 'Nelson Mandela',
    ),
    Quote(
      text: 'The future belongs to those who believe in the beauty of their dreams.',
      author: 'Eleanor Roosevelt',
    ),
    Quote(
      text: 'It does not matter how slowly you go as long as you do not stop.',
      author: 'Confucius',
    ),
    Quote(
      text: 'The only way to do great work is to love what you do.',
      author: 'Steve Jobs',
    ),
    Quote(
      text: 'In the middle of difficulty lies opportunity.',
      author: 'Albert Einstein',
    ),
    Quote(
      text: 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      author: 'Winston Churchill',
    ),
    Quote(
      text: 'Tell me and I forget. Teach me and I remember. Involve me and I learn.',
      author: 'Benjamin Franklin',
    ),
    Quote(
      text: 'The beautiful thing about learning is that nobody can take it away from you.',
      author: 'B.B. King',
    ),
    Quote(
      text: 'Intelligence plus character — that is the goal of true education.',
      author: 'Martin Luther King Jr.',
    ),
    Quote(
      text: 'Live as if you were to die tomorrow. Learn as if you were to live forever.',
      author: 'Mahatma Gandhi',
    ),
    Quote(
      text: 'The mind is not a vessel to be filled, but a fire to be kindled.',
      author: 'Plutarch',
    ),
    Quote(
      text: 'An investment in knowledge pays the best interest.',
      author: 'Benjamin Franklin',
    ),
    Quote(
      text: 'The roots of education are bitter, but the fruit is sweet.',
      author: 'Aristotle',
    ),
    Quote(
      text: 'Strive not to be a success, but rather to be of value.',
      author: 'Albert Einstein',
    ),
    Quote(
      text: 'What we learn with pleasure we never forget.',
      author: 'Alfred Mercier',
    ),
    Quote(
      text: 'The capacity to learn is a gift; the ability to learn is a skill; the willingness to learn is a choice.',
      author: 'Brian Herbert',
    ),
    Quote(
      text: 'Believe you can and you\'re halfway there.',
      author: 'Theodore Roosevelt',
    ),
    Quote(
      text: 'Science is a way of thinking much more than it is a body of knowledge.',
      author: 'Carl Sagan',
    ),
    Quote(
      text: 'I have no special talents. I am only passionately curious.',
      author: 'Albert Einstein',
    ),
    Quote(
      text: 'The only limit to our realisation of tomorrow will be our doubts of today.',
      author: 'Franklin D. Roosevelt',
    ),
  ];

  // ── Fun / Educational Facts ───────────────────────────────────────────────

  static const List<Fact> facts = [
    // Global
    Fact(text: 'Honey never spoils — archaeologists have found 3,000-year-old honey in Egyptian tombs that was still edible.', category: 'global'),
    Fact(text: 'Octopuses have three hearts and blue blood.', category: 'global'),
    Fact(text: 'A day on Venus is longer than a year on Venus.', category: 'global'),
    Fact(text: 'Bananas are berries, but strawberries are not.', category: 'global'),
    Fact(text: 'The Eiffel Tower can grow up to 15 cm taller in summer due to heat expansion.', category: 'global'),
    Fact(text: 'Water can boil and freeze at the same time — it\'s called the triple point.', category: 'global'),
    Fact(text: 'There are more possible chess games than atoms in the observable universe.', category: 'global'),
    Fact(text: 'The human brain uses about 20% of the body\'s total energy.', category: 'global'),
    Fact(text: 'Light takes about 8 minutes and 20 seconds to travel from the Sun to Earth.', category: 'global'),
    Fact(text: 'The Great Wall of China is not visible from space with the naked eye, but city lights are.', category: 'global'),
    Fact(text: 'A group of flamingos is called a "flamboyance."', category: 'global'),
    Fact(text: 'Shakespeare invented over 1,700 words in the English language.', category: 'global'),
    Fact(text: 'The speed of light is approximately 299,792,458 metres per second.', category: 'global'),
    Fact(text: 'Gravity on Mars is about 37% of Earth\'s — you could jump nearly three times higher.', category: 'global'),
    Fact(text: 'The Amazon Rainforest produces about 20% of the world\'s oxygen.', category: 'global'),

    // DRC-specific
    Fact(text: 'The DRC is the largest country in sub-Saharan Africa by area — over 2.3 million km².', category: 'drc'),
    Fact(text: 'The Congo River is the deepest river in the world, reaching depths of over 220 metres.', category: 'drc'),
    Fact(text: 'The DRC is home to the okapi — often called the "forest giraffe," found nowhere else on Earth.', category: 'drc'),
    Fact(text: 'Lubumbashi is the second-largest city in the DRC and the mining capital of the Copperbelt.', category: 'drc'),
    Fact(text: 'The DRC has the world\'s second-largest rainforest, after the Amazon.', category: 'drc'),
    Fact(text: 'Virunga National Park in the DRC is Africa\'s oldest national park, established in 1925.', category: 'drc'),
    Fact(text: 'Over 200 languages are spoken in the DRC, making it one of the most linguistically diverse countries.', category: 'drc'),
    Fact(text: 'The DRC contains about 70% of the world\'s coltan, essential for making smartphones.', category: 'drc'),
    Fact(text: 'Lake Tanganyika, bordering the DRC, is the longest freshwater lake in the world.', category: 'drc'),
    Fact(text: 'Mount Nyiragongo in the DRC has one of the few permanent lava lakes on Earth.', category: 'drc'),
  ];

  // ── Word of the Day ───────────────────────────────────────────────────────

  static const List<Word> words = [
    Word(word: 'Ephemeral', phonetic: '/ɪˈfɛm.ər.əl/', definition: 'Lasting for only a short period of time.', example: 'The ephemeral beauty of the sunset left everyone speechless.'),
    Word(word: 'Ubiquitous', phonetic: '/juːˈbɪk.wɪ.təs/', definition: 'Present, appearing, or found everywhere.', example: 'Smartphones have become ubiquitous in modern life.'),
    Word(word: 'Resilience', phonetic: '/rɪˈzɪl.i.əns/', definition: 'The capacity to recover quickly from difficulties.', example: 'Her resilience after the setback inspired the whole team.'),
    Word(word: 'Serendipity', phonetic: '/ˌsɛr.ənˈdɪp.ɪ.ti/', definition: 'The occurrence of events by chance in a happy way.', example: 'Finding that book in the library was pure serendipity.'),
    Word(word: 'Eloquent', phonetic: '/ˈɛl.ə.kwənt/', definition: 'Fluent or persuasive in speaking or writing.', example: 'The student gave an eloquent speech at the assembly.'),
    Word(word: 'Perseverance', phonetic: '/ˌpɜː.sɪˈvɪə.rəns/', definition: 'Persistence in doing something despite difficulty.', example: 'Perseverance is the key to achieving long-term goals.'),
    Word(word: 'Enigma', phonetic: '/ɪˈnɪɡ.mə/', definition: 'A person or thing that is mysterious or difficult to understand.', example: 'The origin of the ancient artefact remains an enigma.'),
    Word(word: 'Altruism', phonetic: '/ˈæl.tru.ɪ.zəm/', definition: 'Selfless concern for the well-being of others.', example: 'Acts of altruism can transform communities.'),
    Word(word: 'Catalyst', phonetic: '/ˈkæt.əl.ɪst/', definition: 'A person or thing that precipitates a change.', example: 'The new teacher was a catalyst for positive change.'),
    Word(word: 'Meticulous', phonetic: '/məˈtɪk.jʊ.ləs/', definition: 'Showing great attention to detail; very careful.', example: 'Her meticulous notes helped the whole class revise.'),
    Word(word: 'Paradigm', phonetic: '/ˈpær.ə.daɪm/', definition: 'A typical example or model of something.', example: 'The internet created a new paradigm in communication.'),
    Word(word: 'Benevolent', phonetic: '/bəˈnɛv.ə.lənt/', definition: 'Well-meaning and kindly.', example: 'The benevolent donor funded scholarships for ten students.'),
    Word(word: 'Tenacious', phonetic: '/tɪˈneɪ.ʃəs/', definition: 'Holding firmly to something; persistent.', example: 'The tenacious athlete trained through every challenge.'),
    Word(word: 'Ambiguity', phonetic: '/ˌæm.bɪˈɡjuː.ɪ.ti/', definition: 'The quality of being open to more than one interpretation.', example: 'The poem\'s ambiguity sparked a lively classroom debate.'),
    Word(word: 'Empirical', phonetic: '/ɪmˈpɪr.ɪ.kəl/', definition: 'Based on observation or experience rather than theory.', example: 'The scientist relied on empirical evidence to support her hypothesis.'),
    Word(word: 'Synergy', phonetic: '/ˈsɪn.ər.dʒi/', definition: 'The interaction of elements that produces a combined effect greater than the sum of their separate effects.', example: 'The synergy between art and science led to a breakthrough invention.'),
    Word(word: 'Profound', phonetic: '/prəˈfaʊnd/', definition: 'Very great or intense; having deep meaning.', example: 'The lecture had a profound impact on every listener.'),
    Word(word: 'Conundrum', phonetic: '/kəˈnʌn.drəm/', definition: 'A confusing and difficult problem or question.', example: 'Climate change presents a conundrum for policymakers.'),
    Word(word: 'Integrity', phonetic: '/ɪnˈtɛɡ.rɪ.ti/', definition: 'The quality of being honest and having strong moral principles.', example: 'A leader\'s integrity is more valuable than talent alone.'),
    Word(word: 'Pinnacle', phonetic: '/ˈpɪn.ə.kəl/', definition: 'The most successful point; the culmination.', example: 'Graduating with honours was the pinnacle of her academic journey.'),
  ];

  // ── On This Day — Historical Events ───────────────────────────────────────
  // 365-day education & science history — loaded from EducationHistoryData.
  static const List<HistoryEvent> historyEvents = EducationHistoryData.events;

  // ── School Bell / Period Schedule ─────────────────────────────────────────
  // Based on the BISL timetable: 8 periods + 2 breaks

  static const List<Period> periods = [
    Period(name: 'Period 1', startHour: 8, startMinute: 0, endHour: 8, endMinute: 45, sortOrder: 0),
    Period(name: 'Period 2', startHour: 8, startMinute: 45, endHour: 9, endMinute: 30, sortOrder: 1),
    Period(name: 'Period 3', startHour: 9, startMinute: 30, endHour: 10, endMinute: 15, sortOrder: 2),
    Period(name: 'Period 4', startHour: 10, startMinute: 15, endHour: 11, endMinute: 0, sortOrder: 3),
    Period(name: 'First Break', startHour: 11, startMinute: 0, endHour: 11, endMinute: 30, sortOrder: 4),
    Period(name: 'Period 5', startHour: 11, startMinute: 30, endHour: 12, endMinute: 15, sortOrder: 5),
    Period(name: 'Period 6', startHour: 12, startMinute: 15, endHour: 13, endMinute: 0, sortOrder: 6),
    Period(name: 'Second Break', startHour: 13, startMinute: 0, endHour: 13, endMinute: 45, sortOrder: 7),
    Period(name: 'Period 7', startHour: 13, startMinute: 45, endHour: 14, endMinute: 15, sortOrder: 8),
    Period(name: 'Period 8', startHour: 14, startMinute: 15, endHour: 15, endMinute: 0, sortOrder: 9),
  ];

  // ── Upcoming School Events ────────────────────────────────────────────────
  // Pre-filled from the BISL calendar (Mar–Aug 2026). Admin can edit/add more.

  static final List<SchoolEvent> schoolEvents = [
    // March 2026
    SchoolEvent(title: 'International Women\'s Day', eventDate: DateTime(2026, 3, 8)),
    SchoolEvent(title: 'Laylat-ul-Qadr Holiday', eventDate: DateTime(2026, 3, 11)),
    SchoolEvent(title: 'Eid ul Fitr / Navroz Holiday', eventDate: DateTime(2026, 3, 20)),
    SchoolEvent(title: '2nd Term Exam (Year 1–12) & 2nd Mock Exam (Year 13)', eventDate: DateTime(2026, 3, 23)),

    // April 2026
    SchoolEvent(title: 'Report Card Day', eventDate: DateTime(2026, 4, 2)),
    SchoolEvent(title: 'Easter Break Begins', eventDate: DateTime(2026, 4, 3)),
    SchoolEvent(title: 'School Reopens for 3rd Term', eventDate: DateTime(2026, 4, 8)),
    SchoolEvent(title: 'Picnic — EYFS', eventDate: DateTime(2026, 4, 17)),
    SchoolEvent(title: 'International Mother Earth Day', eventDate: DateTime(2026, 4, 22)),
    SchoolEvent(title: 'EYFS Fancy Dress Competition', eventDate: DateTime(2026, 4, 25)),
    SchoolEvent(title: 'Primary & Secondary Dance Competition', eventDate: DateTime(2026, 4, 25)),
    SchoolEvent(title: 'Picnic — Primary & Secondary', eventDate: DateTime(2026, 4, 30)),

    // May 2026
    SchoolEvent(title: 'International Labour Day', eventDate: DateTime(2026, 5, 1)),
    SchoolEvent(title: 'Maths & Science Challenge — Primary', eventDate: DateTime(2026, 5, 8)),
    SchoolEvent(title: 'Sports Day — EYFS', eventDate: DateTime(2026, 5, 8)),
    SchoolEvent(title: 'Spirit Week', eventDate: DateTime(2026, 5, 11)),
    SchoolEvent(title: 'Sports Day — Primary & Secondary', eventDate: DateTime(2026, 5, 15)),
    SchoolEvent(title: 'BISL MYP Theatre Show', eventDate: DateTime(2026, 5, 16)),
    SchoolEvent(title: 'Revolution Day', eventDate: DateTime(2026, 5, 17)),
    SchoolEvent(title: 'Parent Teachers\' Conference — EYFS & Primary', eventDate: DateTime(2026, 5, 23)),
    SchoolEvent(title: 'MYP & DP Student Led Conference (SLC)', eventDate: DateTime(2026, 5, 23)),
    SchoolEvent(title: 'Eid ul Adha Holiday', eventDate: DateTime(2026, 5, 27)),

    // June 2026
    SchoolEvent(title: 'Final Exam — Year 1 to Year 12', eventDate: DateTime(2026, 6, 8)),
    SchoolEvent(title: 'Graduation Day — EYFS & Year 13', eventDate: DateTime(2026, 6, 19)),
    SchoolEvent(title: 'Certificate Distribution & Student of the Year Awards', eventDate: DateTime(2026, 6, 20)),
    SchoolEvent(title: 'Report Card Day', eventDate: DateTime(2026, 6, 20)),
    SchoolEvent(title: 'Summer Holidays Begin', eventDate: DateTime(2026, 6, 22)),
  ];
}
