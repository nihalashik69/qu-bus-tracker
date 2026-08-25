// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:qu_bus_tracker/main.dart';

void main() {
  testWidgets('tracker starts on gender selection', (WidgetTester tester) async {
    await tester.pumpWidget(const QUBusTrackerApp());

    expect(find.text('QU Bus Tracker'), findsOneWidget);
    expect(find.text('Male Student'), findsOneWidget);
    expect(find.text('Female Student'), findsOneWidget);
  });
}
