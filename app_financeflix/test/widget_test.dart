import 'package:flutter_test/flutter_test.dart';
import 'package:app_financeflix/main.dart';
import 'package:app_financeflix/services/auth_service.dart';
import 'package:app_financeflix/services/settings_service.dart';

void main() {
  testWidgets('App renders server connection screen', (WidgetTester tester) async {
    final authService = AuthService();
    final settingsService = SettingsService();
    await tester.pumpWidget(FinanceFlixApp(
      authService: authService,
      settingsService: settingsService,
    ));

    expect(find.text('FinanceFlix'), findsOneWidget);
    expect(find.text('Connect to your server'), findsOneWidget);
  });
}
