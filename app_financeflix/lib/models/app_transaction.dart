import 'transaction_category.dart';

class AppTransaction {
  final int id;
  final int accountId;
  final double amount;
  final TransactionCategory category;
  final DateTime date;

  AppTransaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.category,
    required this.date,
  });
}
