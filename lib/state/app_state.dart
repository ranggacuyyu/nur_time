import 'dart:async';
import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/dzikir_model.dart';
import '../models/ngaji_model.dart';
import '../models/prayer_model.dart';

class AppStateController extends ChangeNotifier {
  // User & Session State
  bool _isLoggedIn = false;
  String _userName = 'Muhammad Rangga';
  String _userNim = '4342501025';
  String _selectedCity = 'Batam';
  int _dailyTargetAyat = 50;

  // Prayer Schedule State
  late Map<String, List<PrayerTimeItem>> _citySchedules;
  DateTime _currentTime = DateTime.now();
  Timer? _clockTimer;
  bool _isSyncing = false;
  String? _lastSyncMessage;

  // Ngaji & Worship State
  late List<TilawahLog> _tilawahLogs;
  late List<NgajiRoutineReminder> _ngajiReminders;
  late List<DailyWorshipTarget> _dailyTargets;

  // Tasbih Digital State
  int _selectedDzikirIndex = 0;
  int _tasbihCount = 0;
  int _tasbihTarget = 33;
  int _totalDailyDzikir = 12;

  AppStateController({bool startTimer = true}) {
    _citySchedules = DummyData.createCityPrayerSchedules();
    _tilawahLogs = DummyData.initialTilawahLogs();
    _ngajiReminders = DummyData.initialNgajiReminders();
    _dailyTargets = DummyData.initialDailyTargets();

    if (startTimer) {
      _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _currentTime = DateTime.now();
        notifyListeners();
      });
    }
  }

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userNim => _userNim;
  String get selectedCity => _selectedCity;
  int get dailyTargetAyat => _dailyTargetAyat;
  DateTime get currentTime => _currentTime;
  bool get isSyncing => _isSyncing;
  String? get lastSyncMessage => _lastSyncMessage;

  List<PrayerTimeItem> get currentPrayers =>
      _citySchedules[_selectedCity] ?? _citySchedules['Batam']!;

  List<TilawahLog> get tilawahLogs => List.unmodifiable(_tilawahLogs);
  List<NgajiRoutineReminder> get ngajiReminders =>
      List.unmodifiable(_ngajiReminders);
  List<DailyWorshipTarget> get dailyTargets => List.unmodifiable(_dailyTargets);

  int get totalAyatReadToday {
    return _tilawahLogs.fold<int>(0, (sum, log) => sum + log.ayatCount);
  }

  double get dailyNgajiProgress {
    if (_dailyTargetAyat <= 0) return 0;
    return (totalAyatReadToday / _dailyTargetAyat).clamp(0.0, 1.0);
  }

  int get completedTargetsCount =>
      _dailyTargets.where((item) => item.isCompleted).length;

  int get activePrayerRemindersCount =>
      currentPrayers.where((p) => p.isReminderEnabled).length;

  DzikirItem get activeTasbihDzikir =>
      DummyData.dzikirList[_selectedDzikirIndex];
  int get selectedDzikirIndex => _selectedDzikirIndex;
  int get tasbihCount => _tasbihCount;
  int get tasbihTarget => _tasbihTarget;
  int get totalDailyDzikir => _totalDailyDzikir;

  NextPrayerInfo get nextPrayerInfo {
    final prayers = currentPrayers.where((p) => p.isFardhu).toList();
    final now = _currentTime;

    PrayerTimeItem? upcoming;
    DateTime? upcomingTime;
    DateTime previousTime = DateTime(now.year, now.month, now.day, 0, 0);
    String previousName = 'Isya';

    for (int i = 0; i < prayers.length; i++) {
      final candidateTime = prayers[i].toDateTime(now);
      if (candidateTime.isAfter(now)) {
        upcoming = prayers[i];
        upcomingTime = candidateTime;
        if (i > 0) {
          previousTime = prayers[i - 1].toDateTime(now);
          previousName = prayers[i - 1].name;
        } else {
          final yesterdayIsya = prayers.last.toDateTime(
            now.subtract(const Duration(days: 1)),
          );
          previousTime = yesterdayIsya;
          previousName = prayers.last.name;
        }
        break;
      }
    }

    if (upcoming == null || upcomingTime == null) {
      // All today's prayers have passed; next is tomorrow's Subuh
      upcoming = prayers.first;
      upcomingTime = upcoming.toDateTime(now.add(const Duration(days: 1)));
      previousTime = prayers.last.toDateTime(now);
      previousName = prayers.last.name;
    }

    final totalInterval = upcomingTime.difference(previousTime).inSeconds;
    final elapsed = now.difference(previousTime).inSeconds;
    final double progress =
        totalInterval > 0 ? (elapsed / totalInterval).clamp(0.0, 1.0) : 0.0;

    return NextPrayerInfo(
      prayer: upcoming,
      remaining: upcomingTime.difference(now),
      progressToNext: progress,
      previousPrayerName: previousName,
    );
  }

  // Auth Actions
  void login({
    required String name,
    required String nim,
    required String city,
  }) {
    _userName = name.trim();
    _userNim = nim.trim().isEmpty ? '4342501025' : nim.trim();
    if (DummyData.availableCities.contains(city)) {
      _selectedCity = city;
    }
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String city,
    required int dailyTargetAyat,
  }) {
    _userName = name.trim();
    _selectedCity = city;
    _dailyTargetAyat = dailyTargetAyat;
    notifyListeners();
  }

  // Prayer Actions
  void changeCity(String city) {
    if (_citySchedules.containsKey(city)) {
      _selectedCity = city;
      notifyListeners();
    }
  }

  void togglePrayerReminder(String prayerId) {
    final list = currentPrayers;
    final index = list.indexWhere((p) => p.id == prayerId);
    if (index != -1) {
      list[index].isReminderEnabled = !list[index].isReminderEnabled;
      notifyListeners();
    }
  }

  void changePrayerNotificationMode(String prayerId, NotificationMode mode) {
    final list = currentPrayers;
    final index = list.indexWhere((p) => p.id == prayerId);
    if (index != -1) {
      list[index].mode = mode;
      notifyListeners();
    }
  }

  /// Demonstrates structured exception handling for network sync / offline fallback.
  Future<String> syncPrayerSchedule({required bool simulateOfflineError}) async {
    _isSyncing = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      if (simulateOfflineError) {
        throw Exception(
          'Koneksi internet terputus. Aplikasi otomatis menggunakan jadwal lokal tersimpan untuk $_selectedCity.',
        );
      }
      _lastSyncMessage =
          'Jadwal $_selectedCity diperbarui pada ${TimeOfDay.fromDateTime(DateTime.now()).hour.toString().padLeft(2, '0')}:${TimeOfDay.fromDateTime(DateTime.now()).minute.toString().padLeft(2, '0')}';
      return _lastSyncMessage!;
    } catch (e) {
      _lastSyncMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Ngaji Actions
  void addTilawahLog({
    required String surahName,
    required int startAyat,
    required int endAyat,
    String note = '',
  }) {
    final newLog = TilawahLog(
      id: 'log-${DateTime.now().microsecondsSinceEpoch}',
      surahName: surahName,
      startAyat: startAyat,
      endAyat: endAyat,
      timestamp: DateTime.now(),
      note: note.trim(),
    );
    _tilawahLogs.insert(0, newLog);
    notifyListeners();
  }

  void deleteTilawahLog(String id) {
    _tilawahLogs.removeWhere((log) => log.id == id);
    notifyListeners();
  }

  void toggleNgajiReminder(String id) {
    final index = _ngajiReminders.indexWhere((item) => item.id == id);
    if (index != -1) {
      _ngajiReminders[index].isEnabled = !_ngajiReminders[index].isEnabled;
      notifyListeners();
    }
  }

  void updateNgajiReminderTime(String id, String newTimeLabel) {
    final index = _ngajiReminders.indexWhere((item) => item.id == id);
    if (index != -1) {
      final old = _ngajiReminders[index];
      _ngajiReminders[index] = NgajiRoutineReminder(
        id: old.id,
        title: old.title,
        subtitle: old.subtitle,
        timeLabel: newTimeLabel,
        isEnabled: old.isEnabled,
      );
      notifyListeners();
    }
  }

  void toggleDailyTarget(String id) {
    final index = _dailyTargets.indexWhere((item) => item.id == id);
    if (index != -1) {
      _dailyTargets[index].isCompleted = !_dailyTargets[index].isCompleted;
      notifyListeners();
    }
  }

  // Tasbih Actions
  void selectTasbihDzikir(int index) {
    if (index >= 0 && index < DummyData.dzikirList.length) {
      _selectedDzikirIndex = index;
      _tasbihCount = 0;
      final rec = DummyData.dzikirList[index].recommendedCount;
      _tasbihTarget = rec > 1 ? rec : 33;
      notifyListeners();
    }
  }

  void setTasbihTarget(int target) {
    if (target > 0) {
      _tasbihTarget = target;
      notifyListeners();
    }
  }

  bool incrementTasbih() {
    _tasbihCount++;
    _totalDailyDzikir++;
    final bool targetReached = _tasbihCount == _tasbihTarget;
    notifyListeners();
    return targetReached;
  }

  void resetTasbih() {
    _tasbihCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}

class AppStateScope extends InheritedNotifier<AppStateController> {
  const AppStateScope({
    super.key,
    required AppStateController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppStateController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope tidak ditemukan dalam widget tree.');
    return scope!.notifier!;
  }
}
