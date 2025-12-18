import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'dart:async';
import '../models/expense.dart';

/// Service that performs CRUD operations against Firestore for expenses.
class ExpenseService {
  final FirebaseFirestore _firestore;

  ExpenseService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _expensesRef() =>
      _firestore.collection('expenses');

  /// Stream of expenses for a given user (ordered by date desc)
  Stream<List<Expense>> streamExpensesForUser(String userId) {
    // Avoid requiring a composite index (where + orderBy) by sorting client-side.
    return _expensesRef().where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs.map((d) => Expense.fromDocument(d)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  /// Add a new expense and return the generated document id
  Future<String> addExpense(Expense expense) async {
    try {
      // Use a known doc id so the UI can reference it.
      final docRef = _expensesRef().doc();
      // Don't force a server read here; on Web this can hang depending on
      // network/proxy rules and makes the UX look broken.
      await docRef.set(expense.toJson()).timeout(const Duration(seconds: 15));

      developer.log(
        'addExpense: created doc id=${docRef.id} for user=${expense.userId}',
      );
      return docRef.id;
    } catch (e, st) {
      developer.log('addExpense failed: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Update existing expense by id
  Future<void> updateExpense(Expense expense) async {
    await _expensesRef().doc(expense.id).update(expense.toJson());
  }

  /// Delete expense by id
  Future<void> deleteExpense(String id) async {
    await _expensesRef().doc(id).delete();
  }

  /// One-time fetch of expenses for diagnostics or manual refresh
  Future<List<Expense>> fetchExpensesForUserOnce(String userId) async {
    // Avoid requiring a composite index by sorting client-side.
    final snapshot = await _expensesRef()
        .where('userId', isEqualTo: userId)
        .get();
    final list = snapshot.docs.map((d) => Expense.fromDocument(d)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Get a single expense by its document id. Returns null when not found.
  Future<Expense?> getExpenseById(String id) async {
    final doc = await _expensesRef().doc(id).get();
    if (!doc.exists) return null;
    return Expense.fromDocument(doc);
  }
}
