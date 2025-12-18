import 'package:cloud_firestore/cloud_firestore.dart';

/// Income model used for Firestore serialization.
class Income {
  final String id;
  final String source;
  final double amount;
  final DateTime date;
  final String userId;

  Income({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    required this.userId,
  });

  /// Create an Income from Firestore document snapshot
  factory Income.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Income(
      id: doc.id,
      source: data['source'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] as String? ?? '',
    );
  }

  /// Convert to JSON map for Firestore
  Map<String, dynamic> toJson() => {
    'source': source,
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'userId': userId,
  };
}
