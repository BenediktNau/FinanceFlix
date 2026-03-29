import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:app_financeflix/services/auth_service.dart';

/// HTTP client wrapper that automatically attaches the Bearer token,
/// intercepts 401 responses, attempts a token refresh, and retries the request.
class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner;
  final AuthService _authService;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  AuthenticatedHttpClient(this._authService) : _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Attach current access token
    _attachToken(request);

    final response = await _inner.send(request);

    if (response.statusCode == 401) {
      // Attempt refresh, then retry
      final refreshed = await _tryRefresh();
      if (refreshed) {
        // Retry with new token — need to copy the request since streams are consumed
        final retryRequest = _copyRequest(request);
        _attachToken(retryRequest);
        return _inner.send(retryRequest);
      } else {
        // Refresh failed — force logout
        await _authService.forceLogout();
      }
    }

    return response;
  }

  void _attachToken(http.BaseRequest request) {
    final token = _authService.accessToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Ensures only one refresh is in-flight at a time using a Completer.
  Future<bool> _tryRefresh() async {
    if (_isRefreshing) {
      // Another call is already refreshing — wait for its result
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final result = await _authService.refreshAccessToken();
      _refreshCompleter!.complete(result);
      return result;
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Copies a BaseRequest so it can be resent (original stream is consumed).
  http.BaseRequest _copyRequest(http.BaseRequest original) {
    if (original is http.MultipartRequest) {
      final copy = http.MultipartRequest(original.method, original.url)
        ..headers.addAll(original.headers)
        ..fields.addAll(original.fields)
        ..files.addAll(original.files);
      return copy;
    }

    if (original is http.Request) {
      final copy = http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..body = original.body
        ..encoding = original.encoding;
      return copy;
    }

    // Fallback: StreamedRequest can't easily be copied, but we don't use it
    return http.Request(original.method, original.url)
      ..headers.addAll(original.headers);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
