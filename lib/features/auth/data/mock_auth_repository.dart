import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../domain/auth_session.dart';
import 'auth_repository.dart';

/// Implémentation mock de [AuthRepository] (M2, en attendant le backend).
///
/// Déterministe pour les tests. Déclencheurs :
/// - `blocked@sup2i.ma`   → `ACCOUNT_BLOCKED`
/// - `suspended@sup2i.ma` → `ACCOUNT_SUSPENDED`
/// - mot de passe `wrong` → `UNAUTHORIZED`
/// - sinon                → succès
class MockAuthRepository implements AuthRepository {
  const MockAuthRepository({this.latency = const Duration(milliseconds: 300)});

  final Duration latency;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);

    final normalized = email.trim().toLowerCase();
    switch (normalized) {
      case 'blocked@sup2i.ma':
        throw const ApiException(ApiCodes.accountBlocked);
      case 'suspended@sup2i.ma':
        throw const ApiException(ApiCodes.accountSuspended);
    }
    if (password == 'wrong') {
      throw const ApiException(ApiCodes.unauthorized);
    }

    final name = normalized.contains('@')
        ? normalized.split('@').first
        : normalized;
    return AuthSession(
      token: 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
      studentId: 'S-0001',
      displayName: name,
    );
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(latency);
  }
}
