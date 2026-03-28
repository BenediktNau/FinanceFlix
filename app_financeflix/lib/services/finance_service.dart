import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:app_financeflix/ApiClient/api_client.dart';
import 'package:app_financeflix/ApiClient/models/create_account_request.dart';
import 'package:app_financeflix/ApiClient/models/create_transaction_request.dart';
import 'package:app_financeflix/ApiClient/models/update_transaction_request.dart';
import 'package:app_financeflix/models/account.dart';
import 'package:app_financeflix/models/app_transaction.dart';
import 'package:app_financeflix/models/transaction_category.dart';

class FinanceService extends ChangeNotifier {
  final ApiClient? apiClient;
  final String? serverUrl;
  final String? token;

  final List<Account> _accounts = [];
  final List<AppTransaction> _transactions = [];
  String? _accountsError;
  String? _transactionsError;
  bool _loadingAccounts = false;
  bool _loadingTransactions = false;

  FinanceService({this.apiClient, this.serverUrl, this.token});

  List<Account> get accounts => List.unmodifiable(_accounts);
  String? get accountsError => _accountsError;
  String? get transactionsError => _transactionsError;
  bool get loadingAccounts => _loadingAccounts;
  bool get loadingTransactions => _loadingTransactions;

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

  Future<void> fetchAccounts() async {
    if (apiClient == null) return;
    _loadingAccounts = true;
    _accountsError = null;
    notifyListeners();
    try {
      final result = await apiClient!.account.getAsync();
      if (result?.isSuccess == true && result?.value != null) {
        _accounts.clear();
        for (final a in result!.value!) {
          final id = _extractInt(a.accountId);
          final name = a.accountName;
          final balance = _extractDouble(a.balance);
          if (id != null && name != null) {
            _accounts.add(Account(
              id: id,
              name: name,
              balance: balance ?? 0.0,
            ));
          }
        }
      }
    } catch (e) {
      _accountsError = 'Failed to load accounts: $e';
      debugPrint(_accountsError);
    } finally {
      _loadingAccounts = false;
      notifyListeners();
    }
  }

  Future<void> createAccount(String name, double startBalance) async {
    if (apiClient == null) return;
    try {
      final request = CreateAccountRequest()
        ..accountName = name
        ..balance = UntypedDouble(startBalance);
      await apiClient!.account.postAsync(request);
      await fetchAccounts();
    } catch (e) {
      debugPrint('Failed to create account: $e');
    }
  }

  Future<void> fetchTransactions() async {
    if (apiClient == null) return;
    _loadingTransactions = true;
    _transactionsError = null;
    notifyListeners();
    try {
      final result = await apiClient!.transaction.getAsync();
      if (result?.isSuccess == true && result?.value != null) {
        _transactions.clear();
        for (final t in result!.value!) {
          final id = _extractInt(t.id);
          final accountId = _extractInt(t.accountId);
          final amount = _extractDouble(t.amount);
          final category = t.category != null
              ? TransactionCategory.fromApiValue(t.category!)
              : TransactionCategory.other;
          final date = t.date ?? DateTime.now();
          final description = t.description;
          if (id != null && accountId != null) {
            _transactions.add(AppTransaction(
              id: id,
              accountId: accountId,
              amount: amount ?? 0.0,
              description: description,
              category: category,
              date: date,
              imageCount: _extractInt(t.imageCount) ?? 0,
            ));
          }
        }
      }
    } catch (e) {
      _transactionsError = 'Failed to load transactions: $e';
      debugPrint(_transactionsError);
    } finally {
      _loadingTransactions = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(
    int accountId,
    double amount,
    String? description,
    TransactionCategory category,
    DateTime date,
  ) async {
    if (apiClient == null) return;
    try {
      final request = CreateTransactionRequest()
        ..accountId = UntypedInteger(accountId)
        ..amount = UntypedDouble(amount)
        ..description = description
        ..category = category.apiValue
        ..date = date;
      await apiClient!.transaction.postAsync(request);
      await fetchTransactions();
      await fetchAccounts();
    } catch (e) {
      debugPrint('Failed to add transaction: $e');
    }
  }

  Future<void> updateTransaction(
    int transactionId,
    double amount,
    String? description,
    TransactionCategory category,
    DateTime date,
  ) async {
    if (apiClient == null) return;
    try {
      final request = UpdateTransactionRequest()
        ..amount = UntypedDouble(amount)
        ..description = description
        ..category = category.apiValue
        ..date = date;
      await apiClient!.transaction.byId(transactionId.toString()).putAsync(request);
      await fetchTransactions();
      await fetchAccounts();
    } catch (e) {
      debugPrint('Failed to update transaction: $e');
    }
  }

  Future<List<int>> fetchTransactionImageIds(int transactionId) async {
    if (serverUrl == null || token == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/transaction/$transactionId/images'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> ids = jsonDecode(response.body);
        return ids.cast<int>();
      }
      return [];
    } catch (e) {
      debugPrint('Failed to fetch transaction image IDs: $e');
      return [];
    }
  }

  Future<Uint8List?> fetchTransactionImage(int transactionId, int imageId) async {
    if (serverUrl == null || token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/transaction/$transactionId/image/$imageId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return response.bodyBytes;
      return null;
    } catch (e) {
      debugPrint('Failed to fetch transaction image: $e');
      return null;
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    if (apiClient == null) return;
    try {
      await apiClient!.transaction.byId(transactionId.toString()).deleteAsync();
      await fetchTransactions();
      await fetchAccounts();
    } catch (e) {
      debugPrint('Failed to delete transaction: $e');
    }
  }

  int? _extractInt(UntypedNode? node) {
    if (node is UntypedInteger) return node.value;
    if (node is UntypedDouble) return node.value.toInt();
    if (node is UntypedString) return int.tryParse(node.value);
    return null;
  }

  double? _extractDouble(UntypedNode? node) {
    if (node is UntypedDouble) return node.value;
    if (node is UntypedInteger) return node.value.toDouble();
    if (node is UntypedString) return double.tryParse(node.value);
    return null;
  }
}
