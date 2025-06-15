// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_forge/main.dart';

void main() {
  testWidgets('App Forge loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AppForge());

    // Verify that App Forge title is displayed
    expect(find.text('App Forge'), findsNWidgets(2)); // AppBar and body
    
    // Verify that the description is displayed
    expect(find.text('Build mobile apps from Figma designs with AI'), findsOneWidget);
    
    // Verify the build icon is displayed
    expect(find.byIcon(Icons.build_rounded), findsOneWidget);
  });
}
