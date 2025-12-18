import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';

final expenseServiceProvider = Provider<ExpenseService>(
  (ref) => ExpenseService(),
);

final incomeServiceProvider = Provider<IncomeService>((ref) => IncomeService());

/// Stream of Firebase auth state (updates whenever user signs in/out)
final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

/// Stream provider that exposes a list of expenses for the current user.
/// This now depends on [authStateProvider] so it will re-evaluate when the
/// signed-in user changes and return the proper expenses stream.
final userExpensesProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      final service = ref.watch(expenseServiceProvider);
      return service.streamExpensesForUser(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (err, st) => Stream<List<Expense>>.error(err, st),
  );
});

/// Stream provider for income
final userIncomeProvider = StreamProvider.autoDispose<List<Income>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      final service = ref.watch(incomeServiceProvider);
      return service.streamIncomeForUser(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (err, st) => Stream<List<Income>>.error(err, st),
  );
});

/// Computed provider that calculates total expenses
final totalExpensesProvider = Provider<double>((ref) {
  final asyncList = ref.watch(userExpensesProvider);
  return asyncList.maybeWhen(
    data: (list) => list.fold(0.0, (s, e) => s + e.amount),
    orElse: () => 0.0,
  );
});

/// Computed provider that calculates total income
final totalIncomeProvider = Provider<double>((ref) {
  final asyncList = ref.watch(userIncomeProvider);
  return asyncList.maybeWhen(
    data: (list) => list.fold(0.0, (s, i) => s + i.amount),
    orElse: () => 0.0,
  );
});

/// Balance = Total Income - Total Expenses
final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expenses = ref.watch(totalExpensesProvider);
  return income - expenses;
});

/// Keep old totalProvider for backward compatibility
final totalProvider = Provider<double>((ref) {
  return ref.watch(totalExpensesProvider);
});
