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
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (authService.isLoggedIn) {
      final apiClient = authService.createAuthenticatedClient();
      final service = FinanceService(
        apiClient: apiClient,
        serverUrl: authService.serverUrl,
        token: authService.token,
      );
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
