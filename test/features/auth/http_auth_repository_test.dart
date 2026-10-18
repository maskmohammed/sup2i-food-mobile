import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:sup2i_food_mobile/core/error/api_codes.dart';
import 'package:sup2i_food_mobile/core/error/api_exception.dart';
import 'package:sup2i_food_mobile/features/auth/data/http_auth_repository.dart';

const _userId = 'bf430a3d-47ee-4cab-ab7d-afe435266534';

http.Response _jsonResponse(Object payload, int status) => http.Response(
  jsonEncode(payload),
  status,
  headers: const <String, String>{'content-type': 'application/json'},
);

http.Response _loginSuccess() => _jsonResponse(<String, Object>{
  'accessToken': 'access-test-1',
  'refreshToken': 'refresh-test-1',
  'expiresIn': 900,
  'user': <String, Object>{'id': _userId, 'email': 'student@sup2i.ma'},
}, 200);

http.Response _meSuccess() => _jsonResponse(<String, Object>{
  'id': _userId,
  'email': 'student@sup2i.ma',
  'firstName': 'Aya',
  'lastName': 'Idrissi',
  'status': 'ACTIVE',
  'roles': <String>['STUDENT'],
  'student': <String, Object>{
    'id': '665d4ad9-a038-4fba-ad06-2c9cfb7e0350',
    'studentNumber': 'S-2026-001',
    'program': 'INFO',
    'level': 'L3',
    'groupName': 'G1',
  },
}, 200);

void main() {
  final baseUri = Uri.parse('http://localhost:8080');

  test('login reads real API DTO and /me student number', () async {
    final routes = <String>[];
    final client = MockClient((request) async {
      routes.add('${request.method} ${request.url.path}');
      if (request.url.path == '/api/v1/auth/login') {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'student@sup2i.ma');
        expect(body['password'], 'password123');
        return _loginSuccess();
      }
      if (request.url.path == '/api/v1/me') {
        expect(request.method, 'GET');
        expect(request.headers['authorization'], 'Bearer access-test-1');
        return _meSuccess();
      }
      if (request.url.path == '/api/v1/auth/logout') {
        expect(request.method, 'POST');
        expect(request.headers['authorization'], 'Bearer access-test-1');
        return http.Response('', 204);
      }
      return http.Response('', 404);
    });
    final repository = HttpAuthRepository(baseUri: baseUri, client: client);

    final session = await repository.login(
      email: ' STUDENT@SUP2I.MA ',
      password: 'password123',
    );
    expect(session.token, 'access-test-1');
    expect(session.studentId, 'S-2026-001');
    expect(session.displayName, 'Aya Idrissi');
    await repository.logout();
    expect(routes, <String>[
      'POST /api/v1/auth/login',
      'GET /api/v1/me',
      'POST /api/v1/auth/logout',
    ]);
    repository.close();
    client.close();
  });

  test('server ACCOUNT_BLOCKED code survives HTTP translation', () async {
    final client = MockClient(
      (_) async => _jsonResponse(<String, String>{
        'code': 'ACCOUNT_BLOCKED',
        'message': 'not for UI',
      }, 403),
    );
    final repository = HttpAuthRepository(baseUri: baseUri, client: client);
    await expectLater(
      repository.login(email: 'blocked@sup2i.ma', password: 'password123'),
      throwsA(
        isA<ApiException>().having(
          (exception) => exception.code,
          'code',
          ApiCodes.accountBlocked,
        ),
      ),
    );
    client.close();
  });

  test('missing JSON error envelope maps 401 to UNAUTHORIZED', () async {
    final client = MockClient((_) async => http.Response('', 401));
    final repository = HttpAuthRepository(baseUri: baseUri, client: client);
    await expectLater(
      repository.login(email: 'student@sup2i.ma', password: 'badpassword'),
      throwsA(
        isA<ApiException>().having(
          (exception) => exception.code,
          'code',
          ApiCodes.unauthorized,
        ),
      ),
    );
    client.close();
  });

  test('malformed success response cannot create a session', () async {
    final client = MockClient(
      (_) async =>
          _jsonResponse(<String, Object>{'accessToken': 'token-only'}, 200),
    );
    final repository = HttpAuthRepository(baseUri: baseUri, client: client);
    await expectLater(
      repository.login(email: 'student@sup2i.ma', password: 'password123'),
      throwsA(
        isA<ApiException>().having(
          (exception) => exception.code,
          'code',
          ApiCodes.internalError,
        ),
      ),
    );
    client.close();
  });

  test('user without student record is refused', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/v1/auth/login') return _loginSuccess();
      final me = <String, Object?>{
        'id': _userId,
        'email': 'user@sup2i.ma',
        'student': null,
      };
      return _jsonResponse(me, 200);
    });
    final repository = HttpAuthRepository(baseUri: baseUri, client: client);
    await expectLater(
      repository.login(email: 'user@sup2i.ma', password: 'password123'),
      throwsA(
        isA<ApiException>().having(
          (exception) => exception.code,
          'code',
          ApiCodes.unauthorized,
        ),
      ),
    );
    client.close();
  });

  test('remote cleartext API URL is rejected', () {
    expect(
      () => HttpAuthRepository(baseUri: Uri.parse('http://example.com')),
      throwsArgumentError,
    );
  });
}
