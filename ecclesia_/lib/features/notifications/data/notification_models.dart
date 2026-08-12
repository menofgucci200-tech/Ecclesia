import 'package:equatable/equatable.dart';

/// A notification-center entry — today, a parish announcement flagged
/// against the user's read watermark. See `GET /notifications`.
class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.isImportant,
    required this.read,
    this.publishedAt,
  });

  final int id;
  final String category;
  final String categoryLabel;
  final String title;
  final String body;
  final String? imageUrl;
  final bool isImportant;
  final bool read;
  final DateTime? publishedAt;

  static const List<String> _monthsFr = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  /// Relative label, e.g. "Il y a 2 h", falling back to an absolute date past a week.
  String get relativeLabel {
    final d = publishedAt;
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return '${d.day} ${_monthsFr[d.month - 1]} ${d.year}';
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final published = json['published_at'] as String?;
    return NotificationItem(
      id: json['id'] as int,
      category: json['category'] as String? ?? 'announcement',
      categoryLabel: json['category_label'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      isImportant: json['is_important'] as bool? ?? false,
      read: json['read'] as bool? ?? false,
      publishedAt: published != null ? DateTime.tryParse(published)?.toLocal() : null,
    );
  }

  @override
  List<Object?> get props => [id, category, title, body, imageUrl, isImportant, read, publishedAt];
}
