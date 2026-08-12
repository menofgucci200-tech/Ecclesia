/// A community prayer intention shared on the parish wall.
class Intention {
  const Intention({
    required this.id,
    required this.intention,
    required this.authorName,
    required this.isAnonymous,
    required this.prayersCount,
    required this.hasPrayed,
    required this.isMine,
    this.createdAt,
  });

  final int id;
  final String intention;
  final String authorName;
  final bool isAnonymous;
  final int prayersCount;
  final bool hasPrayed;
  final bool isMine;
  final String? createdAt;

  Intention copyWith({int? prayersCount, bool? hasPrayed}) => Intention(
        id: id,
        intention: intention,
        authorName: authorName,
        isAnonymous: isAnonymous,
        prayersCount: prayersCount ?? this.prayersCount,
        hasPrayed: hasPrayed ?? this.hasPrayed,
        isMine: isMine,
        createdAt: createdAt,
      );

  factory Intention.fromJson(Map<String, dynamic> json) => Intention(
        id: json['id'] as int,
        intention: json['intention'] as String? ?? '',
        authorName: json['author_name'] as String? ?? 'Un fidèle',
        isAnonymous: json['is_anonymous'] as bool? ?? false,
        prayersCount: (json['prayers_count'] as num?)?.toInt() ?? 0,
        hasPrayed: json['has_prayed'] as bool? ?? false,
        isMine: json['is_mine'] as bool? ?? false,
        createdAt: json['created_at'] as String?,
      );
}

/// Result of loading the wall: the list plus whether the user must join a parish.
class IntentionsResult {
  const IntentionsResult({required this.items, required this.needsParish});
  final List<Intention> items;
  final bool needsParish;
}
