// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
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

  testWidgets('completed overdue assignments are faded and not styled red', (
    WidgetTester tester,
  ) async {
    final overdueAssignment = Assignment(
      title: 'Overdue work',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
    );

    await tester.pumpWidget(
      StudyFlowApp(initialAssignments: [overdueAssignment]),
    );

    expect(overdueAssignment.isOverdue, isTrue);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(overdueAssignment.isOverdue, isFalse);
    expect(
      tester
          .widget<Opacity>(
            find.byKey(const ValueKey('assignment-Overdue work')),
          )
          .opacity,
      0.55,
    );
    final title = tester.widget<Text>(find.text('Overdue work'));
    expect(title.style?.decoration, TextDecoration.lineThrough);
    expect(title.style?.color, isNull);
  });

  testWidgets('upcoming assignments show an all caught up message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      StudyFlowApp(
        initialAssignments: [
          Assignment(
            title: 'Finished work',
            dueDate: DateTime.now(),
            isComplete: true,
          ),
        ],
      ),
    );

    await tester.tap(find.text('Upcoming'));
    await tester.pump();

    expect(find.text('All caught up!'), findsOneWidget);
  });
}
