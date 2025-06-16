import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_bmi/widgets/character/bmi_character.dart';
import 'package:app_bmi/widgets/character/character_animator.dart';

void main() {
  group('BMICharacter', () {
    testWidgets('displays BMI value with label', (WidgetTester tester) async {
      const bmiValue = 22.5;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
                bmi: bmiValue,
                showLabels: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('BMI 22.5'), findsOneWidget);
      expect(find.text('정상 체중'), findsOneWidget);
    });

    testWidgets('hides labels when showLabels is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
                bmi: 22.5,
                showLabels: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('BMI 22.5'), findsNothing);
      expect(find.text('정상 체중'), findsNothing);
    });

    testWidgets('shows correct emotions for different BMI categories', (WidgetTester tester) async {
      // Underweight
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
                bmi: 17.0,
                showLabels: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('😔'), findsOneWidget);
      expect(find.text('저체중'), findsOneWidget);

      // Normal
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
                bmi: 22.0,
                showLabels: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('😊'), findsOneWidget);
      expect(find.text('정상 체중'), findsOneWidget);

      // Overweight
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
                bmi: 27.0,
                showLabels: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('😅'), findsOneWidget);
      expect(find.text('과체중'), findsOneWidget);

      // Obese
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
                bmi: 32.0,
                showLabels: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('😰'), findsOneWidget);
      expect(find.text('비만'), findsOneWidget);
    });

    testWidgets('renders with custom size', (WidgetTester tester) async {
      const customSize = 300.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
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
      expect(container.constraints?.maxHeight, customSize * 1.2);
    });

    testWidgets('shows target BMI silhouette when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
                bmi: 27.0,
                targetBmi: 22.0,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should find two CustomPaint widgets (main character and target silhouette)
      expect(find.byType(CustomPaint), findsNWidgets(2));
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
                bmi: 22.5,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BMICharacter));
      expect(tapped, isTrue);
    });

    testWidgets('animates when animate is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
                bmi: 22.5,
                animate: true,
                animationDuration: Duration(milliseconds: 500),
              ),
            ),
          ),
        ),
      );

      // Animation should start
      await tester.pump();
      
      // Wait for animation to complete
      await tester.pumpAndSettle();
      
      expect(find.byType(BMICharacter), findsOneWidget);
    });

    testWidgets('renders different character styles', (WidgetTester tester) async {
      // Cute style
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
                bmi: 22.5,
                style: CharacterStyle.cute,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BMICharacter), findsOneWidget);

      // Realistic style
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
                bmi: 22.5,
                style: CharacterStyle.realistic,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BMICharacter), findsOneWidget);

      // Minimal style
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BMICharacter(
                bmi: 22.5,
                style: CharacterStyle.minimal,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BMICharacter), findsOneWidget);
    });
  });

  group('CharacterAnimator', () {
    testWidgets('animates child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CharacterAnimator(
                animationType: AnimationType.bounce,
                duration: Duration(milliseconds: 500),
                child: Text('Animated'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Animated'), findsOneWidget);
      
      // Animation should be running
      await tester.pump(const Duration(milliseconds: 250));
      
      // Widget should still be visible during animation
      expect(find.text('Animated'), findsOneWidget);
    });

    testWidgets('supports different animation types', (WidgetTester tester) async {
      final animationTypes = [
        AnimationType.bounce,
        AnimationType.shake,
        AnimationType.pulse,
        AnimationType.float,
        AnimationType.wave,
        AnimationType.celebrate,
      ];

      for (final type in animationTypes) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: CharacterAnimator(
                  animationType: type,
                  duration: const Duration(milliseconds: 200),
                  child: const Text('Test'),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('stops animation when repeat is false', (WidgetTester tester) async {
      var animationCompleted = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CharacterAnimator(
                animationType: AnimationType.bounce,
                duration: const Duration(milliseconds: 200),
                repeat: false,
                onAnimationComplete: () => animationCompleted = true,
                child: const Text('Once'),
              ),
            ),
          ),
        ),
      );

      // Wait for animation to complete
      await tester.pumpAndSettle();
      
      expect(animationCompleted, isTrue);
    });
  });
}