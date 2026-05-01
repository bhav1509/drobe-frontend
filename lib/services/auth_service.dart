import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../models/auth_session.dart';
import 'api_config.dart';

class AuthService {
  static const String _googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
  );
  static const String _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static Future<void>? _initializeFuture;

  static String? _accessToken;
  static String? _refreshToken;

  static bool get hasAccessToken => _accessToken != null;

  static Map<String, String> get authorizationHeaders => _authHeaders();

  static Future<void> _initializeGoogleSignIn() {
    return _initializeFuture ??= _googleSignIn.initialize(
      clientId: _googleClientId.isEmpty ? null : _googleClientId,
      serverClientId: _googleServerClientId.isEmpty
          ? null
          : _googleServerClientId,
    );
  }

  static Future<AuthSession> signInWithGoogle() async {
    await _initializeGoogleSignIn();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw Exception('Google sign-in is not supported on this platform.');
    }

    final googleAccount = await _googleSignIn.authenticate();
    final idToken = googleAccount.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google did not return an ID token.');
    }

    final session = await _authenticateWithBackend(
      idToken: idToken,
      email: googleAccount.email,
      displayName: googleAccount.displayName,
    );

    return session;
  }

  static Future<void> logout() async {
    final refreshToken = _refreshToken;
    _accessToken = null;
    _refreshToken = null;

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/auth/logout'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      } catch (_) {}
    }

    await _initializeGoogleSignIn();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  static Future<http.Response> get(Uri uri) async {
    return _sendWithRefresh(() {
      return http.get(uri, headers: _authHeaders());
    });
  }

  static Future<http.Response> delete(Uri uri) async {
    return _sendWithRefresh(() {
      return http.delete(uri, headers: _authHeaders());
    });
  }

  static Future<http.StreamedResponse> sendMultipart(
    http.MultipartRequest request,
  ) async {
    return _sendMultipart(request);
  }

  static Future<AuthSession> _authenticateWithBackend({
    required String idToken,
    required String email,
    required String? displayName,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/google'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('Google authentication failed.');
    }

    return _storeSession(
      jsonDecode(response.body) as Map<String, dynamic>,
      email: email,
      displayName: displayName,
    );
  }

  static Future<http.Response> _sendWithRefresh(
    Future<http.Response> Function() send,
  ) async {
    final response = await send();

    if (response.statusCode != 401) {
      return response;
    }

    await _refresh();
    return send();
  }

  static Future<http.StreamedResponse> _sendMultipart(
    http.MultipartRequest request,
  ) {
    final token = _accessToken;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    return request.send();
  }

  static Future<void> _refresh() async {
    final refreshToken = _refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Sign in required.');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/refresh'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode != 200) {
      _accessToken = null;
      _refreshToken = null;
      throw Exception('Session expired. Please sign in again.');
    }

    _storeSession(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static AuthSession _storeSession(
    Map<String, dynamic> data, {
    String? email,
    String? displayName,
  }) {
    final user = data['user'] as Map<String, dynamic>? ?? {};
    final session = AuthSession(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      userId: user['id'] as int,
      email: email,
      displayName: displayName,
    );

    _accessToken = session.accessToken;
    _refreshToken = session.refreshToken;

    return session;
  }

  static Map<String, String> _authHeaders() {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      return const {};
    }

    return {'Authorization': 'Bearer $token'};
  }
}
