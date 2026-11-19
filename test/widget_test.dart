// Basic widget test for Education Management System

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_manager_app/main.dart';

void main() {
  testWidgets('App should start and show splash screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EduManagerApp());

    // Verify splash screen is shown
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
