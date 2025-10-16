import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:club_hub/src/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('Login screen renders email and password fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
