import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/prayer_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class PrayerScheduleScreen extends StatefulWidget {
  const PrayerScheduleScreen({super.key});

  @override
  State<PrayerScheduleScreen> createState() => _PrayerScheduleScreenState();
}

class _PrayerScheduleScreenState extends State<PrayerScheduleScreen> {
  bool _simulateNetworkError = false;

  Future<void> _handleSync() async {
    final state = AppStateScope.of(context);
    try {
      final result = await state.syncPrayerSchedule(
        simulateOfflineError: _simulateNetworkError,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text(result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.warning,
            size: 36,
          ),
          title: const Text('Koneksi Terputus'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Gunakan Jadwal Lokal'),
            ),
          ],
        ),
      );
    }
  }

  void _showAdzanTestDialog(PrayerTimeItem prayer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.notifications_active_rounded,
          color: AppColors.primary,
          size: 40,
        ),
        title: Text('Pengingat Waktu ${prayer.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Telah masuk waktu sholat ${prayer.name} (${prayer.formattedTime}) untuk wilayah ${AppStateScope.of(context).selectedCity}.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Mode Notifikasi Aktif: Mari segerakan wudhu dan tunaikan sholat tepat waktu.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Siap, Saya Sholat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final prayers = state.currentPrayers;
    final nextId = state.nextPrayerInfo.prayer.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal & Pengingat Sholat'),
        actions: [
          IconButton(
            tooltip: 'Sinkronkan Jadwal',
            onPressed: state.isSyncing ? null : _handleSync,
            icon: state.isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // City selector & offline simulation control
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: state.selectedCity,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Wilayah / Kota',
                          prefixIcon: Icon(Icons.location_on_rounded),
                        ),
                        items: DummyData.availableCities
                            .map(
                              (city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            state.changeCity(value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Simulasi Mode Offline (Uji Error Handling)',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Aktifkan untuk menguji penanganan koneksi terputus saat sinkronisasi',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _simulateNetworkError,
                        onChanged: (val) {
                          setState(() => _simulateNetworkError = val);
                        },
                      ),
                      if (state.lastSyncMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            state.lastSyncMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Waktu Sholat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${state.activePrayerRemindersCount} pengingat aktif',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prayers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final prayer = prayers[index];
                  final isNext = prayer.id == nextId;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isNext
                            ? AppColors.gold
                            : AppColors.primary.withValues(alpha: 0.08),
                        width: isNext ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isNext
                                      ? AppColors.goldSoft
                                      : AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  prayer.isReminderEnabled
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_off_outlined,
                                  color: isNext
                                      ? AppColors.warning
                                      : AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          prayer.name,
                                          style: const TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          prayer.arabicName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (isNext) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.goldSoft,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Berikutnya',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.warning,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${prayer.formattedTime} WIB • ${prayer.mode.label}',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: prayer.isReminderEnabled,
                                activeThumbColor: AppColors.primary,
                                onChanged: (_) {
                                  state.togglePrayerReminder(prayer.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 1),
                                      content: Text(
                                        prayer.isReminderEnabled
                                            ? 'Pengingat ${prayer.name} diaktifkan'
                                            : 'Pengingat ${prayer.name} dimatikan',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton<NotificationMode>(
                                value: prayer.mode,
                                underline: const SizedBox.shrink(),
                                isDense: true,
                                items: NotificationMode.values
                                    .map(
                                      (mode) => DropdownMenuItem(
                                        value: mode,
                                        child: Text(
                                          mode.label,
                                          style: const TextStyle(fontSize: 12.5),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (mode) {
                                  if (mode != null) {
                                    state.changePrayerNotificationMode(
                                      prayer.id,
                                      mode,
                                    );
                                  }
                                },
                              ),
                              TextButton.icon(
                                onPressed: () => _showAdzanTestDialog(prayer),
                                icon: const Icon(Icons.volume_up_rounded, size: 18),
                                label: const Text(
                                  'Uji Pengingat',
                                  style: TextStyle(fontSize: 12.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
