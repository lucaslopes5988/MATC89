import 'package:flutter_test/flutter_test.dart';

import 'package:atividade_flutter/main.dart';

void main() {
  testWidgets('App inicia na tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Entrar na conta'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
