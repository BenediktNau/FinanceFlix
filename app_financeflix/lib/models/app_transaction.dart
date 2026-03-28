import 'transaction_category.dart';

class AppTransaction {
  final int id;
  final int accountId;
  final double amount;
  final String? description;
  final TransactionCategory category;
  final DateTime date;
  final int imageCount;

  AppTransaction({
    required this.id,
    required this.accountId,
    required this.amount,
    this.description,
    required this.category,
    required this.date,
    this.imageCount = 0,
  });

  bool get hasImages => imageCount > 0;
}
