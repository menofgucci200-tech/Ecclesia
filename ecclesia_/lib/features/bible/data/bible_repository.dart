import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One book of the bundled Crampon 1923 Bible (metadata only).
class BibleBook {
  const BibleBook({
    required this.slug,
    required this.name,
    required this.abbr,
    required this.testament,
    required this.chapters,
  });

  final String slug;
  final String name;
  final String abbr;
  final String testament; // 'AT' | 'NT'
  final int chapters;

  bool get isOldTestament => testament == 'AT';

  factory BibleBook.fromJson(Map<String, dynamic> json) => BibleBook(
        slug: json['slug'] as String,
        name: json['name'] as String,
        abbr: json['abbr'] as String,
        testament: json['testament'] as String? ?? 'AT',
        chapters: (json['chapters'] as num).toInt(),
      );
}

/// A single hit from a full-text search.
class BibleSearchResult {
  const BibleSearchResult({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  final BibleBook book;
  final int chapter; // 1-based
  final int verse; // 1-based
  final String text;

  String get reference => '${book.abbr} $chapter, $verse';
}

/// Loads the offline Bible from bundled assets, caching the index and each
/// book's verses (book files are `[[verse, …], …]`, chapter/verse are 1-based
/// = index + 1).
class BibleRepository {
  BibleRepository(this._bundle);

  final AssetBundle _bundle;
  List<BibleBook>? _index;
  final Map<String, List<List<String>>> _books = {};

  Future<List<BibleBook>> index() async {
    if (_index != null) return _index!;
    final raw = await _bundle.loadString('assets/bible/index.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    _index = (data['books'] as List<dynamic>)
        .map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
        .toList();
    return _index!;
  }

  Future<List<List<String>>> book(String slug) async {
    final cached = _books[slug];
    if (cached != null) return cached;
    final raw = await _bundle.loadString('assets/bible/$slug.json');
    final data = (json.decode(raw) as List<dynamic>)
        .map((ch) => (ch as List<dynamic>).map((v) => v as String).toList())
        .toList();
    _books[slug] = data;
    return data;
  }

  /// Full-text, accent-insensitive search across the whole Bible.
  Future<List<BibleSearchResult>> search(String query, {int limit = 300}) async {
    final q = _fold(query.trim());
    if (q.length < 3) return const [];

    final books = await index();
    final results = <BibleSearchResult>[];
    for (final b in books) {
      final chapters = await book(b.slug);
      for (var ci = 0; ci < chapters.length; ci++) {
        final verses = chapters[ci];
        for (var vi = 0; vi < verses.length; vi++) {
          if (_fold(verses[vi]).contains(q)) {
            results.add(BibleSearchResult(book: b, chapter: ci + 1, verse: vi + 1, text: verses[vi]));
            if (results.length >= limit) return results;
          }
        }
      }
    }
    return results;
  }

  /// Lowercase + strip French accents for accent-insensitive matching.
  static String _fold(String input) {
    final buffer = StringBuffer();
    for (final ch in input.toLowerCase().split('')) {
      buffer.write(_accents[ch] ?? ch);
    }
    return buffer.toString();
  }

  static const Map<String, String> _accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a',
    'ç': 'c',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'í': 'i', 'ì': 'i',
    'ô': 'o', 'ö': 'o', 'ó': 'o', 'ò': 'o', 'õ': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
    'ÿ': 'y', 'œ': 'oe', 'æ': 'ae',
  };
}

final bibleRepositoryProvider = Provider<BibleRepository>((ref) => BibleRepository(rootBundle));

final bibleIndexProvider =
    FutureProvider<List<BibleBook>>((ref) => ref.read(bibleRepositoryProvider).index());

final bibleBookProvider = FutureProvider.family<List<List<String>>, String>(
  (ref, slug) => ref.read(bibleRepositoryProvider).book(slug),
);
