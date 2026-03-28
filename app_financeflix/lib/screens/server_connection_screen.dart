import 'package:flutter/material.dart';
import 'package:app_financeflix/services/auth_service.dart';
import 'package:app_financeflix/services/settings_service.dart';
import 'package:app_financeflix/screens/login_screen.dart';

class ServerConnectionScreen extends StatefulWidget {
  final AuthService authService;
  final SettingsService? settingsService;

  const ServerConnectionScreen({
    super.key,
    required this.authService,
    this.settingsService,
  });

  @override
  State<ServerConnectionScreen> createState() => _ServerConnectionScreenState();
}

class _ServerConnectionScreenState extends State<ServerConnectionScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _testing = false;
  String? _statusMessage;
  bool? _connectionOk;

  @override
  void initState() {
    super.initState();
    if (widget.authService.serverUrl != null) {
      _urlController.text = widget.authService.serverUrl!;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _testing = true;
      _statusMessage = null;
      _connectionOk = null;
    });

    final error =
        await widget.authService.testConnection(_urlController.text.trim());

    if (!mounted) return;
    setState(() {
      _testing = false;
      if (error == null) {
        _connectionOk = true;
        _statusMessage = 'Connection successful!';
      } else {
        _connectionOk = false;
        _statusMessage = error;
      }
    });
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;

    final url = _urlController.text.trim();
    await widget.authService.setServerUrl(url);

    // Fetch server feature flags
    final settings = widget.settingsService ?? SettingsService();
    await settings.fetchFromServer(url);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          authService: widget.authService,
          settingsService: settings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_outlined,
                    size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text('FinanceFlix',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Connect to your server',
                    style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Server URL',
                    hintText: 'http://192.168.1.100:3000',
                    prefixIcon: Icon(Icons.dns_outlined),

                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a server URL';
                    }
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                      return 'Enter a valid URL (e.g. http://192.168.1.100:3000)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_statusMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _connectionOk == true
                          ? Colors.green.withAlpha(25)
                          : Colors.red.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _connectionOk == true
                              ? Icons.check_circle
                              : Icons.error,
                          color: _connectionOk == true
                              ? Colors.green
                              : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMessage!,
                            style: TextStyle(
                              color: _connectionOk == true
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _testing ? null : _testConnection,
                        icon: _testing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.wifi_find),
                        label: const Text('Test'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _testing ? null : _connect,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Connect'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
