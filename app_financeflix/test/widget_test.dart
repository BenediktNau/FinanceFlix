import 'package:flutter_test/flutter_test.dart';
import 'package:app_financeflix/main.dart';
import 'package:app_financeflix/services/finance_service.dart';

void main() {
  testWidgets('App renders account list screen', (WidgetTester tester) async {
    final service = FinanceService();
    await tester.pumpWidget(FinanceFlixApp(service: service));

    expect(find.text('FinanceFlix'), findsOneWidget);
    expect(find.text('No accounts yet'), findsOneWidget);
  });
}
