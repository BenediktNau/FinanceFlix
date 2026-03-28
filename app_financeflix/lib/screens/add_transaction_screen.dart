import 'package:flutter/material.dart';
import 'package:app_financeflix/models/transaction_category.dart';
import 'package:app_financeflix/services/finance_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final FinanceService service;
  final int accountId;

  const AddTransactionScreen({
    super.key,
    required this.service,
    required this.accountId,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  TransactionCategory _selectedCategory = TransactionCategory.other;
  DateTime _selectedDate = DateTime.now();
  bool _isIncome = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text);
    final signedAmount = _isIncome ? amount : -amount;
    final description = _descriptionController.text.trim();
    await widget.service.addTransaction(
      widget.accountId,
      signedAmount,
      description.isEmpty ? null : description,
      _selectedCategory,
      _selectedDate,
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
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
                  if (value != null) _selectedCategory = value;
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
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child:
                      Text('Add Transaction', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
