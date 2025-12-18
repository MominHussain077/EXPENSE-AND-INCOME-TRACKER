import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final Expense? expense;
  const ExpenseFormScreen({super.key, this.expense});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  String _category = 'Other';
  DateTime _date = DateTime.now();
  bool _loading = false;

  static const categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Other'];

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleController = TextEditingController(text: e?.title ?? '');
    _amountController = TextEditingController(
      text: e != null ? e.amount.toString() : '',
    );
    _category = e?.category ?? _category;
    _date = e?.date ?? _date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<String> _probeFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('expenses')
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 6));
      return 'Firestore reachable';
    } on FirebaseException catch (e) {
      return 'Firestore: ${e.code}';
    } on TimeoutException {
      return 'Firestore unreachable (network/firewall)';
    } catch (e) {
      return 'Firestore probe failed: $e';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final service = ref.read(expenseServiceProvider);
    final user = FirebaseAuth.instance.currentUser!;
    final expense = Expense(
      id: widget.expense?.id ?? '',
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _category,
      date: _date,
      userId: user.uid,
    );

    try {
      debugPrint(
        'Saving expense: ${expense.title} ${expense.amount} for user ${expense.userId}',
      );
      // Add a timeout so UI doesn't hang indefinitely
      if (widget.expense == null) {
        final id = await service.addExpense(expense);
        debugPrint('Document created id=$id');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Expense saved')));
        }
      } else {
        await service
            .updateExpense(expense)
            .timeout(const Duration(seconds: 15));
      }
      debugPrint('Expense saved successfully');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on TimeoutException catch (_) {
      debugPrint('Expense save timed out');
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final probe = await _probeFirestore();
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Save timed out. $probe.\nIf Firestore is reachable but writes fail, update Firestore rules.',
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } on FirebaseException catch (e, st) {
      debugPrint('Firebase error: ${e.code} ${e.message}\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firebase: ${e.code} ${e.message ?? ''}')),
        );
      }
    } catch (e, st) {
      debugPrint('Expense save failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v?.isEmpty ?? true) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter an amount';
                  final parsed = double.tryParse(v);
                  if (parsed == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_date)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: 16),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.0),
                          child: Text('Save'),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
