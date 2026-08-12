import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/bible_repository.dart';
import 'bible_reader_screen.dart';
import 'bible_search_screen.dart';

/// Entry point of the offline Bible: books grouped by testament, with a quick
/// filter and a full-text search.
class BibleHomeScreen extends ConsumerStatefulWidget {
  const BibleHomeScreen({super.key});

  @override
  ConsumerState<BibleHomeScreen> createState() => _BibleHomeScreenState();
}

class _BibleHomeScreenState extends ConsumerState<BibleHomeScreen> {
  String _filter = '';

  bool _matches(BibleBook b) {
    if (_filter.isEmpty) return true;
    final f = _filter.toLowerCase();
    return b.name.toLowerCase().contains(f) || b.abbr.toLowerCase().contains(f);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bibleIndexProvider);

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Bible', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BibleSearchScreen())),
            icon: const Icon(Icons.search),
            tooltip: 'Rechercher',
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: HomePalette.navy)),
        error: (e, _) => Center(
          child: Text(
            e is ApiException ? e.message : 'Impossible de charger la Bible.',
            style: const TextStyle(color: HomePalette.textBody),
          ),
        ),
        data: (books) {
          final ot = books.where((b) => b.isOldTestament && _matches(b)).toList();
          final nt = books.where((b) => !b.isOldTestament && _matches(b)).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                child: TextField(
                  onChanged: (v) => setState(() => _filter = v),
                  decoration: InputDecoration(
                    hintText: 'Filtrer un livre…',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.menu_book_outlined, color: HomePalette.navy, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: HomePalette.cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: HomePalette.cardBorder)),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                  children: [
                    if (ot.isNotEmpty) ...[
                      const _SectionTitle('Ancien Testament'),
                      ...ot.map((b) => _BookTile(book: b)),
                    ],
                    if (nt.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const _SectionTitle('Nouveau Testament'),
                      ...nt.map((b) => _BookTile(book: b)),
                    ],
                    if (ot.isEmpty && nt.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: Text('Aucun livre.', style: TextStyle(color: HomePalette.textBody))),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
        child: Text(title.toUpperCase(),
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: HomePalette.textMuted, letterSpacing: 1)),
      );
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book});
  final BibleBook book;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BibleReaderScreen(book: book))),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: HomePalette.cardBorder)),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: HomePalette.navy.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
                  child: Text(book.abbr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: HomePalette.navy)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(book.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: HomePalette.navy)),
                ),
                Text('${book.chapters} ch', style: const TextStyle(fontSize: 12, color: HomePalette.textMuted)),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: HomePalette.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
