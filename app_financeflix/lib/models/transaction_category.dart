import 'package:flutter/material.dart';

enum TransactionCategory {
  income,
  housing,
  groceries,
  transport,
  entertainment,
  health,
  shopping,
  savings,
  other;

  String get label => switch (this) {
        income => 'Income',
        housing => 'Housing',
        groceries => 'Groceries',
        transport => 'Transport',
        entertainment => 'Entertainment',
        health => 'Health',
        shopping => 'Shopping',
        savings => 'Savings',
        other => 'Other',
      };

  IconData get icon => switch (this) {
        income => Icons.trending_up,
        housing => Icons.home,
        groceries => Icons.shopping_cart,
        transport => Icons.directions_car,
        entertainment => Icons.movie,
        health => Icons.local_hospital,
        shopping => Icons.shopping_bag,
        savings => Icons.savings,
        other => Icons.more_horiz,
      };

  bool get isIncome => this == income;

  /// Maps to the backend TransactionCategory enum ordinal.
  int get apiValue => index;

  static TransactionCategory fromApiValue(int value) {
    if (value >= 0 && value < values.length) return values[value];
    return other;
  }
}
