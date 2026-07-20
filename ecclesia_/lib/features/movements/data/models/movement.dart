/// A parish movement (group) the faithful can join.
class Movement {
  const Movement({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.meetingInfo,
    this.logoUrl,
    this.membersCount = 0,
    this.isMember = false,
  });

  final int id;
  final String name;
  final String? category;
  final String? description;
  final String? meetingInfo;
  final String? logoUrl;
  final int membersCount;
  final bool isMember;

  Movement copyWith({bool? isMember, int? membersCount}) => Movement(
        id: id,
        name: name,
        category: category,
        description: description,
        meetingInfo: meetingInfo,
        logoUrl: logoUrl,
        membersCount: membersCount ?? this.membersCount,
        isMember: isMember ?? this.isMember,
      );

  factory Movement.fromJson(Map<String, dynamic> json) => Movement(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        category: json['category'] as String?,
        description: json['description'] as String?,
        meetingInfo: json['meeting_info'] as String?,
        logoUrl: json['logo_url'] as String?,
        membersCount: (json['members_count'] as num?)?.toInt() ?? 0,
        isMember: json['is_member'] as bool? ?? false,
      );
}

/// A post/announcement published inside a movement.
class MovementPost {
  const MovementPost({required this.id, required this.title, required this.body, this.imageUrl, this.publishedAt});

  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime? publishedAt;

  factory MovementPost.fromJson(Map<String, dynamic> json) => MovementPost(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
      );
}

/// A downloadable movement document.
class MovementDocument {
  const MovementDocument({required this.id, required this.title, required this.url, this.size});

  final int id;
  final String title;
  final String url;
  final String? size;

  factory MovementDocument.fromJson(Map<String, dynamic> json) => MovementDocument(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        url: json['url'] as String? ?? '',
        size: json['size'] as String?,
      );
}

/// A movement's full detail: the movement + its posts + documents.
class MovementDetail {
  const MovementDetail({required this.movement, this.posts = const [], this.documents = const []});

  final Movement movement;
  final List<MovementPost> posts;
  final List<MovementDocument> documents;

  factory MovementDetail.fromJson(Map<String, dynamic> json) => MovementDetail(
        movement: Movement.fromJson(json['movement'] as Map<String, dynamic>),
        posts: (json['posts'] as List<dynamic>? ?? const [])
            .map((e) => MovementPost.fromJson(e as Map<String, dynamic>))
            .toList(),
        documents: (json['documents'] as List<dynamic>? ?? const [])
            .map((e) => MovementDocument.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
