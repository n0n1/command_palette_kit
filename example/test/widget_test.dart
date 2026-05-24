import 'package:flutter_test/flutter_test.dart';

import 'package:command_palette_kit_example/main.dart';

void main() {
  testWidgets('opens the command palette', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open command palette'));
    await tester.pumpAndSettle();

    expect(find.text('Open Dashboard'), findsOneWidget);
    expect(find.text('Use Dark Theme'), findsOneWidget);
  });
}
