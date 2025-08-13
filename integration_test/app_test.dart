import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bible_app/main.dart';
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify initial load and verse refresh',
        (WidgetTester tester) async {
      await tester.pumpWidget(const BibleVersesApp());
      await tester.pumpAndSettle();

      // Verify initial UI loaded
      expect(find.text('Daily Bible Verses'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byIcon(Icons.wallpaper), findsOneWidget);

      // Wait for initial verse to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Get initial verse text
      final initialVerseKey = find.byKey(const ValueKey('verse_text'));
      expect(initialVerseKey, findsOneWidget);
      final initialVerse = (tester.widget(initialVerseKey) as Text).data;

      // Tap New Verse button
      await tester.tap(find.byIcon(Icons.refresh));
      
      // Verify loading state
      expect(find.text('Loading...'), findsOneWidget);
      
      // Wait for new verse to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Get new verse text
      final newVerseKey = find.byKey(const ValueKey('verse_text'));
      expect(newVerseKey, findsOneWidget);
      final newVerse = (tester.widget(newVerseKey) as Text).data;

      // Verify verse changed
      expect(initialVerse, isNot(equals(newVerse)));
    });

    testWidgets('verify topic selection and filtering',
        (WidgetTester tester) async {
      await tester.pumpWidget(const BibleVersesApp());
      await tester.pumpAndSettle();

      // Open topic dropdown
      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();

      // Select Love topic
      await tester.tap(find.text('Love').last);
      await tester.pumpAndSettle();

      // Wait for verse to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify Love topic badge is shown
      expect(find.text('Love'), findsOneWidget);
    });

    testWidgets('verify translation change',
        (WidgetTester tester) async {
      await tester.pumpWidget(const BibleVersesApp());
      await tester.pumpAndSettle();

      // Open translation dropdown
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Select King James Version
      await tester.tap(find.text('King James Version (English)').last);
      await tester.pumpAndSettle();

      // Wait for verse to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify translation changed
      expect(find.text('King James Version'), findsOneWidget);
    });

    testWidgets('verify background selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(const BibleVersesApp());
      await tester.pumpAndSettle();

      // Open background dropdown
      await tester.tap(find.byIcon(Icons.wallpaper));
      await tester.pumpAndSettle();

      // Select a different background
      await tester.tap(find.text('Ocean Sunset').last);
      await tester.pumpAndSettle();

      // Verify background selector shows selected option
      expect(find.text('Ocean Sunset'), findsOneWidget);
    });

    testWidgets('verify error handling with no internet',
        (WidgetTester tester) async {
      await tester.pumpWidget(const BibleVersesApp());
      await tester.pumpAndSettle();

      // Verify fallback verse appears when API fails
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Should show fallback verse (John 3:16) when API fails
      expect(find.text('Fallback'), findsOneWidget);
    });
  });
}
