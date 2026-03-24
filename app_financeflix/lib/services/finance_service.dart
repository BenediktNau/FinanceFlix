import 'package:flutter/foundation.dart';
import 'package:app_financeflix/ApiClient/api_client.dart';
import 'package:app_financeflix/models/account.dart';
import 'package:app_financeflix/models/app_transaction.dart';
import 'package:app_financeflix/models/transaction_category.dart';

class FinanceService extends ChangeNotifier {
  final ApiClient? apiClient;

  final List<Account> _accounts = [];
  final List<AppTransaction> _transactions = [];
  int _nextAccountId = 1;
  int _nextTransactionId = 1;

  FinanceService({this.apiClient});

  List<Account> get accounts => List.unmodifiable(_accounts);

  List<AppTransaction> transactionsFor(int accountId) {
    final list =
        _transactions.where((t) => t.accountId == accountId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Account? accountById(int id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void createAccount(String name, double startBalance) {
    _accounts.add(Account(
      id: _nextAccountId++,
      name: name,
      balance: startBalance,
    ));
    notifyListeners();
  }

  void addTransaction(
    int accountId,
    double amount,
    TransactionCategory category,
    DateTime date,
  ) {
    final signedAmount = category.isIncome ? amount : -amount;
    _transactions.add(AppTransaction(
      id: _nextTransactionId++,
      accountId: accountId,
      amount: signedAmount,
      category: category,
      date: date,
    ));
    final account = accountById(accountId);
    if (account != null) {
      account.balance += signedAmount;
    }
    notifyListeners();
  }

  /// Fetches transactions from the API once the backend is ready.
  /// Uses the Kiota-generated> ApiClient.
  Future<void> fetchTransactions() async {
    if (apiClient == null) return;
    final result = await apiClient!.transaction.getAsync();
    if (result?.isSuccess == true && result?.value != null) {
      // TODO: Map Kiota Transaction models to AppTransaction
      // and merge with local state once backend supports full CRUD.
      notifyListeners();
    }
  }
}
