/// A piece of spiritual content (prayer, rosary, novena, litany) shown in the
/// "Vie & Foi" hub, authored from the super-admin dashboard.
class Prayer {
  const Prayer({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.title,
    required this.body,
    this.subtitle,
    this.reference,
    this.imageUrl,
  });

  final int id;
  final String category;
  final String categoryLabel;
  final String title;
  final String? subtitle;
  final String body;
  final String? reference;
  final String? imageUrl;

  factory Prayer.fromJson(Map<String, dynamic> json) => Prayer(
        id: json['id'] as int,
        category: json['category'] as String? ?? 'priere',
        categoryLabel: json['category_label'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String?,
        body: json['body'] as String? ?? '',
        reference: json['reference'] as String?,
        imageUrl: json['image_url'] as String?,
      );
}
