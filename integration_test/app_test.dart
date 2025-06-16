import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_bmi/main.dart' as app;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BMI Tracker App Integration Tests', () {
    setUpAll(() async {
      // Initialize Supabase for tests
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        anonKey: 'test-key',
        localStorage: const EmptyLocalStorage(),
      );
    });

    testWidgets('App launches and shows home screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify app title is displayed
      expect(find.text('BMI 트래커'), findsOneWidget);
      
      // Verify main navigation items exist
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('Navigate to weight input screen and record weight', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find and tap the weight record button
      final addButton = find.text('오늘 체중 기록하기');
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify weight input screen is shown
      expect(find.text('체중 기록'), findsOneWidget);
      
      // Enter weight
      final weightField = find.byType(TextFormField).first;
      await tester.enterText(weightField, '70.5');
      
      // Save weight
      final saveButton = find.text('저장');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should return to home screen
      expect(find.text('BMI 트래커'), findsOneWidget);
    });

    testWidgets('Navigate through bottom navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to statistics
      await tester.tap(find.byIcon(Icons.bar_chart_outlined));
      await tester.pumpAndSettle();
      expect(find.text('통계'), findsWidgets);

      // Navigate to profile/settings
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.text('설정'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(find.text('BMI 트래커'), findsOneWidget);
    });

    testWidgets('Dark mode toggle works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Find and toggle dark mode
      final darkModeSwitch = find.byType(Switch).first;
      await tester.tap(darkModeSwitch);
      await tester.pumpAndSettle();

      // Verify theme changed (check background color)
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, isNot(equals(Colors.white)));
    });

    testWidgets('Goal setting flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for goal setting button
      final goalButton = find.text('목표 설정하기');
      if (goalButton.evaluate().isNotEmpty) {
        await tester.tap(goalButton);
        await tester.pumpAndSettle();

        // Enter target weight
        final targetWeightField = find.byType(TextFormField).first;
        await tester.enterText(targetWeightField, '65.0');

        // Save goal
        final saveButton = find.text('저장');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Should show goal progress
        expect(find.text('목표 달성률'), findsOneWidget);
      }
    });

    testWidgets('Weight history is displayed', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Record a weight first
      final addButton = find.text('오늘 체중 기록하기');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      final weightField = find.byType(TextFormField).first;
      await tester.enterText(weightField, '70.0');
      
      final saveButton = find.text('저장');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Check if weight history shows the entry
      expect(find.text('70.0 kg'), findsWidgets);
    });

    testWidgets('BMI calculation and display', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // BMI should be displayed on home screen
      expect(find.text('BMI'), findsWidgets);
      
      // BMI gauge should be visible
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Charts are rendered correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to statistics
      await tester.tap(find.byIcon(Icons.bar_chart_outlined));
      await tester.pumpAndSettle();

      // Charts should be visible
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('체중 변화'), findsWidgets);
    });

    testWidgets('Export/Import functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Find export button
      final exportButton = find.text('데이터 내보내기');
      if (exportButton.evaluate().isNotEmpty) {
        await tester.tap(exportButton);
        await tester.pumpAndSettle();

        // Should show export options
        expect(find.text('CSV'), findsOneWidget);
        expect(find.text('JSON'), findsOneWidget);
      }
    });

    testWidgets('Responsive layout on different screen sizes', (WidgetTester tester) async {
      // Test on phone size
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 2.625;

      app.main();
      await tester.pumpAndSettle();

      // Should show bottom navigation
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Test on tablet size
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpAndSettle();

      // Should show navigation rail on tablet
      expect(find.byType(NavigationRail), findsWidgets);

      // Reset to default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}

// Mock LocalStorage for tests
class EmptyLocalStorage extends LocalStorage {
  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async => null;

  @override
  Future<void> clear() async {}

  @override
  Future<bool> hasAccessToken() async => false;

  @override
  Future<void> persistSession(String persistSessionString) async {}

  @override
  Future<void> removePersistedSession() async {}

  @override
  Future<String?> persistedSession() async => null;
}