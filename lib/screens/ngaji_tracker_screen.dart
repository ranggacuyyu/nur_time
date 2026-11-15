import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/ngaji_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'surah_detail_screen.dart';

class NgajiTrackerScreen extends StatefulWidget {
  const NgajiTrackerScreen({super.key});

  @override
  State<NgajiTrackerScreen> createState() => _NgajiTrackerScreenState();
}

class _NgajiTrackerScreenState extends State<NgajiTrackerScreen> {
  Future<void> _pickReminderTime(NgajiRoutineReminder reminder) async {
    final parts = reminder.timeLabel.split(':');
    final initialHour = int.tryParse(parts.first) ?? 5;
    final initialMin = int.tryParse(parts.last) ?? 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMin),
    );
    if (picked != null && mounted) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      AppStateScope.of(context).updateNgajiReminderTime(reminder.id, formatted);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jam pengingat ${reminder.title} diubah ke $formatted'),
        ),
      );
    }
  }

  void _openAddTilawahModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _AddTilawahSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final percent = (state.dailyNgajiProgress * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengingat & Tracker Ngaji'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_tilawah_fab'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _openAddTilawahModal,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Catat Ngaji'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Target Tilawah Harian',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$percent%',
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${state.totalAyatReadToday} dari ${state.dailyTargetAyat} Ayat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: state.dailyNgajiProgress,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.gold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Ngaji Routine Reminders
              const Text(
                'Jadwal Pengingat Rutin Ngaji',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...state.ngajiReminders.map(
                (reminder) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: reminder.isEnabled
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.grey.shade200,
                      child: Icon(
                        Icons.alarm_rounded,
                        color: reminder.isEnabled
                            ? AppColors.primary
                            : Colors.grey,
                      ),
                    ),
                    title: Text(
                      reminder.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${reminder.subtitle} • Pukul ${reminder.timeLabel}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Ubah Jam',
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _pickReminderTime(reminder),
                        ),
                        Switch(
                          value: reminder.isEnabled,
                          activeThumbColor: AppColors.primary,
                          onChanged: (_) =>
                              state.toggleNgajiReminder(reminder.id),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Daily Worship Checklist
              const Text(
                'Checklist Target Ibadah Harian',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: state.dailyTargets
                      .map(
                        (target) => CheckboxListTile(
                          value: target.isCompleted,
                          activeColor: AppColors.primary,
                          title: Text(
                            target.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: target.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            target.category,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onChanged: (_) => state.toggleDailyTarget(target.id),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Surah List Horizontal
              const Text(
                'Bacaan Surah Pilihan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 132,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: DummyData.surahList.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final surah = DummyData.surahList[index];
                    return SizedBox(
                      width: 155,
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SurahDetailScreen(surah: surah),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  surah.arabicName,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  surah.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                                Text(
                                  '${surah.totalAyat} Ayat',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Riwayat Tilawah
              const Text(
                'Riwayat Catatan Tilawah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (state.tilawahLogs.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Belum ada catatan tilawah hari ini. Tekan "Catat Ngaji" untuk memulai.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.tilawahLogs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = state.tilawahLogs[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.goldSoft,
                          foregroundColor: AppColors.primaryDark,
                          child: const Icon(Icons.menu_book_rounded, size: 20),
                        ),
                        title: Text(
                          '${log.surahName} (Ayat ${log.startAyat}–${log.endAyat})',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${log.ayatCount} ayat${log.note.isNotEmpty ? " • ${log.note}" : ""}',
                          style: const TextStyle(fontSize: 12.5),
                        ),
                        trailing: IconButton(
                          tooltip: 'Hapus catatan',
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                          ),
                          onPressed: () {
                            state.deleteTilawahLog(log.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Catatan tilawah dihapus'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
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

class _AddTilawahSheet extends StatefulWidget {
  const _AddTilawahSheet();

  @override
  State<_AddTilawahSheet> createState() => _AddTilawahSheetState();
}

class _AddTilawahSheetState extends State<_AddTilawahSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _startController = TextEditingController(text: '1');
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  SurahItem _selectedSurah = DummyData.surahList.first;

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTilawah() {
    try {
      final form = _formKey.currentState;
      if (form == null || !form.validate()) {
        return;
      }

      final startAyat = int.parse(_startController.text.trim());
      final endAyat = int.parse(_endController.text.trim());

      AppStateScope.of(context).addTilawahLog(
        surahName: _selectedSurah.name,
        startAyat: startAyat,
        endAyat: endAyat,
        note: _noteController.text,
      );

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text(
            'Tersimpan: ${_selectedSurah.name} ayat $startAyat–$endAyat',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Gagal menyimpan catatan: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Catat Progres Ngaji',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<SurahItem>(
                key: const Key('tilawah_surah_dropdown'),
                initialValue: _selectedSurah,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Pilih Surah',
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                items: DummyData.surahList
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text('${s.number}. ${s.name} (${s.totalAyat} ayat)'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSurah = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('tilawah_start_field'),
                      controller: _startController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ayat Mulai',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Wajib diisi';
                        }
                        final parsed = int.tryParse(val.trim());
                        if (parsed == null || parsed < 1) {
                          return 'Minimal 1';
                        }
                        if (parsed > _selectedSurah.totalAyat) {
                          return 'Maks ${_selectedSurah.totalAyat}';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: const Key('tilawah_end_field'),
                      controller: _endController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Ayat Selesai (Maks ${_selectedSurah.totalAyat})',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Wajib diisi';
                        }
                        final endVal = int.tryParse(val.trim());
                        if (endVal == null || endVal < 1) {
                          return 'Angka tidak valid';
                        }
                        if (endVal > _selectedSurah.totalAyat) {
                          return 'Melebihi ${_selectedSurah.totalAyat} ayat';
                        }
                        final startVal =
                            int.tryParse(_startController.text.trim()) ?? 1;
                        if (endVal < startVal) {
                          return 'Harus >= Ayat Mulai';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Contoh: Tilawah ba\'da Maghrib',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                key: const Key('tilawah_save_button'),
                onPressed: _saveTilawah,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Simpan Catatan Ngaji'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
