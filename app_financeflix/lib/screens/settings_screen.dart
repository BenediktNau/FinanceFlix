import 'package:flutter/material.dart';
import 'package:app_financeflix/services/auth_service.dart';
import 'package:app_financeflix/services/settings_service.dart';
import 'package:app_financeflix/screens/server_connection_screen.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsService settingsService;
  final AuthService authService;

  const SettingsScreen({
    super.key,
    required this.settingsService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: settingsService,
        builder: (context, _) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Server',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: theme.colorScheme.primary)),
              ),
              ListTile(
                leading: const Icon(Icons.dns_outlined),
                title: const Text('Server URL'),
                subtitle: Text(authService.serverUrl ?? 'Not configured'),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Server Features',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: theme.colorScheme.primary)),
              ),
              ListTile(
                leading: Icon(
                  Icons.smart_toy_outlined,
                  color: settingsService.aiEnabled
                      ? Colors.green
                      : theme.colorScheme.outline,
                ),
                title: const Text('AI Features'),
                subtitle: const Text('Ollama AI categorization'),
                trailing: _featureChip(context, settingsService.aiEnabled),
              ),
              ListTile(
                leading: Icon(
                  Icons.mail_outlined,
                  color: settingsService.mailInboxEnabled
                      ? Colors.green
                      : theme.colorScheme.outline,
                ),
                title: const Text('Mail Inbox'),
                subtitle:
                    const Text('Automatic transactions from email'),
                trailing:
                    _featureChip(context, settingsService.mailInboxEnabled),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Features are configured on the server.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Account',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: theme.colorScheme.primary)),
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh server features'),
                onTap: () async {
                  if (authService.serverUrl != null) {
                    await settingsService
                        .fetchFromServer(authService.serverUrl!);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await authService.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => ServerConnectionScreen(
                          authService: authService,
                          settingsService: settingsService),
                    ),
                    (_) => false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _featureChip(BuildContext context, bool enabled) {
    return Chip(
      label: Text(
        enabled ? 'Enabled' : 'Disabled',
        style: TextStyle(
          color: enabled ? Colors.green.shade700 : Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      backgroundColor:
          enabled ? Colors.green.withAlpha(25) : Colors.grey.withAlpha(25),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
    );
  }
}
