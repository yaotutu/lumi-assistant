import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:lumi_assistant/main.dart';

void main() {
  testWidgets('App loads and displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: LumiAssistantApp()));

    // Wait for initial frame
    await tester.pump();

    // Verify that our app title is displayed
    expect(find.text('Lumi Assistant'), findsOneWidget);
    
    // Verify that the settings icon is displayed
    expect(find.byIcon(Icons.settings), findsOneWidget);
    
    // Verify that the MCP test icon is displayed
    expect(find.byIcon(Icons.build_circle), findsOneWidget);
  });
}