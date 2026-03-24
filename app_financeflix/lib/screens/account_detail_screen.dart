import 'package:flutter/material.dart';
import 'package:app_financeflix/models/app_transaction.dart';
import 'package:app_financeflix/services/finance_service.dart';
import 'package:app_financeflix/services/settings_service.dart';
import 'add_transaction_screen.dart';
import 'mail_inbox_screen.dart';

class AccountDetailScreen extends StatelessWidget {
  final FinanceService service;
  final SettingsService settingsService;
  final int accountId;

  const AccountDetailScreen({
    super.key,
    required this.service,
    required this.settingsService,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final account = service.accountById(accountId);
        if (account == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Account not found')),
          );
        }
        final transactions = service.transactionsFor(accountId);
        return Scaffold(
          appBar: AppBar(
            title: Text(account.name),
            actions: [
              ListenableBuilder(
                listenable: settingsService,
                builder: (context, _) {
                  if (!settingsService.mailInboxEnabled) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.mail_outlined),
                    tooltip: 'Mail Inboxes',
                    onPressed: () {
                      if (service.apiClient == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MailInboxScreen(
                            apiClient: service.apiClient!,
                            accountId: accountId,
                            accountName: account.name,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              _buildBalanceCard(context, account.balance),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Transactions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      '${transactions.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: transactions.isEmpty
                    ? _buildEmptyTransactions(context)
                    : _buildTransactionList(context, transactions),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(
                    service: service,
                    accountId: accountId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Transaction'),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            Text(
              'Balance',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${balance.toStringAsFixed(2)} \u20AC',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        balance >= 0 ? colorScheme.primary : colorScheme.error,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
      BuildContext context, List<AppTransaction> transactions) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _buildTransactionTile(context, tx);
      },
    );
  }

  Widget _buildTransactionTile(BuildContext context, AppTransaction tx) {
    final isPositive = tx.amount >= 0;
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isPositive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        child: Icon(
          tx.category.icon,
          color: isPositive ? Colors.green : Colors.red,
        ),
      ),
      title: Text(tx.category.label),
      subtitle: Text(
        '${tx.date.day.toString().padLeft(2, '0')}.'
        '${tx.date.month.toString().padLeft(2, '0')}.'
        '${tx.date.year}',
        style: TextStyle(color: colorScheme.outline),
      ),
      trailing: Text(
        '${isPositive ? '+' : ''}${tx.amount.toStringAsFixed(2)} \u20AC',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isPositive ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
