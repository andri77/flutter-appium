// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_app/main.dart';

void main() {
  testWidgets('Bible app initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BibleVersesApp());
    await tester.pump();

    // Verify that header is present
    expect(find.text('Daily Bible Verses'), findsOneWidget);

    // Verify that selector buttons are present
    expect(find.byIcon(Icons.language), findsOneWidget); // Translation selector
    expect(find.byIcon(Icons.category), findsOneWidget); // Topic selector
    expect(find.byIcon(Icons.wallpaper), findsOneWidget); // Background selector
    expect(find.byIcon(Icons.refresh), findsOneWidget); // New verse button

    // Verify initial state
    expect(find.text('Loading...'), findsNothing);
    expect(find.text('New Verse'), findsOneWidget);
  });

  testWidgets('Topic selection test', (WidgetTester tester) async {
    await tester.pumpWidget(const BibleVersesApp());
    await tester.pump();

    // Open topic dropdown
    await tester.tap(find.byIcon(Icons.category));
    await tester.pumpAndSettle();

    // Verify topics are present
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Love'), findsOneWidget);
    expect(find.text('Faith'), findsOneWidget);
    expect(find.text('Hope'), findsOneWidget);
  });

  testWidgets('Translation selection test', (WidgetTester tester) async {
    await tester.pumpWidget(const BibleVersesApp());
    await tester.pump();

    // Open translation dropdown
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    // Verify translations are present
    expect(find.text('New International Version (English)'), findsOneWidget);
    expect(find.text('King James Version (English)'), findsOneWidget);
  });

  testWidgets('New verse button test', (WidgetTester tester) async {
    await tester.pumpWidget(const BibleVersesApp());
    await tester.pump();

    // Click new verse button
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    // Verify loading state
    expect(find.text('Loading...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
