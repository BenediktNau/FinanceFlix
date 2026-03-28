import 'package:flutter/material.dart';
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:app_financeflix/ApiClient/api_client.dart';
import 'package:app_financeflix/ApiClient/models/create_mail_inbox_request.dart';
import 'package:app_financeflix/ApiClient/models/mail_inbox.dart';

class MailInboxScreen extends StatefulWidget {
  final ApiClient apiClient;
  final int accountId;
  final String accountName;

  const MailInboxScreen({
    super.key,
    required this.apiClient,
    required this.accountId,
    required this.accountName,
  });

  @override
  State<MailInboxScreen> createState() => _MailInboxScreenState();
}

class _MailInboxScreenState extends State<MailInboxScreen> {
  List<MailInbox>? _inboxes;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInboxes();
  }

  Future<void> _loadInboxes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await widget.apiClient.mailinbox
          .byAccountId(widget.accountId.toString())
          .getAsync();

      if (!mounted) return;

      if (result?.isSuccess == true && result?.value != null) {
        setState(() {
          _inboxes = result!.value!.toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = result?.error ?? 'Failed to load inboxes';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Connection error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _deleteInbox(MailInbox inbox) async {
    final id = _extractInt(inbox.id);
    if (id == null) return;

    try {
      await widget.apiClient.mailinbox.byAccountId(id.toString()).deleteAsync();
      _loadInboxes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddMailInboxForm(
        apiClient: widget.apiClient,
        accountId: widget.accountId,
        onSaved: () {
          Navigator.pop(context);
          _loadInboxes();
        },
      ),
    );
  }

  int? _extractInt(UntypedNode? node) {
    if (node is UntypedInteger) return node.value;
    if (node is UntypedDouble) return node.value.toInt();
    if (node is UntypedString) return int.tryParse(node.value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mail Inboxes - ${widget.accountName}')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Inbox'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadInboxes, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_inboxes == null || _inboxes!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mail_outline, size: 64,
                color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            const Text('No mail inboxes configured'),
            const SizedBox(height: 8),
            Text(
              'Add an inbox to automatically create\ntransactions from emails',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInboxes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _inboxes!.length,
        itemBuilder: (context, index) {
          final inbox = _inboxes![index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(Icons.mail,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              title: Text(inbox.displayName ?? 'Unnamed'),
              subtitle: Text(
                '${inbox.username ?? ''}@${inbox.imapHost ?? ''}\n'
                'Folder: ${inbox.folderName ?? 'INBOX'}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteInbox(inbox),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AddMailInboxForm extends StatefulWidget {
  final ApiClient apiClient;
  final int accountId;
  final VoidCallback onSaved;

  const _AddMailInboxForm({
    required this.apiClient,
    required this.accountId,
    required this.onSaved,
  });

  @override
  State<_AddMailInboxForm> createState() => _AddMailInboxFormState();
}

class _AddMailInboxFormState extends State<_AddMailInboxForm> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _imapHostController = TextEditingController();
  final _imapPortController = TextEditingController(text: '993');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _folderNameController = TextEditingController(text: 'INBOX');
  bool _useSsl = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _displayNameController.dispose();
    _imapHostController.dispose();
    _imapPortController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _folderNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final request = CreateMailInboxRequest()
        ..accountId = UntypedInteger(widget.accountId)
        ..displayName = _displayNameController.text.trim()
        ..imapHost = _imapHostController.text.trim()
        ..imapPort = UntypedInteger(int.parse(_imapPortController.text.trim()))
        ..username = _usernameController.text.trim()
        ..password = _passwordController.text
        ..folderName = _folderNameController.text.trim()
        ..useSsl = _useSsl;

      final result = await widget.apiClient.mailinbox.postAsync(request);

      if (!mounted) return;

      if (result?.isSuccess == true) {
        widget.onSaved();
      } else {
        setState(() {
          _error = result?.error ?? 'Failed to create inbox';
          _saving = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Connection error: $e';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add Mail Inbox',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'e.g. My Gmail',

                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imapHostController,
                decoration: const InputDecoration(
                  labelText: 'IMAP Host',
                  hintText: 'e.g. imap.gmail.com',

                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _imapPortController,
                      decoration: const InputDecoration(
                        labelText: 'Port',
      
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('SSL'),
                      value: _useSsl,
                      onChanged: (v) => setState(() => _useSsl = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username / Email',

                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',

                ),
                obscureText: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _folderNameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                  hintText: 'INBOX',

                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
