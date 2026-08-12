import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/presentation/theme/home_palette.dart';
import '../data/bible_repository.dart';
import 'bible_reader_screen.dart';

/// Full-text, accent-insensitive search across the whole Bible.
class BibleSearchScreen extends ConsumerStatefulWidget {
  const BibleSearchScreen({super.key});

  @override
  ConsumerState<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends ConsumerState<BibleSearchScreen> {
  final _controller = TextEditingController();
  List<BibleSearchResult>? _results;
  bool _searching = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final q = _controller.text.trim();
    if (q.length < 3) return;
    setState(() {
      _searching = true;
      _lastQuery = q;
    });
    final results = await ref.read(bibleRepositoryProvider).search(q);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Rechercher', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _run(),
              decoration: InputDecoration(
                hintText: 'Un mot, une expression…',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: HomePalette.navy),
                suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), color: HomePalette.navy, onPressed: _run),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: HomePalette.cardBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: HomePalette.cardBorder)),
              ),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_searching) {
      return const Center(child: CircularProgressIndicator(color: HomePalette.navy));
    }
    final results = _results;
    if (results == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Cherchez un mot dans toute la Bible (Crampon 1923).',
              textAlign: TextAlign.center, style: TextStyle(color: HomePalette.textBody)),
        ),
      );
    }
    if (results.isEmpty) {
      return Center(child: Text('Aucun résultat pour « $_lastQuery ».', style: const TextStyle(color: HomePalette.textBody)));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${results.length} résultat${results.length > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12.5, color: HomePalette.textMuted, fontWeight: FontWeight.w600)),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = results[i];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BibleReaderScreen(book: r.book, chapter: r.chapter, highlightVerse: r.verse),
                  )),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: HomePalette.cardBorder)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.reference, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: HomePalette.navy)),
                        const SizedBox(height: 4),
                        Text(r.text, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, height: 1.5, color: HomePalette.textBody)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
