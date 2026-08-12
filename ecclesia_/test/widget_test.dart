import 'package:ecclesia_/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  testWidgets('EcclesiaApp builds without throwing', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(const ProviderScope(child: EcclesiaApp()));
    await tester.pump();
    // Clears the splash screen's one-shot delayed entrance animation
    // (flutter_animate schedules it via a Timer) before the tree is torn
    // down — the indefinite CircularProgressIndicator ticker means
    // pumpAndSettle() would never return, so a bounded pump is used instead.
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
  });
}
