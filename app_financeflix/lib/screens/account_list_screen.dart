import 'package:flutter/material.dart';
import 'package:app_financeflix/models/account.dart';
import 'package:app_financeflix/services/auth_service.dart';
import 'package:app_financeflix/services/finance_service.dart';
import 'package:app_financeflix/services/settings_service.dart';
import 'create_account_screen.dart';
import 'account_detail_screen.dart';
import 'settings_screen.dart';

class AccountListScreen extends StatefulWidget {
  final FinanceService service;
  final AuthService authService;
  final SettingsService settingsService;

  const AccountListScreen({
    super.key,
    required this.service,
    required this.authService,
    required this.settingsService,
  });

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  @override
  void initState() {
    super.initState();
    widget.service.fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinanceFlix'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    settingsService: widget.settingsService,
                    authService: widget.authService,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.service,
        builder: (context, _) {
          if (widget.service.loadingAccounts && widget.service.accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.service.accountsError != null && widget.service.accounts.isEmpty) {
            return _buildErrorState(context, widget.service.accountsError!);
          }
          final accounts = widget.service.accounts;
          if (accounts.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () => widget.service.fetchAccounts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              itemBuilder: (context, index) =>
                  _buildAccountCard(context, accounts[index]),
            ),
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

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Could not load accounts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => widget.service.fetchAccounts(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
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
                service: widget.service,
                settingsService: widget.settingsService,
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
        builder: (_) => CreateAccountScreen(service: widget.service),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} \u20AC';
  }
}
