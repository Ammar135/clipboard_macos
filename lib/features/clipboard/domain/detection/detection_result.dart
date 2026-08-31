import '../entities/content_category.dart';

class DetectionResult {
  final ContentCategory category;
  final Map<String, Object?> metadata;

  const DetectionResult({
    required this.category,
    this.metadata = const {},
  });
}
