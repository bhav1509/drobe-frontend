// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:drobe_frontend/main.dart';

void main() {
  testWidgets('shows sign in UI first', (WidgetTester tester) async {
    await tester.pumpWidget(const DrobeApp());

    expect(find.text('DROBE'), findsOneWidget);
    expect(find.textContaining('Drobe'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
