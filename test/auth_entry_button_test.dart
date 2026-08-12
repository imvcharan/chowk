import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_news/data/repositories/providers.dart';
import 'package:e_news/presentation/widgets/auth_entry_button.dart';

void main() {
  testWidgets('shows login action when logged out and profile action when logged in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AuthEntryButton()),
        ),
      ),
    );

    expect(find.byIcon(Icons.login_rounded), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsNothing);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AuthEntryButton(isLoggedIn: true)),
        ),
      ),
    );

    expect(find.text('प्रोफाइल'), findsOneWidget);
    expect(find.byIcon(Icons.login_rounded), findsNothing);
  });
}
