/// The saint (or liturgical celebration) of a given day.
class Saint {
  const Saint({
    required this.date,
    required this.hasSaint,
    this.feast,
    this.name,
    this.summary,
    this.imageUrl,
    this.wikipediaUrl,
    this.color,
    this.liturgicalDay,
  });

  final String date;
  final bool hasSaint;
  final String? feast;
  final String? name;
  final String? summary;
  final String? imageUrl;
  final String? wikipediaUrl;
  final String? color;
  final String? liturgicalDay;

  factory Saint.fromJson(Map<String, dynamic> json) => Saint(
        date: json['date'] as String? ?? '',
        hasSaint: json['has_saint'] as bool? ?? false,
        feast: json['feast'] as String?,
        name: json['name'] as String?,
        summary: json['summary'] as String?,
        imageUrl: json['image_url'] as String?,
        wikipediaUrl: json['wikipedia_url'] as String?,
        color: json['color'] as String?,
        liturgicalDay: json['liturgical_day'] as String?,
      );
}
