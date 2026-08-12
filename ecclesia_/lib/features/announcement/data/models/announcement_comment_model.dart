import 'package:equatable/equatable.dart';

/// A comment on a parish announcement.
class AnnouncementCommentModel extends Equatable {
  const AnnouncementCommentModel({
    required this.id,
    required this.body,
    required this.authorName,
    required this.authorInitials,
    this.authorAvatarUrl,
    required this.isMine,
    this.createdAt,
  });

  final int id;
  final String body;
  final String authorName;
  final String authorInitials;
  final String? authorAvatarUrl;
  final bool isMine;
  final DateTime? createdAt;

  String get relativeLabel {
    final d = createdAt;
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return 'Il y a ${diff.inDays} j';
  }

  factory AnnouncementCommentModel.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'] as String?;
    return AnnouncementCommentModel(
      id: json['id'] as int,
      body: json['body'] as String? ?? '',
      authorName: json['author_name'] as String? ?? 'Un fidèle',
      authorInitials: json['author_initials'] as String? ?? '?',
      authorAvatarUrl: json['author_avatar_url'] as String?,
      isMine: json['is_mine'] as bool? ?? false,
      createdAt: created != null ? DateTime.tryParse(created)?.toLocal() : null,
    );
  }

  @override
  List<Object?> get props => [id, body, authorName, authorInitials, authorAvatarUrl, isMine, createdAt];
}
