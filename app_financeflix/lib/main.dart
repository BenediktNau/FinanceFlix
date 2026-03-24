import 'package:flutter/material.dart';
import 'package:app_financeflix/services/auth_service.dart';
import 'package:app_financeflix/services/finance_service.dart';
import 'package:app_financeflix/services/settings_service.dart';
import 'package:app_financeflix/screens/server_connection_screen.dart';
import 'package:app_financeflix/screens/login_screen.dart';
import 'package:app_financeflix/screens/account_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final settingsService = SettingsService();
  await authService.loadSavedState();

  // Fetch server features if we have a server URL
  if (authService.serverUrl != null) {
    await settingsService.fetchFromServer(authService.serverUrl!);
  }

  runApp(FinanceFlixApp(
    authService: authService,
    settingsService: settingsService,
  ));
}

class FinanceFlixApp extends StatelessWidget {
  final AuthService authService;
  final SettingsService settingsService;

  const FinanceFlixApp({
    super.key,
    required this.authService,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanceFlix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (authService.isLoggedIn) {
      final apiClient = authService.createAuthenticatedClient();
      final service = FinanceService(apiClient: apiClient);
      return AccountListScreen(
        service: service,
        authService: authService,
        settingsService: settingsService,
      );
    }

    if (authService.serverUrl != null) {
      return LoginScreen(
        authService: authService,
        settingsService: settingsService,
      );
    }

    return ServerConnectionScreen(
      authService: authService,
      settingsService: settingsService,
    );
  }
}
