import '../../../announcement/data/models/announcement_model.dart';

/// Aggregated payload for the home screen (`GET /api/home`).
class HomeData {
  const HomeData({
    this.liturgy,
    this.parishName,
    this.massTimes = const [],
    this.nextMass,
    this.announcement,
    this.events = const [],
    this.quote,
  });

  final LiturgyModel? liturgy;
  final String? parishName;
  final List<MassTimeModel> massTimes;
  final NextMassModel? nextMass;
  final AnnouncementModel? announcement;
  final List<AgendaEvent> events;
  final QuoteModel? quote;

  factory HomeData.fromJson(Map<String, dynamic> json) {
    final parish = json['parish'] as Map<String, dynamic>?;
    return HomeData(
      liturgy: json['liturgy'] == null
          ? null
          : LiturgyModel.fromJson(json['liturgy'] as Map<String, dynamic>),
      parishName: parish?['name'] as String?,
      massTimes: (json['mass_times'] as List<dynamic>? ?? const [])
          .map((e) => MassTimeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextMass: json['next_mass'] == null
          ? null
          : NextMassModel.fromJson(json['next_mass'] as Map<String, dynamic>),
      announcement: json['announcement'] == null
          ? null
          : AnnouncementModel.fromJson(json['announcement'] as Map<String, dynamic>),
      events: (json['events'] as List<dynamic>? ?? const [])
          .map((e) => AgendaEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      quote: json['quote'] == null
          ? null
          : QuoteModel.fromJson(json['quote'] as Map<String, dynamic>),
    );
  }
}

/// A single agenda item: a major liturgical feast or a parish event.
class AgendaEvent {
  const AgendaEvent({
    required this.type,
    required this.date,
    required this.title,
    this.time,
    this.subtitle,
    this.color,
    this.grade = 0,
    this.location,
    this.description,
  });

  final String type; // 'liturgical' | 'parish'
  final DateTime date;
  final String title;
  final String? time;
  final String? subtitle;
  final String? color;
  final int grade;
  final String? location;
  final String? description;

  bool get isParish => type == 'parish';

  factory AgendaEvent.fromJson(Map<String, dynamic> json) => AgendaEvent(
        type: json['type'] as String? ?? 'liturgical',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        title: json['title'] as String? ?? '',
        time: json['time'] as String?,
        subtitle: json['subtitle'] as String?,
        color: json['color'] as String?,
        grade: (json['grade'] as num?)?.toInt() ?? 0,
        location: json['location'] as String?,
        description: json['description'] as String?,
      );
}

class LiturgyModel {
  const LiturgyModel({
    required this.date,
    required this.liturgicalDay,
    this.season,
    this.color,
    this.week,
    this.gospelRef,
    this.gospelTitle,
    this.readings = const [],
  });

  final DateTime date;
  final String liturgicalDay;
  final String? season;
  final String? color;
  final String? week;
  final String? gospelRef;
  final String? gospelTitle;
  final List<ReadingModel> readings;

  factory LiturgyModel.fromJson(Map<String, dynamic> json) {
    final gospel = json['gospel'] as Map<String, dynamic>?;
    return LiturgyModel(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      liturgicalDay: json['liturgical_day'] as String? ?? 'Liturgie du jour',
      season: json['season'] as String?,
      color: json['color'] as String?,
      week: json['week'] as String?,
      gospelRef: gospel?['ref'] as String?,
      gospelTitle: gospel?['title'] as String?,
      readings: (json['readings'] as List<dynamic>? ?? const [])
          .map((e) => ReadingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReadingModel {
  const ReadingModel({
    required this.type,
    this.ref,
    this.title,
    this.intro,
    this.content,
    this.refrain,
    this.verse,
  });

  final String type;
  final String? ref;
  final String? title;
  final String? intro;
  final String? content;
  final String? refrain;
  final String? verse;

  /// Human label for the reading type.
  String get label => switch (type) {
        'lecture_1' => 'Première lecture',
        'psaume' => 'Psaume',
        'lecture_2' => 'Deuxième lecture',
        'evangile' => 'Évangile',
        'cantique' => 'Cantique',
        'sequence' => 'Séquence',
        _ => 'Lecture',
      };

  factory ReadingModel.fromJson(Map<String, dynamic> json) => ReadingModel(
        type: json['type'] as String? ?? 'lecture',
        ref: json['ref'] as String?,
        title: json['title'] as String?,
        intro: json['intro'] as String?,
        content: json['content'] as String?,
        refrain: json['refrain'] as String?,
        verse: json['verse'] as String?,
      );
}

class MassTimeModel {
  const MassTimeModel({
    required this.dayLabel,
    required this.time,
    this.label,
    this.note,
  });

  final String dayLabel;
  final String time;
  final String? label;
  final String? note;

  factory MassTimeModel.fromJson(Map<String, dynamic> json) => MassTimeModel(
        dayLabel: json['day_label'] as String? ?? '',
        time: json['time'] as String? ?? '',
        label: json['label'] as String?,
        note: json['note'] as String?,
      );
}

class NextMassModel {
  const NextMassModel({required this.dayLabel, required this.time, this.label, this.at});

  final String dayLabel;
  final String time;
  final String? label;
  final DateTime? at;

  factory NextMassModel.fromJson(Map<String, dynamic> json) => NextMassModel(
        dayLabel: json['day_label'] as String? ?? '',
        time: json['time'] as String? ?? '',
        label: json['label'] as String?,
        at: DateTime.tryParse(json['at'] as String? ?? ''),
      );
}

class QuoteModel {
  const QuoteModel({this.text, this.ref});

  final String? text;
  final String? ref;

  factory QuoteModel.fromJson(Map<String, dynamic> json) =>
      QuoteModel(text: json['text'] as String?, ref: json['ref'] as String?);
}
