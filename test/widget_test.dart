import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:lumi_assistant/main.dart';

void main() {
  testWidgets('App loads and displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: LumiAssistantApp()));

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Verify that our app title is displayed
    expect(find.text('Lumi Assistant'), findsOneWidget);
    
    // Verify that the success message is displayed
    expect(find.text('项目初始化成功！'), findsOneWidget);
    
    // Verify that the check icon is displayed
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    
    // Clean up any pending timers or streams
    await tester.binding.delayed(const Duration(milliseconds: 100));
  });
}