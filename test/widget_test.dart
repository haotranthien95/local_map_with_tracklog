// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_map_with_tracklog/main.dart';

void main() {
  testWidgets('App launches with bottom navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the bottom navigation bar exists
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify that all three navigation items are present
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches tabs', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify we start on the Map tab (default index 1)
    expect(find.text('Local Map with Track Log'), findsOneWidget);

    // Tap on Dashboard tab
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    // Verify Dashboard screen is displayed
    expect(find.text('Dashboard - Coming Soon'), findsOneWidget);

    // Tap on Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify Settings screen is displayed (check for Logout which is unique)
    expect(find.text('Logout'), findsWidgets);

    // Tap back to Map tab
    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    // Verify Map screen is displayed
    expect(find.text('Local Map with Track Log'), findsOneWidget);
  });
}
