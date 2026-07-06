import 'package:ecclesia_/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  testWidgets('EcclesiaApp builds without throwing', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(const ProviderScope(child: EcclesiaApp()));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
