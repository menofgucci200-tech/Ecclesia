import 'package:equatable/equatable.dart';

/// A parish feed announcement as returned by `GET /parish/announcements`.
class AnnouncementModel extends Equatable {
  const AnnouncementModel({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.title,
    required this.body,
    this.imageUrl,
    this.videoUrl,
    required this.authorName,
    this.authorRole,
    required this.authorInitials,
    required this.isPinned,
    required this.isImportant,
    required this.likesCount,
    required this.commentsCount,
    this.publishedAt,
  });

  final int id;
  final String category;
  final String categoryLabel;
  final String title;
  final String body;
  final String? imageUrl;
  final String? videoUrl;
  final String authorName;
  final String? authorRole;
  final String authorInitials;
  final bool isPinned;
  final bool isImportant;
  final int likesCount;
  final int commentsCount;
  final DateTime? publishedAt;

  static const List<String> _monthsFr = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  /// Absolute short date, e.g. "6 juil. 2026".
  String get shortDate {
    final d = publishedAt;
    if (d == null) return '';
    return '${d.day} ${_monthsFr[d.month - 1]} ${d.year}';
  }

  /// Relative label, e.g. "Il y a 2 h", falling back to [shortDate] past a week.
  String get relativeLabel {
    final d = publishedAt;
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return shortDate;
  }

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    final published = json['published_at'] as String?;
    return AnnouncementModel(
      id: json['id'] as int,
      category: json['category'] as String? ?? 'announcement',
      categoryLabel: json['category_label'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      authorName: json['author_name'] as String? ?? '',
      authorRole: json['author_role'] as String?,
      authorInitials: json['author_initials'] as String? ?? '',
      isPinned: json['is_pinned'] as bool? ?? false,
      isImportant: json['is_important'] as bool? ?? false,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      publishedAt: published != null ? DateTime.tryParse(published)?.toLocal() : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        category,
        title,
        body,
        imageUrl,
        videoUrl,
        authorName,
        authorRole,
        authorInitials,
        isPinned,
        isImportant,
        likesCount,
        commentsCount,
        publishedAt,
      ];
}
