import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_bmi/widgets/charts/bmi_gauge.dart';

void main() {
  group('BMIGauge', () {
    testWidgets('displays BMI value', (WidgetTester tester) async {
      const bmiValue = 22.5;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMIGauge(
                bmi: bmiValue,
              ),
            ),
          ),
        ),
      );

      // Wait for animation
      await tester.pumpAndSettle();

      expect(find.text('22.5'), findsOneWidget);
      expect(find.text('BMI'), findsOneWidget);
    });

    testWidgets('shows correct category label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMIGauge(
                bmi: 22.5,
                showLabels: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('정상'), findsOneWidget);
    });

    testWidgets('hides labels when showLabels is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMIGauge(
                bmi: 22.5,
                showLabels: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('정상'), findsNothing);
    });

    testWidgets('shows different categories correctly', (WidgetTester tester) async {
      // Test underweight
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMIGauge(
                bmi: 17.0,
                showLabels: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('저체중'), findsOneWidget);

      // Test overweight
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMIGauge(
                bmi: 27.0,
                showLabels: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('과체중'), findsOneWidget);

      // Test obese
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMIGauge(
                bmi: 32.0,
                showLabels: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('비만'), findsOneWidget);
    });

    testWidgets('renders with custom size', (WidgetTester tester) async {
      const customSize = 300.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMIGauge(
                bmi: 22.5,
                size: customSize,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.maxWidth, customSize);
      expect(container.constraints?.maxHeight, customSize);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMIGauge(
                bmi: 22.5,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BMIGauge));
      expect(tapped, isTrue);
    });

    testWidgets('animates when animate is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMIGauge(
                bmi: 22.5,
                animate: true,
                animationDuration: Duration(milliseconds: 500),
              ),
            ),
          ),
        ),
      );

      // Initially animating
      await tester.pump();
      
      // Animation should be in progress
      final initialText = find.text('22.5');
      expect(initialText, findsNothing); // Value is still animating

      // Wait for animation to complete
      await tester.pumpAndSettle();
      expect(find.text('22.5'), findsOneWidget);
    });

    testWidgets('shows target BMI marker when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMIGauge(
                bmi: 25.0,
                targetBmi: 22.0,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should render without errors with target BMI
      expect(find.byType(BMIGauge), findsOneWidget);
    });

    testWidgets('handles extreme BMI values', (WidgetTester tester) async {
      // Test very low BMI
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMIGauge(
                bmi: 10.0, // Below normal range
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('10.0'), findsOneWidget);

      // Test very high BMI
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMIGauge(
                bmi: 45.0, // Above normal range
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('45.0'), findsOneWidget);
    });
  });
}