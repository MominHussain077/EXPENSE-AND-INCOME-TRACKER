import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/income.dart';

/// Service that performs CRUD operations against Firestore for income.
class IncomeService {
  final FirebaseFirestore _firestore;

  IncomeService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _incomeRef() =>
      _firestore.collection('income');

  /// Stream of income for a given user (ordered by date desc)
  Stream<List<Income>> streamIncomeForUser(String userId) {
    return _incomeRef().where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs.map((d) => Income.fromDocument(d)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  /// Add a new income and return the generated document id
  Future<String> addIncome(Income income) async {
    try {
      final docRef = _incomeRef().doc();
      await docRef.set(income.toJson()).timeout(const Duration(seconds: 15));
      developer.log(
        'addIncome: created doc id=${docRef.id} for user=${income.userId}',
      );
      return docRef.id;
    } catch (e, st) {
      developer.log('addIncome failed: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Update existing income by id
  Future<void> updateIncome(Income income) async {
    await _incomeRef().doc(income.id).update(income.toJson());
  }

  /// Delete income by id
  Future<void> deleteIncome(String id) async {
    await _incomeRef().doc(id).delete();
  }
}
