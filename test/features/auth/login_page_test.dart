import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/app.dart';

Future<void> _reachLogin(WidgetTester tester) async {
  await tester.pumpWidget(const Sup2iFoodApp());

  expect(find.byKey(const Key('splash_screen')), findsOneWidget);

  await tester.pump(const Duration(milliseconds: 2000));
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('login_screen')), findsOneWidget);
}

Future<void> _fill(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(find.byKey(const Key('login_email')), email);
  await tester.enterText(find.byKey(const Key('login_password')), password);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('DÃ©marrage final : splash puis login obligatoire', (
    tester,
  ) async {
    await _reachLogin(tester);

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byKey(const Key('login_email')), findsOneWidget);
    expect(find.byKey(const Key('login_password')), findsOneWidget);
    expect(find.text('Bon retour !'), findsOneWidget);
  });

  testWidgets('Aucune inscription ni connexion sociale', (tester) async {
    await _reachLogin(tester);

    expect(find.textContaining('Sign Up'), findsNothing);
    expect(find.textContaining('Inscription'), findsNothing);
    expect(find.textContaining('Google'), findsNothing);
    expect(find.textContaining('Apple'), findsNothing);
  });

  testWidgets('Soumission vide : validation, on reste sur Login', (
    tester,
  ) async {
    await _reachLogin(tester);

    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.text('Entrez votre e-mail.'), findsOneWidget);
    expect(find.text('Entrez votre mot de passe.'), findsOneWidget);
  });

  testWidgets('E-mail invalide : message de format', (tester) async {
    await _reachLogin(tester);

    await _fill(tester, email: 'pasunemail', password: 'secret12');
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.text('Format d\'e-mail invalide.'), findsOneWidget);
  });

  testWidgets('Mot de passe erronÃ© : message UNAUTHORIZED', (tester) async {
    await _reachLogin(tester);

    await _fill(tester, email: 'etudiant@sup2i.ma', password: 'wrong');
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
  });

  testWidgets('Compte bloquÃ© : message ACCOUNT_BLOCKED', (tester) async {
    await _reachLogin(tester);

    await _fill(tester, email: 'blocked@sup2i.ma', password: 'secret12');
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.textContaining('compte est bloqu'), findsOneWidget);
  });

  testWidgets('Identifiants valides : accÃ¨s shell authentifiÃ©', (
    tester,
  ) async {
    await _reachLogin(tester);

    await _fill(tester, email: 'etudiant@sup2i.ma', password: 'secret12');
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_submit')), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('sup2i_food_remembered_email'), 'etudiant@sup2i.ma');
  });
}
