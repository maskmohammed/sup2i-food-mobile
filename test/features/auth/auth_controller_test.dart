import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/core/error/api_codes.dart';
import 'package:sup2i_food_mobile/features/auth/application/auth_controller.dart';
import 'package:sup2i_food_mobile/features/auth/data/mock_auth_repository.dart';

void main() {
  AuthController controller() =>
      AuthController(const MockAuthRepository(latency: Duration.zero));

  test('Connexion réussie → authentifié, sans erreur', () async {
    final c = controller();
    final ok = await c.login('etudiant@sup2i.ma', 'secret12');
    expect(ok, isTrue);
    expect(c.isAuthenticated, isTrue);
    expect(c.errorCode, isNull);
  });

  test('Échec → non authentifié, errorCode renseigné', () async {
    final c = controller();
    final ok = await c.login('etudiant@sup2i.ma', 'wrong');
    expect(ok, isFalse);
    expect(c.isAuthenticated, isFalse);
    expect(c.errorCode, ApiCodes.unauthorized);
  });

  test('Déconnexion → non authentifié', () async {
    final c = controller();
    await c.login('etudiant@sup2i.ma', 'secret12');
    await c.logout();
    expect(c.isAuthenticated, isFalse);
  });
}
