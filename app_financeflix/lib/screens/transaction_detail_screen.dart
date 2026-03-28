import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:app_financeflix/models/app_transaction.dart';
import 'package:app_financeflix/models/transaction_category.dart';
import 'package:app_financeflix/services/finance_service.dart';

class TransactionDetailScreen extends StatefulWidget {
  final FinanceService service;
  final int transactionId;
  final int accountId;

  const TransactionDetailScreen({
    super.key,
    required this.service,
    required this.transactionId,
    required this.accountId,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  bool _editing = false;
  late final GlobalKey<FormState> _formKey;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TransactionCategory _selectedCategory;
  late DateTime _selectedDate;
  late bool _isIncome;
  Future<List<int>>? _imageIdsFuture;
  final Map<int, Future<Uint8List?>> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedCategory = TransactionCategory.other;
    _selectedDate = DateTime.now();
    _isIncome = false;
    _loadImagesIfNeeded();
  }

  void _loadImagesIfNeeded() {
    final tx = _findTransaction();
    if (tx != null && tx.hasImages) {
      _imageIdsFuture =
          widget.service.fetchTransactionImageIds(widget.transactionId);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  AppTransaction? _findTransaction() {
    final transactions = widget.service.transactionsFor(widget.accountId);
    try {
      return transactions.firstWhere((t) => t.id == widget.transactionId);
    } catch (_) {
      return null;
    }
  }

  void _startEditing(AppTransaction tx) {
    _amountController.text = tx.amount.abs().toStringAsFixed(2);
    _descriptionController.text = tx.description ?? '';
    _selectedCategory = tx.category;
    _selectedDate = tx.date;
    _isIncome = tx.amount >= 0;
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    setState(() => _editing = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text);
    final signedAmount = _isIncome ? amount : -amount;
    final description = _descriptionController.text.trim();
    await widget.service.updateTransaction(
      widget.transactionId,
      signedAmount,
      description.isEmpty ? null : description,
      _selectedCategory,
      _selectedDate,
    );
    if (!mounted) return;
    setState(() => _editing = false);
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await widget.service.deleteTransaction(widget.transactionId);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        final tx = _findTransaction();
        if (tx == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Transaction not found')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(_editing ? 'Edit Transaction' : 'Transaction Details'),
            actions: [
              if (!_editing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                  onPressed: () => _startEditing(tx),
                ),
              if (!_editing)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: _deleteTransaction,
                ),
              if (_editing)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Cancel',
                  onPressed: _cancelEditing,
                ),
            ],
          ),
          body: _editing ? _buildEditForm(context) : _buildDetails(context, tx),
        );
      },
    );
  }

  Widget _buildDetails(BuildContext context, AppTransaction tx) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = tx.amount >= 0;
    final amountColor = isPositive ? Colors.green : Colors.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: amountColor.withValues(alpha: 0.1),
            child: Icon(tx.category.icon, size: 40, color: amountColor),
          ),
          const SizedBox(height: 16),
          Text(
            '${isPositive ? '+' : ''}${tx.amount.toStringAsFixed(2)} \u20AC',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isPositive ? 'Income' : 'Expense',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.outline,
                ),
          ),
          const SizedBox(height: 32),
          _detailRow(
            context,
            icon: Icons.category,
            label: 'Category',
            value: tx.category.label,
          ),
          const Divider(height: 1),
          _detailRow(
            context,
            icon: Icons.description,
            label: 'Description',
            value: tx.description ?? '-',
          ),
          const Divider(height: 1),
          _detailRow(
            context,
            icon: Icons.calendar_today,
            label: 'Date',
            value: '${tx.date.day.toString().padLeft(2, '0')}.'
                '${tx.date.month.toString().padLeft(2, '0')}.'
                '${tx.date.year}',
          ),
          if (tx.hasImages && _imageIdsFuture != null) ...[
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(
              'Order Images',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<int>>(
              future: _imageIdsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final imageIds = snapshot.data;
                if (imageIds == null || imageIds.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: imageIds.map((imageId) {
                    _imageCache.putIfAbsent(
                      imageId,
                      () => widget.service.fetchTransactionImage(
                          widget.transactionId, imageId),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FutureBuilder<Uint8List?>(
                        future: _imageCache[imageId],
                        builder: (context, imgSnapshot) {
                          if (imgSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 150,
                              child:
                                  Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (imgSnapshot.data == null) {
                            return const SizedBox.shrink();
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.memory(
                              imgSnapshot.data!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Expense'),
                  icon: Icon(Icons.trending_down),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Income'),
                  icon: Icon(Icons.trending_up),
                ),
              ],
              selected: {_isIncome},
              onSelectionChanged: (set) =>
                  setState(() => _isIncome = set.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                prefixIcon: Icon(
                  Icons.euro,
                  color: _isIncome ? Colors.green : Colors.red,
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return 'Please enter a positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'e.g. Grocery shopping',
                prefixIcon: Icon(Icons.description),

              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TransactionCategory>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),

              ),
              items: TransactionCategory.values
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon, size: 20),
                            const SizedBox(width: 12),
                            Text(cat.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
  
                ),
                child: Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}.'
                  '${_selectedDate.month.toString().padLeft(2, '0')}.'
                  '${_selectedDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saveChanges,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child:
                    Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
