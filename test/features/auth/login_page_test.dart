import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/app.dart';

void main() {
  testWidgets('L\'app démarre sur l\'écran Login', (tester) async {
    await tester.pumpWidget(const Sup2iFoodApp());

    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Soumission vide : validation, on reste sur Login', (
    tester,
  ) async {
    await tester.pumpWidget(const Sup2iFoodApp());

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.text('Entrez votre e-mail.'), findsOneWidget);
    expect(find.text('Entrez votre mot de passe.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('E-mail invalide : message de format', (tester) async {
    await tester.pumpWidget(const Sup2iFoodApp());

    await tester.enterText(find.byKey(const Key('login_email')), 'pasunemail');
    await tester.enterText(find.byKey(const Key('login_password')), 'secret12');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.text('Format d\'e-mail invalide.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Identifiants valides : redirection vers le shell', (
    tester,
  ) async {
    await tester.pumpWidget(const Sup2iFoodApp());

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'etudiant@sup2i.ma',
    );
    await tester.enterText(find.byKey(const Key('login_password')), 'secret12');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
