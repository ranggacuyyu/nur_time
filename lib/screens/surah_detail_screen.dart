import 'package:flutter/material.dart';

import '../models/ngaji_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class SurahDetailScreen extends StatefulWidget {
  final SurahItem surah;

  const SurahDetailScreen({
    super.key,
    required this.surah,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  double _arabicFontSize = 24;

  void _markAsReadToday() {
    final state = AppStateScope.of(context);
    final int targetAyat =
        widget.surah.totalAyat > 20 ? 10 : widget.surah.totalAyat;

    state.addTilawahLog(
      surahName: widget.surah.name,
      startAyat: 1,
      endAyat: targetAyat,
      note: 'Ditandai selesai dari Detail Surah',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Text(
          'Alhamdulillah! ${widget.surah.name} ayat 1–$targetAyat dicatat ke riwayat ngaji.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surah = widget.surah;

    return Scaffold(
      appBar: AppBar(
        title: Text('Surah ${surah.name}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Surah Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      surah.arabicName,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${surah.name} • ${surah.meaning}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Surah ke-${surah.number} • ${surah.totalAyat} Ayat • ${surah.revelationPlace}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Keutamaan Surah
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.gold,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Keutamaan Surah',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        surah.virtue,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Font Size Slider for Usability
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ukuran Teks Arab (${_arabicFontSize.toInt()} pt)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Slider(
                        value: _arabicFontSize,
                        min: 18,
                        max: 34,
                        divisions: 8,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() => _arabicFontSize = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Ayat Pembuka Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Potongan Ayat Pembuka',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        surah.sampleArabic,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: _arabicFontSize,
                          height: 1.8,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        surah.sampleLatin,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        surah.sampleTranslation,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _markAsReadToday,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Tandai Sudah Dibaca Hari Ini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
