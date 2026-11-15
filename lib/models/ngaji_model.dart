class SurahItem {
  final int number;
  final String name;
  final String arabicName;
  final String meaning;
  final int totalAyat;
  final String revelationPlace;
  final String virtue;
  final String sampleArabic;
  final String sampleLatin;
  final String sampleTranslation;

  const SurahItem({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.meaning,
    required this.totalAyat,
    required this.revelationPlace,
    required this.virtue,
    required this.sampleArabic,
    required this.sampleLatin,
    required this.sampleTranslation,
  });
}

class TilawahLog {
  final String id;
  final String surahName;
  final int startAyat;
  final int endAyat;
  final DateTime timestamp;
  final String note;

  const TilawahLog({
    required this.id,
    required this.surahName,
    required this.startAyat,
    required this.endAyat,
    required this.timestamp,
    this.note = '',
  });

  int get ayatCount => (endAyat - startAyat) + 1;
}

class NgajiRoutineReminder {
  final String id;
  final String title;
  final String subtitle;
  final String timeLabel;
  bool isEnabled;

  NgajiRoutineReminder({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    this.isEnabled = true,
  });
}

class DailyWorshipTarget {
  final String id;
  final String title;
  final String category;
  bool isCompleted;

  DailyWorshipTarget({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
  });
}
