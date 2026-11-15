class DzikirItem {
  final String id;
  final String title;
  final String category;
  final String arabicText;
  final String latinText;
  final String translation;
  final int recommendedCount;

  const DzikirItem({
    required this.id,
    required this.title,
    required this.category,
    required this.arabicText,
    required this.latinText,
    required this.translation,
    this.recommendedCount = 33,
  });
}
