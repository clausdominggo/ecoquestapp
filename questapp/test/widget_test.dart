// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:questapp/main.dart';

void main() {
  testWidgets('shows EcoQuest splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const QuestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('EcoQuest'), findsWidgets);
    expect(find.text('Mulai'), findsOneWidget);
  });
}
