import 'package:flutter/foundation.dart';
import 'package:microsoft_kiota_bundle/microsoft_kiota_bundle.dart';
import 'package:app_financeflix/ApiClient/api_client.dart';

class SettingsService extends ChangeNotifier {
  bool _aiEnabled = false;
  bool _mailInboxEnabled = false;
  bool _loaded = false;

  bool get aiEnabled => _aiEnabled;
  bool get mailInboxEnabled => _mailInboxEnabled;
  bool get loaded => _loaded;

  /// Fetches the server's feature flags via Kiota ApiClient (GET /features).
  Future<void> fetchFromServer(String serverUrl) async {
    try {
      final adapter = DefaultRequestAdapter(
        authProvider: AnonymousAuthenticationProvider(),
      );
      adapter.baseUrl = serverUrl.endsWith('/')
          ? serverUrl.substring(0, serverUrl.length - 1)
          : serverUrl;
      final client = ApiClient(adapter);

      final result = await client.features.getAsync();

      if (result != null) {
        _aiEnabled = result.aiEnabled ?? false;
        _mailInboxEnabled = result.mailInboxEnabled ?? false;
        _loaded = true;
        notifyListeners();
      }
    } catch (_) {
      // Server might not support /features yet — keep defaults
    }
  }
}
