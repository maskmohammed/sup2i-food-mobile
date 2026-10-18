import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../domain/auth_session.dart';
import 'auth_repository.dart';

/// HTTP adapter for the existing backend contract (not a mock).
///
/// Access tokens are kept in memory only in this first F2 slice. Refresh,
/// secure persistence, MFA entry and automatic session recovery are separate
/// follow-up work. No password, token or server message is logged.
class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository({
    required Uri baseUri,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _baseUri = baseUri,
       _client = client ?? http.Client(),
       _ownsClient = client == null {
    if (!baseUri.hasAuthority ||
        (baseUri.scheme != 'http' && baseUri.scheme != 'https') ||
        (baseUri.path.isNotEmpty && baseUri.path != '/') ||
        baseUri.hasQuery ||
        baseUri.hasFragment ||
        baseUri.userInfo.isNotEmpty) {
      throw ArgumentError.value(baseUri, 'baseUri', 'Expected an API origin');
    }
    // Plain HTTP is only acceptable for a local development backend.
    if (baseUri.scheme == 'http' &&
        baseUri.host != 'localhost' &&
        baseUri.host != '127.0.0.1' &&
        baseUri.host != '10.0.2.2') {
      throw ArgumentError.value(
        baseUri,
        'baseUri',
        'Remote API must use HTTPS',
      );
    }
  }

  final Uri _baseUri;
  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;
  String? _accessToken;

  Uri _url(String path) => _baseUri.replace(path: path);

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(timeout);
    } on TimeoutException {
      throw const ApiException.network();
    } on http.ClientException {
      throw const ApiException.network();
    }
  }

  Map<String, dynamic> _jsonObject(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // An invalid server response is not a valid authenticated session.
    }
    throw const ApiException(ApiCodes.internalError);
  }

  String _requiredString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String && value.isNotEmpty) return value;
    throw const ApiException(ApiCodes.internalError);
  }

  void _requireSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        final code = decoded['code'];
        if (code is String && code.isNotEmpty) throw ApiException(code);
      }
    } on FormatException {
      // Fall back to status when the server has no JSON error envelope.
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const ApiException(ApiCodes.unauthorized);
    }
    if (response.statusCode == 429) {
      throw const ApiException(ApiCodes.rateLimited);
    }
    throw const ApiException(ApiCodes.internalError);
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    _accessToken = null;
    final loginResponse = await _send(
      () => _client.post(
        _url('/api/v1/auth/login'),
        headers: const <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      ),
    );
    _requireSuccess(loginResponse);

    final payload = _jsonObject(loginResponse);
    final accessToken = _requiredString(payload, 'accessToken');
    _requiredString(payload, 'refreshToken');
    final expiresIn = payload['expiresIn'];
    if (expiresIn is! int || expiresIn <= 0) {
      throw const ApiException(ApiCodes.internalError);
    }
    final userData = payload['user'];
    if (userData is! Map<String, dynamic>) {
      throw const ApiException(ApiCodes.internalError);
    }
    final userId = _requiredString(userData, 'id');

    // /auth/login returns a user identity, not a student number.
    // /me is the documented student-profile source of truth.
    final meResponse = await _send(
      () => _client.get(
        _url('/api/v1/me'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    _requireSuccess(meResponse);
    final me = _jsonObject(meResponse);
    if (_requiredString(me, 'id') != userId) {
      throw const ApiException(ApiCodes.internalError);
    }
    final student = me['student'];
    if (student is! Map<String, dynamic>) {
      throw const ApiException(ApiCodes.unauthorized);
    }
    final studentNumber = _requiredString(student, 'studentNumber');
    final firstName = me['firstName'] is String
        ? me['firstName'] as String
        : '';
    final lastName = me['lastName'] is String ? me['lastName'] as String : '';
    final fullName = <String>[
      firstName,
      lastName,
    ].where((part) => part.trim().isNotEmpty).join(' ').trim();
    final displayName = fullName.isNotEmpty
        ? fullName
        : _requiredString(me, 'email');

    _accessToken = accessToken;
    return AuthSession(
      token: accessToken,
      studentId: studentNumber,
      displayName: displayName,
    );
  }

  @override
  Future<void> logout() async {
    final token = _accessToken;
    _accessToken = null;
    if (token == null) return;
    // Local logout must succeed even when the backend is temporarily down.
    // Revocation is best-effort; this limitation must be revisited in F2.
    try {
      await _send(
        () => _client.post(
          _url('/api/v1/auth/logout'),
          headers: <String, String>{'Authorization': 'Bearer $token'},
        ),
      );
    } on Exception {
      // Credentials are already discarded in memory.
    }
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}
