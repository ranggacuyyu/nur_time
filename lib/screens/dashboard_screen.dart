import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/ngaji_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/prayer_countdown_card.dart';
import 'surah_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
  });

  String _formatDate(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final nextPrayer = state.nextPrayerInfo;
    final ngajiProgress = state.dailyNgajiProgress;
    final featuredSurahs = DummyData.surahList.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assalamu\'alaikum, ${state.userName}'),
            Text(
              _formatDate(state.currentTime),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pengingat Sholat',
            onPressed: () => onNavigateTab(1),
            icon: const Icon(Icons.notifications_active_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrayerCountdownCard(
                nextPrayer: nextPrayer,
                city: state.selectedCity,
                onScheduleTap: () => onNavigateTab(1),
              ),
              const SizedBox(height: 16),

              // Summary stats row (responsive with LayoutBuilder)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 540;
                  final cards = [
                    _QuickStatCard(
                      icon: Icons.menu_book_rounded,
                      iconColor: AppColors.primary,
                      title: 'Tilawah Hari Ini',
                      value:
                          '${state.totalAyatReadToday} / ${state.dailyTargetAyat} ayat',
                      progress: ngajiProgress,
                      onTap: () => onNavigateTab(2),
                    ),
                    _QuickStatCard(
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: AppColors.gold,
                      title: 'Checklist Ibadah',
                      value:
                          '${state.completedTargetsCount} / ${state.dailyTargets.length} selesai',
                      progress: state.dailyTargets.isEmpty
                          ? 0
                          : state.completedTargetsCount /
                              state.dailyTargets.length,
                      onTap: () => onNavigateTab(2),
                    ),
                  ];

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 12),
                        Expanded(child: cards[1]),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      cards[0],
                      const SizedBox(height: 10),
                      cards[1],
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Akses Cepat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${state.activePrayerRemindersCount} alarm aktif',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.35,
                children: [
                  _ActionTile(
                    icon: Icons.alarm_on_rounded,
                    label: 'Jadwal Sholat',
                    onTap: () => onNavigateTab(1),
                  ),
                  _ActionTile(
                    icon: Icons.edit_note_rounded,
                    label: 'Catat Ngaji',
                    onTap: () => onNavigateTab(2),
                  ),
                  _ActionTile(
                    icon: Icons.fingerprint_rounded,
                    label: 'Tasbih Digital',
                    onTap: () => onNavigateTab(3),
                  ),
                  _ActionTile(
                    icon: Icons.person_rounded,
                    label: 'Target & Profil',
                    onTap: () => onNavigateTab(4),
                  ),
                ],
              ),

              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Surah Pilihan Untuk Ngaji',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateTab(2),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: featuredSurahs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final SurahItem surah = featuredSurahs[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.12),
                        foregroundColor: AppColors.primary,
                        child: Text(
                          '${surah.number}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      title: Text(
                        '${surah.name} (${surah.arabicName})',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${surah.meaning} • ${surah.totalAyat} Ayat',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SurahDetailScreen(surah: surah),
                          ),
                        );
                      },
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

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final double progress;
  final VoidCallback onTap;

  const _QuickStatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
