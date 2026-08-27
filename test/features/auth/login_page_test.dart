import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/app.dart';

Future<void> _fill(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(find.byKey(const Key('login_email')), email);
  await tester.enterText(find.byKey(const Key('login_password')), password);
}

void main() {
  testWidgets('L\'app démarre sur l\'écran Login', (tester) async {
    await tester.pumpWidget(const Sup2iFoodApp());
    await tester.pump(const Duration(seconds: 1)); // flush le chargement notifs

    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Soumission vide : validation, on reste sur Login', (
    tester,
  ) async {
    await tester.pumpWidget(const Sup2iFoodApp());
    await tester.pump(const Duration(seconds: 1)); // flush le chargement notifs

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.text('Entrez votre e-mail.'), findsOneWidget);
    expect(find.text('Entrez votre mot de passe.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('E-mail invalide : message de format', (tester) async {
    await tester.pumpWidget(const Sup2iFoodApp());
    await tester.pump(const Duration(seconds: 1)); // flush le chargement notifs

    await _fill(tester, email: 'pasunemail', password: 'secret12');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.text('Format d\'e-mail invalide.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Mot de passe erroné → message UNAUTHORIZED, reste sur Login', (
    tester,
  ) async {
    await tester.pumpWidget(const Sup2iFoodApp());

    await _fill(tester, email: 'etudiant@sup2i.ma', password: 'wrong');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Compte bloqué → message ACCOUNT_BLOCKED', (tester) async {
    await tester.pumpWidget(const Sup2iFoodApp());

    await _fill(tester, email: 'blocked@sup2i.ma', password: 'secret12');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.textContaining('bloqué'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Identifiants valides : redirection vers le shell', (
    tester,
  ) async {
    await tester.pumpWidget(const Sup2iFoodApp());

    await _fill(tester, email: 'etudiant@sup2i.ma', password: 'secret12');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
