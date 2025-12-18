import 'package:cloud_firestore/cloud_firestore.dart';

/// Expense model used for Firestore serialization.
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String userId;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.userId,
  });

  /// Create an Expense from Firestore document snapshot
  factory Expense.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Expense(
      id: doc.id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] as String? ?? 'Other',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] as String? ?? '',
    );
  }

  /// Convert to JSON map for Firestore
  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'category': category,
    'date': Timestamp.fromDate(date),
    'userId': userId,
  };
}
