// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:my_learning_app/views/loginView.dart';

void main() {
  testWidgets('NoteCard displays title correctly', (WidgetTester tester) async {
    // 1. Build the widget in the test environment
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // 2. Find the widget containing the text
    final titleFinder = find.text('Finish Flutter Project');

    // 3. Verify it exists
    expect(titleFinder, findsOneWidget);
  });
}
