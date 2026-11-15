import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/dzikir_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class DzikirTasbihScreen extends StatefulWidget {
  const DzikirTasbihScreen({super.key});

  @override
  State<DzikirTasbihScreen> createState() => _DzikirTasbihScreenState();
}

class _DzikirTasbihScreenState extends State<DzikirTasbihScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleTapTasbih(AppStateController state) {
    final targetReached = state.incrementTasbih();
    if (targetReached) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text(
            'Alhamdulillah! Target ${state.tasbihTarget}x ${state.activeTasbihDzikir.title} tercapai.',
          ),
        ),
      );
    }
  }

  void _confirmReset(AppStateController state) {
    if (state.tasbihCount == 0) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Tasbih'),
        content: const Text('Yakin ingin mengembalikan hitungan tasbih ke 0?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              state.resetTasbih();
              Navigator.of(ctx).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final activeDzikir = state.activeTasbihDzikir;
    final double progress = state.tasbihTarget > 0
        ? (state.tasbihCount / state.tasbihTarget).clamp(0.0, 1.0)
        : 0.0;

    final filteredList = DummyData.dzikirList.where((item) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return item.title.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.translation.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih Digital & Doa Harian'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Interactive Tasbih Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: state.selectedDzikirIndex,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Bacaan Dzikir',
                          prefixIcon: Icon(Icons.auto_awesome_rounded),
                        ),
                        items: List.generate(
                          DummyData.dzikirList.length,
                          (i) => DropdownMenuItem(
                            value: i,
                            child: Text(DummyData.dzikirList[i].title),
                          ),
                        ),
                        onChanged: (idx) {
                          if (idx != null) {
                            state.selectTasbihDzikir(idx);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        activeDzikir.arabicText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        activeDzikir.latinText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Circular Tap Button
                      GestureDetector(
                        key: const Key('tasbih_tap_button'),
                        onTap: () => _handleTapTasbih(state),
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryDark,
                                AppColors.primaryLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 152,
                                height: 152,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.white24,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    AppColors.gold,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${state.tasbihCount}',
                                    key: const Key('tasbih_count_text'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 42,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Target: ${state.tasbihTarget}',
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Target Chips & Reset
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [33, 99, 100]
                            .map(
                              (target) => ChoiceChip(
                                label: Text('$target x'),
                                selected: state.tasbihTarget == target,
                                selectedColor:
                                    AppColors.primary.withValues(alpha: 0.16),
                                onSelected: (_) =>
                                    state.setTasbihTarget(target),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Total dzikir hari ini: ${state.totalDailyDzikir}x',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            key: const Key('tasbih_reset_button'),
                            onPressed: () => _confirmReset(state),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Reset'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Searchable Doa & Dzikir Harian
              const Text(
                'Kumpulan Doa & Dzikir Harian',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari doa (contoh: Adzan, Al-Qur\'an, Istighfar)...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
              ),
              const SizedBox(height: 10),
              if (filteredList.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Doa atau dzikir yang dicari tidak ditemukan.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final DzikirItem item = filteredList[index];
                    return Card(
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.12),
                          foregroundColor: AppColors.primary,
                          child: const Icon(Icons.menu_book_outlined, size: 18),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          item.category,
                          style: const TextStyle(fontSize: 12),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              item.arabicText,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 21,
                                height: 1.7,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item.latinText,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item.translation,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
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
