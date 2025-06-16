import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_bmi/widgets/common/input_field.dart';

void main() {
  group('InputField', () {
    testWidgets('displays label correctly', (WidgetTester tester) async {
      const labelText = 'Email';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InputField(
              label: labelText,
            ),
          ),
        ),
      );

      expect(find.text(labelText), findsOneWidget);
    });

    testWidgets('displays hint text', (WidgetTester tester) async {
      const hintText = 'Enter your email';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InputField(
              label: 'Email',
              hint: hintText,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.decoration?.hintText, hintText);
    });

    testWidgets('calls onChanged when text changes', (WidgetTester tester) async {
      String? changedValue;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputField(
              label: 'Test',
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Hello');
      expect(changedValue, 'Hello');
    });

    testWidgets('shows error text', (WidgetTester tester) async {
      const errorText = 'This field is required';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InputField(
              label: 'Test',
              errorText: errorText,
            ),
          ),
        ),
      );

      expect(find.text(errorText), findsOneWidget);
    });

    testWidgets('validates input', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: InputField(
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Initially no error
      expect(find.text('Required'), findsNothing);

      // Validate form
      formKey.currentState!.validate();
      await tester.pump();

      // Error should be shown
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InputField(
              label: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.obscureText, isTrue);
      
      // Should show visibility toggle button
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InputField(
              label: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      // Initially obscured
      var textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.obscureText, isTrue);

      // Toggle visibility
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Should now be visible
      textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('disables input when enabled is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InputField(
              label: 'Test',
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('shows prefix and suffix text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InputField(
              label: 'Price',
              prefixText: '\$',
              suffixText: '.00',
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.decoration?.prefixText, '\$');
      expect(textField.decoration?.suffixText, '.00');
    });
  });

  group('NumericInputField', () {
    testWidgets('accepts only numeric input', (WidgetTester tester) async {
      double? value;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericInputField(
              label: 'Weight',
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '65.5');
      expect(value, 65.5);

      // Try entering non-numeric
      await tester.enterText(find.byType(TextFormField), 'abc');
      expect(value, null);
    });

    testWidgets('respects decimal places', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericInputField(
              label: 'Weight',
              decimalPlaces: 2,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '65.123');
      await tester.pump();
      
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      final controller = textField.controller;
      // Input should be truncated to 2 decimal places
      expect(controller?.text, '65.12');
    });

    testWidgets('validates min and max values', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: NumericInputField(
                label: 'Age',
                min: 18,
                max: 100,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Test below min
      await tester.enterText(find.byType(TextFormField), '10');
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('최소값은 18입니다'), findsOneWidget);

      // Test above max
      await tester.enterText(find.byType(TextFormField), '150');
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('최대값은 100입니다'), findsOneWidget);

      // Test valid value
      await tester.enterText(find.byType(TextFormField), '25');
      final isValid = formKey.currentState!.validate();
      await tester.pump();
      expect(isValid, isTrue);
    });

    testWidgets('shows suffix text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericInputField(
              label: 'Weight',
              suffix: 'kg',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final inputField = tester.widget<InputField>(find.byType(InputField));
      expect(inputField.suffixText, 'kg');
    });

    testWidgets('shows prefix icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericInputField(
              label: 'Weight',
              prefixIcon: Icons.monitor_weight,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.monitor_weight), findsOneWidget);
    });

    testWidgets('displays initial value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericInputField(
              label: 'Weight',
              initialValue: 65.5,
              decimalPlaces: 1,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('65.5'), findsOneWidget);
    });
  });
}