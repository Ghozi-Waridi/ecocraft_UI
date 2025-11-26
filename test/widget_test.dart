import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecocraft/main.dart';

void main() {
  testWidgets('EcoCraft app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EcoCraftApp());

    // Verify that splash screen loads
    expect(find.text('EcoCraft'), findsOneWidget);
  });
}
