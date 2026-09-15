// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:studyflow/main.dart';

void main() {
  testWidgets('StudyFlow shows the assignment dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudyFlowApp());

    expect(find.text('StudyFlow'), findsOneWidget);
    expect(find.text('Read Chapter 1'), findsOneWidget);
    expect(find.text('Add assignment'), findsOneWidget);
  });
}
