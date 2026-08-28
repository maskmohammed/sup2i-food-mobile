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

/// Ouvre l'écran Login via le mur de connexion (onglet protégé Profil).
Future<void> _openLogin(WidgetTester tester) async {
  await tester.pumpWidget(const Sup2iFoodApp());
  await tester.pump(const Duration(seconds: 1)); // flush le chargement notifs
  await tester.pumpAndSettle();
  await tester.tap(find.text('Profil')); // onglet protégé -> mur
  await tester.pumpAndSettle();
  await tester.tap(find.text('Se connecter')); // bouton du mur -> Login
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Mode invité : l\'app démarre sur le shell (pas de login forcé)',
    (tester) async {
      await tester.pumpWidget(const Sup2iFoodApp());
      await tester.pump(
        const Duration(seconds: 1),
      ); // flush le chargement notifs
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byKey(const Key('login_email')), findsNothing);
    },
  );

  testWidgets('Soumission vide : validation, on reste sur Login', (
    tester,
  ) async {
    await _openLogin(tester);

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.text('Entrez votre e-mail.'), findsOneWidget);
    expect(find.text('Entrez votre mot de passe.'), findsOneWidget);
  });

  testWidgets('E-mail invalide : message de format', (tester) async {
    await _openLogin(tester);

    await _fill(tester, email: 'pasunemail', password: 'secret12');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.text('Format d\'e-mail invalide.'), findsOneWidget);
  });

  testWidgets('Mot de passe erroné → message UNAUTHORIZED, reste sur Login', (
    tester,
  ) async {
    await _openLogin(tester);

    await _fill(tester, email: 'etudiant@sup2i.ma', password: 'wrong');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
  });

  testWidgets('Compte bloqué → message ACCOUNT_BLOCKED', (tester) async {
    await _openLogin(tester);

    await _fill(tester, email: 'blocked@sup2i.ma', password: 'secret12');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.textContaining('bloqué'), findsOneWidget);
  });

  testWidgets('Identifiants valides : Login se ferme (retour au shell)', (
    tester,
  ) async {
    await _openLogin(tester);

    await _fill(tester, email: 'etudiant@sup2i.ma', password: 'secret12');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    // L'écran Login a été fermé (dépilé) ; on est de retour sur le shell.
    expect(find.byKey(const Key('login_submit')), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
