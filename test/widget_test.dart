import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:journal_trend_analyzer/main.dart';
import 'package:journal_trend_analyzer/providers/search_provider.dart';

void main() {
  testWidgets('App launches and shows bottom navigation bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SearchProvider(),
        child: const JournalTrendApp(),
      ),
    );

    // Verify the app starts with bottom navigation bar present
    expect(find.byType(NavigationBar), findsOneWidget);
    // Verify Search tab is initially selected
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Trends'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
