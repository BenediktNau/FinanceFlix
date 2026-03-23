import 'package:flutter/material.dart';
import 'package:app_financeflix/services/finance_service.dart';
import 'package:app_financeflix/screens/account_list_screen.dart';

void main() {
  final service = FinanceService();
  runApp(FinanceFlixApp(service: service));
}

class FinanceFlixApp extends StatelessWidget {
  final FinanceService service;

  const FinanceFlixApp({super.key, required this.service});

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
      home: AccountListScreen(service: service),
    );
  }
}
