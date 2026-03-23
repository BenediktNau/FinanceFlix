import 'package:flutter/material.dart';
import 'package:app_financeflix/models/account.dart';
import 'package:app_financeflix/services/finance_service.dart';
import 'create_account_screen.dart';
import 'account_detail_screen.dart';

class AccountListScreen extends StatelessWidget {
  final FinanceService service;

  const AccountListScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinanceFlix'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: service,
        builder: (context, _) {
          final accounts = service.accounts;
          if (accounts.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, index) =>
                _buildAccountCard(context, accounts[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('Account'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No accounts yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first account to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _navigateToCreate(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, Account account) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            Icons.account_balance,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          account.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          _formatCurrency(account.balance),
          style: TextStyle(
            color: account.balance >= 0
                ? colorScheme.primary
                : colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AccountDetailScreen(
                service: service,
                accountId: account.id,
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAccountScreen(service: service),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} \u20AC';
  }
}
