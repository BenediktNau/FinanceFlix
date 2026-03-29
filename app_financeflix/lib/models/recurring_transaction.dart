import 'transaction_category.dart';

enum RecurrenceFrequency {
  daily,
  weekly,
  biWeekly,
  monthly,
  quarterly,
  yearly;

  String get label => switch (this) {
        daily => 'Daily',
        weekly => 'Weekly',
        biWeekly => 'Bi-weekly',
        monthly => 'Monthly',
        quarterly => 'Quarterly',
        yearly => 'Yearly',
      };

  int get apiValue => index;

  static RecurrenceFrequency fromApiValue(int value) {
    if (value >= 0 && value < values.length) return values[value];
    return monthly;
  }
}

class RecurringTransaction {
  final int id;
  final int accountId;
  final double amount;
  final String description;
  final TransactionCategory category;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime nextExecutionDate;

  RecurringTransaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.description,
    required this.category,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.nextExecutionDate,
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'] as int,
      accountId: json['accountId'] as int,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      category: TransactionCategory.fromApiValue(json['category'] as int? ?? 8),
      frequency: RecurrenceFrequency.fromApiValue(json['frequency'] as int? ?? 3),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      isActive: json['isActive'] as bool? ?? true,
      nextExecutionDate: DateTime.parse(json['nextExecutionDate'] as String),
    );
  }
}
