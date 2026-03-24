import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:microsoft_kiota_bundle/microsoft_kiota_bundle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_financeflix/ApiClient/api_client.dart';
import 'package:app_financeflix/ApiClient/models/login_request.dart';
import 'package:app_financeflix/ApiClient/models/register_request.dart';

/// AuthenticationProvider that injects a Bearer token into requests.
class BearerTokenAuthProvider implements AuthenticationProvider {
  final String token;

  BearerTokenAuthProvider(this.token);

  @override
  Future<void> authenticateRequest(
    RequestInformation request, [
    Map<String, Object>? additionalAuthenticationContext,
  ]) async {
    request.headers.put('Authorization', 'Bearer $token');
  }
}

class AuthService extends ChangeNotifier {
  static const _serverUrlKey = 'server_url';
  static const _tokenKey = 'auth_token';

  String? _serverUrl;
  String? _token;

  String? get serverUrl => _serverUrl;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  /// Loads previously saved server URL and token from shared preferences.
  Future<void> loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString(_serverUrlKey);
    _token = prefs.getString(_tokenKey);
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

  /// Creates an authenticated Kiota ApiClient with the stored Bearer token.
  ApiClient createAuthenticatedClient() {
    if (_serverUrl == null || _token == null) {
      throw StateError('Not connected or not logged in');
    }
    final adapter = DefaultRequestAdapter(
      authProvider: BearerTokenAuthProvider(_token!),
    );
    adapter.baseUrl = _serverUrl!;
    return ApiClient(adapter);
  }

  /// Tests whether the server is reachable.
  /// Returns null on success, or an error message on failure.
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

  /// Login with email and password using Kiota ApiClient.
  /// Returns null on success, or an error message on failure.
  Future<String?> login(String email, String password) async {
    if (_serverUrl == null) return 'No server configured';
    try {
      final client = _createAnonymousClient(_serverUrl!);
      final request = LoginRequest()
        ..email = email
        ..password = password;

      final result = await client.auth.login.postAsync(request);

      if (result?.isSuccess == true && result?.value != null) {
        _token = result!.value;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
        notifyListeners();
        return null;
      }

      return result?.error ?? 'Login failed';
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  /// Register a new account using Kiota ApiClient.
  /// Returns null on success, or an error message on failure.
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

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }
}
