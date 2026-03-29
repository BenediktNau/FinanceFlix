import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:microsoft_kiota_bundle/microsoft_kiota_bundle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_financeflix/ApiClient/api_client.dart';
import 'package:app_financeflix/ApiClient/models/register_request.dart';

/// AuthenticationProvider that dynamically reads the token from storage.
class DynamicBearerTokenAuthProvider implements AuthenticationProvider {
  final AuthService _authService;

  DynamicBearerTokenAuthProvider(this._authService);

  @override
  Future<void> authenticateRequest(
    RequestInformation request, [
    Map<String, Object>? additionalAuthenticationContext,
  ]) async {
    final token = _authService.accessToken;
    if (token != null) {
      request.headers.put('Authorization', 'Bearer $token');
    }
  }
}

class AuthService extends ChangeNotifier {
  static const _serverUrlKey = 'server_url';
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _serverUrl;
  String? _accessToken;
  String? _refreshToken;

  String? get serverUrl => _serverUrl;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _accessToken != null;

  /// Callback set by the app to handle forced logout (e.g., navigate to login screen).
  VoidCallback? onForceLogout;

  /// Loads previously saved server URL and tokens.
  Future<void> loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString(_serverUrlKey);
    _accessToken = await _secureStorage.read(key: _accessTokenKey);
    _refreshToken = await _secureStorage.read(key: _refreshTokenKey);

    // If we have an access token that looks expired, try to refresh proactively
    if (_accessToken != null && _isAccessTokenExpired() && _refreshToken != null) {
      final refreshed = await refreshAccessToken();
      if (!refreshed) {
        // Refresh failed — clear tokens, user must re-login
        await _clearTokens();
      }
    }

    notifyListeners();
  }

  Future<void> setServerUrl(String url) async {
    _serverUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, _serverUrl!);
    notifyListeners();
  }

  /// Creates an anonymous Kiota ApiClient (no auth) for the given base URL.
  ApiClient _createAnonymousClient(String baseUrl) {
    final adapter = DefaultRequestAdapter(
      authProvider: AnonymousAuthenticationProvider(),
    );
    adapter.baseUrl = baseUrl;
    return ApiClient(adapter);
  }

  /// Creates an authenticated Kiota ApiClient with dynamic token lookup.
  ApiClient createAuthenticatedClient() {
    if (_serverUrl == null || _accessToken == null) {
      throw StateError('Not connected or not logged in');
    }
    final adapter = DefaultRequestAdapter(
      authProvider: DynamicBearerTokenAuthProvider(this),
    );
    adapter.baseUrl = _serverUrl!;
    return ApiClient(adapter);
  }

  /// Tests whether the server is reachable.
  Future<String?> testConnection(String url) async {
    final base = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    try {
      final response = await http
          .get(Uri.parse(base))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode < 500) {
        return null; // reachable
      }
      return 'Server returned status ${response.statusCode}';
    } catch (e) {
      return 'Could not reach server: $e';
    }
  }

  /// Login with email and password using raw HTTP (not Kiota, since the response format changed).
  /// Returns null on success, or an error message on failure.
  Future<String?> login(String email, String password) async {
    if (_serverUrl == null) return 'No server configured';
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['isSuccess'] == true && body['value'] != null) {
          final value = body['value'] as Map<String, dynamic>;
          _accessToken = value['accessToken'] as String;
          _refreshToken = value['refreshToken'] as String;
          await _saveTokens();
          notifyListeners();
          return null;
        }
        return body['error'] as String? ?? 'Login failed';
      }

      return 'Login failed (${response.statusCode})';
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  /// Register a new account using Kiota ApiClient.
  Future<String?> register(String email, String password) async {
    if (_serverUrl == null) return 'No server configured';
    try {
      final client = _createAnonymousClient(_serverUrl!);
      final request = RegisterRequest()
        ..email = email
        ..password = password;

      final result = await client.auth.register.postAsync(request);

      if (result?.isSuccess == true) {
        return null;
      }

      return result?.error ?? 'Registration failed';
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  /// Attempt to refresh the access token using the stored refresh token.
  /// Returns true on success, false on failure.
  Future<bool> refreshAccessToken() async {
    if (_serverUrl == null || _refreshToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['isSuccess'] == true && body['value'] != null) {
          final value = body['value'] as Map<String, dynamic>;
          _accessToken = value['accessToken'] as String;
          _refreshToken = value['refreshToken'] as String;
          await _saveTokens();
          notifyListeners();
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return false;
    }
  }

  Future<void> logout() async {
    // Best-effort: tell the backend to revoke the refresh token
    if (_serverUrl != null && _refreshToken != null) {
      try {
        await http.post(
          Uri.parse('$_serverUrl/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': _refreshToken}),
        );
      } catch (_) {
        // Ignore — we're logging out anyway
      }
    }

    await _clearTokens();
    notifyListeners();
  }

  /// Called by the AuthenticatedHttpClient when a 401 can't be recovered.
  Future<void> forceLogout() async {
    await _clearTokens();
    notifyListeners();
    onForceLogout?.call();
  }

  /// Check if the access token JWT is expired by decoding the payload (no signature verification).
  bool _isAccessTokenExpired() {
    if (_accessToken == null) return true;
    try {
      final parts = _accessToken!.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      // Base64 padding
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final data = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = data['exp'] as int?;
      if (exp == null) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return true; // If we can't decode, assume expired
    }
  }

  Future<void> _saveTokens() async {
    await _secureStorage.write(key: _accessTokenKey, value: _accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: _refreshToken);
  }

  Future<void> _clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}
