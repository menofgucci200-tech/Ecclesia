import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/presentation/theme/home_palette.dart';
import '../data/bible_repository.dart';

/// Reads one chapter of a book, with chapter navigation, a chapter picker and
/// a font-size control. Optionally scrolls to and highlights [highlightVerse].
class BibleReaderScreen extends ConsumerStatefulWidget {
  const BibleReaderScreen({
    super.key,
    required this.book,
    this.chapter = 1,
    this.highlightVerse,
  });

  final BibleBook book;
  final int chapter;
  final int? highlightVerse;

  @override
  ConsumerState<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends ConsumerState<BibleReaderScreen> {
  late int _chapter = widget.chapter;
  double _fontSize = 17;
  final _scrollController = ScrollController();
  final _highlightKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _go(int chapter) {
    setState(() => _chapter = chapter);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  Future<void> _pickChapter() async {
    final chosen = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.book.name} — chapitres',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: HomePalette.navy)),
            const SizedBox(height: 14),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: widget.book.chapters,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1),
                itemBuilder: (context, i) {
                  final n = i + 1;
                  final active = n == _chapter;
                  return InkWell(
                    onTap: () => Navigator.of(ctx).pop(n),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? HomePalette.navy : HomePalette.screenBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: active ? HomePalette.navy : HomePalette.cardBorder),
                      ),
                      child: Text('$n',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : HomePalette.navy)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (chosen != null) _go(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bibleBookProvider(widget.book.slug));

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: InkWell(
          onTap: _pickChapter,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${widget.book.name} $_chapter',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more, size: 20),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _fontSize = (_fontSize - 1).clamp(13, 28)),
            icon: const Icon(Icons.text_decrease),
            tooltip: 'Réduire',
          ),
          IconButton(
            onPressed: () => setState(() => _fontSize = (_fontSize + 1).clamp(13, 28)),
            icon: const Icon(Icons.text_increase),
            tooltip: 'Agrandir',
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: HomePalette.navy)),
        error: (e, _) => const Center(child: Text('Impossible de charger le texte.')),
        data: (chapters) {
          final verses = (_chapter - 1) < chapters.length ? chapters[_chapter - 1] : const <String>[];
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.highlightVerse != null && _highlightKey.currentContext != null) {
              Scrollable.ensureVisible(_highlightKey.currentContext!,
                  duration: const Duration(milliseconds: 400), alignment: 0.2);
            }
          });
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
            itemCount: verses.length,
            itemBuilder: (context, i) {
              final n = i + 1;
              final highlight = widget.highlightVerse == n && _chapter == widget.chapter;
              return Container(
                key: highlight ? _highlightKey : null,
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                decoration: highlight
                    ? BoxDecoration(color: HomePalette.gold.withValues(alpha: .16), borderRadius: BorderRadius.circular(8))
                    : null,
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '$n ',
                      style: TextStyle(
                          fontSize: _fontSize * 0.72,
                          fontWeight: FontWeight.w800,
                          color: HomePalette.gold,
                          fontFeatures: const []),
                    ),
                    TextSpan(
                      text: verses[i],
                      style: TextStyle(fontSize: _fontSize, height: 1.6, color: HomePalette.textBody),
                    ),
                  ]),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _chapter > 1 ? () => _go(_chapter - 1) : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Précédent'),
                  style: OutlinedButton.styleFrom(foregroundColor: HomePalette.navy, side: const BorderSide(color: HomePalette.cardBorder)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _chapter < widget.book.chapters ? () => _go(_chapter + 1) : null,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Suivant'),
                  style: OutlinedButton.styleFrom(foregroundColor: HomePalette.navy, side: const BorderSide(color: HomePalette.cardBorder)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
