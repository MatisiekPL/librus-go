import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librus_go/screens/login_screen.dart';

void main() {
  testWidgets("LoginScreen has all elements", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    expect(find.text("Librus Go"), findsOneWidget);
    expect(find.text("Wejdź"), findsOneWidget);
    expect(find.text("Adres e-mail"), findsOneWidget);
    expect(find.text("Hasło"), findsOneWidget);
  });
}
