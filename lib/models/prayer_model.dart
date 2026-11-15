enum NotificationMode {
  adzan('Suara Adzan'),
  vibrate('Getar Saja'),
  silent('Senyap');

  final String label;
  const NotificationMode(this.label);
}

class PrayerTimeItem {
  final String id;
  final String name;
  final String arabicName;
  final int hour;
  final int minute;
  final bool isFardhu;
  bool isReminderEnabled;
  NotificationMode mode;

  PrayerTimeItem({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.hour,
    required this.minute,
    this.isFardhu = true,
    this.isReminderEnabled = true,
    this.mode = NotificationMode.adzan,
  });

  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  DateTime toDateTime(DateTime referenceDate) {
    return DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
      hour,
      minute,
    );
  }

  PrayerTimeItem copyWith({
    int? hour,
    int? minute,
    bool? isReminderEnabled,
    NotificationMode? mode,
  }) {
    return PrayerTimeItem(
      id: id,
      name: name,
      arabicName: arabicName,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isFardhu: isFardhu,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      mode: mode ?? this.mode,
    );
  }
}

class NextPrayerInfo {
  final PrayerTimeItem prayer;
  final Duration remaining;
  final double progressToNext;
  final String previousPrayerName;

  const NextPrayerInfo({
    required this.prayer,
    required this.remaining,
    required this.progressToNext,
    required this.previousPrayerName,
  });

  String get formattedCountdown {
    final int hours = remaining.inHours;
    final int minutes = remaining.inMinutes.remainder(60);
    final int seconds = remaining.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
