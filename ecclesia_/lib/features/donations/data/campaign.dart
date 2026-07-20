class Campaign {
  const Campaign({
    required this.id,
    required this.title,
    required this.typeLabel,
    this.description,
    this.targetAmount,
    this.collectedAmount = 0,
    this.progress = 0,
    this.imageUrl,
    this.endsAt,
  });

  final int id;
  final String title;
  final String typeLabel;
  final String? description;
  final int? targetAmount;
  final int collectedAmount;
  final int progress;
  final String? imageUrl;
  final String? endsAt;

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        typeLabel: json['type_label'] as String? ?? 'Don',
        description: json['description'] as String?,
        targetAmount: (json['target_amount'] as num?)?.toInt(),
        collectedAmount: (json['collected_amount'] as num?)?.toInt() ?? 0,
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        imageUrl: json['image_url'] as String?,
        endsAt: json['ends_at'] as String?,
      );
}
