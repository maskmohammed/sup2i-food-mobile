import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/core/error/api_codes.dart';
import 'package:sup2i_food_mobile/core/error/api_exception.dart';
import 'package:sup2i_food_mobile/features/auth/data/mock_auth_repository.dart';

void main() {
  const repo = MockAuthRepository(latency: Duration.zero);

  test('Succès : retourne une session', () async {
    final session = await repo.login(
      email: 'Etudiant@sup2i.ma',
      password: 'secret12',
    );
    expect(session.displayName, 'etudiant');
    expect(session.token, isNotEmpty);
  });

  test('Mot de passe « wrong » → UNAUTHORIZED', () async {
    expect(
      () => repo.login(email: 'etudiant@sup2i.ma', password: 'wrong'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiCodes.unauthorized,
        ),
      ),
    );
  });

  test('Compte bloqué → ACCOUNT_BLOCKED', () async {
    expect(
      () => repo.login(email: 'blocked@sup2i.ma', password: 'secret12'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiCodes.accountBlocked,
        ),
      ),
    );
  });

  test('Compte suspendu → ACCOUNT_SUSPENDED', () async {
    expect(
      () => repo.login(email: 'suspended@sup2i.ma', password: 'secret12'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiCodes.accountSuspended,
        ),
      ),
    );
  });
}
