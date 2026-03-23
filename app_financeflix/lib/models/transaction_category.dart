import 'package:flutter/material.dart';

enum TransactionCategory {
  einkommen,
  wohnen,
  lebensmittel,
  transport,
  unterhaltung,
  gesundheit,
  shopping,
  sparen,
  sonstiges;

  String get label => switch (this) {
        einkommen => 'Einkommen',
        wohnen => 'Wohnen',
        lebensmittel => 'Lebensmittel',
        transport => 'Transport',
        unterhaltung => 'Unterhaltung',
        gesundheit => 'Gesundheit',
        shopping => 'Shopping',
        sparen => 'Sparen',
        sonstiges => 'Sonstiges',
      };

  IconData get icon => switch (this) {
        einkommen => Icons.trending_up,
        wohnen => Icons.home,
        lebensmittel => Icons.shopping_cart,
        transport => Icons.directions_car,
        unterhaltung => Icons.movie,
        gesundheit => Icons.local_hospital,
        shopping => Icons.shopping_bag,
        sparen => Icons.savings,
        sonstiges => Icons.more_horiz,
      };

  bool get isIncome => this == einkommen;

  /// Maps to the backend TransactionCategory enum ordinal.
  int get apiValue => index;

  static TransactionCategory fromApiValue(int value) {
    if (value >= 0 && value < values.length) return values[value];
    return sonstiges;
  }
}
