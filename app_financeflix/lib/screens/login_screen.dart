import 'package:flutter/material.dart';
import 'package:app_financeflix/services/auth_service.dart';
import 'package:app_financeflix/services/finance_service.dart';
import 'package:app_financeflix/services/settings_service.dart';
import 'package:app_financeflix/screens/account_list_screen.dart';
import 'package:app_financeflix/screens/server_connection_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final SettingsService settingsService;

  const LoginScreen({
    super.key,
    required this.authService,
    required this.settingsService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final error = await widget.authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (error == null) {
      _navigateToApp();
    } else {
      setState(() {
        _loading = false;
        _errorMessage = error;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final error = await widget.authService.register(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (error == null) {
      // Auto-login after registration
      final loginError = await widget.authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      if (loginError == null) {
        _navigateToApp();
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = 'Registered! Please log in.';
      });
    } else {
      setState(() {
        _loading = false;
        _errorMessage = error;
      });
    }
  }

  void _navigateToApp() {
    final apiClient = widget.authService.createAuthenticatedClient();
    final service = FinanceService(apiClient: apiClient);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => AccountListScreen(
          service: service,
          authService: widget.authService,
          settingsService: widget.settingsService,
        ),
      ),
      (_) => false,
    );
  }

  void _changeServer() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            ServerConnectionScreen(authService: widget.authService),
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
                Icon(Icons.lock_outline,
                    size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text('Login',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _changeServer,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dns_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        widget.authService.serverUrl ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.edit,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _errorMessage == 'Registered! Please log in.'
                          ? Colors.green.withAlpha(25)
                          : Colors.red.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: _errorMessage == 'Registered! Please log in.'
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loading ? null : _register,
                    child: const Text('Register'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
