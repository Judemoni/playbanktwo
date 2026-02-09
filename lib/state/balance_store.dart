import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class BalanceStore {
  static const double _defaultChecking = 0;
  static const double _defaultSavings = 0;
  static const int _maxTransactions = 50;

  static final checking = ValueNotifier<double>(_defaultChecking);
  static final savings = ValueNotifier<double>(_defaultSavings);
  static final transactions = ValueNotifier<List<TransactionEntry>>([]);
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _balanceSub;

  static double get totalBanking => checking.value + savings.value;

  static void resetLocal() {
    checking.value = _defaultChecking;
    savings.value = _defaultSavings;
    transactions.value = const [];
  }

  static Future<void> bindToCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _balanceSub?.cancel();
    _balanceSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) {
        resetLocal();
        return;
      }
      final data = doc.data();
      if (data == null) {
        resetLocal();
        return;
      }
      final balances = data['balances'];
      if (balances is Map) {
        final checkingValue = balances['checking'];
        final savingsValue = balances['savings'];
        checking.value = _parseAmount(checkingValue) ?? _defaultChecking;
        savings.value = _parseAmount(savingsValue) ?? _defaultSavings;
      }
      final checkingValue = data['checking'];
      final savingsValue = data['savings'];
      if (balances is! Map) {
        checking.value = _parseAmount(checkingValue) ?? _defaultChecking;
        savings.value = _parseAmount(savingsValue) ?? _defaultSavings;
      }

      final rawTransactions = data['transactions'] ?? data['activity'];
      if (rawTransactions is List) {
        final parsed = rawTransactions
            .map((entry) => TransactionEntry.fromMap(entry))
            .whereType<TransactionEntry>()
            .toList();
        parsed.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        transactions.value = parsed.take(_maxTransactions).toList();
      }
    });
  }

  static Future<void> stopListening() async {
    await _balanceSub?.cancel();
    _balanceSub = null;
  }

  static Future<void> updateRemoteBalances() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {
        'balances': {
          'checking': checking.value,
          'savings': savings.value,
        },
      },
      SetOptions(merge: true),
    );
  }

  static void send({
    required String accountKey,
    required double amount,
  }) {
    if (amount <= 0) return;
    if (accountKey == 'CHECKING') {
      checking.value = (checking.value - amount).clamp(0, double.infinity);
      updateRemoteBalances();
      return;
    }
    if (accountKey == 'SAVINGS') {
      savings.value = (savings.value - amount).clamp(0, double.infinity);
      updateRemoteBalances();
    }
  }

  static Future<void> recordTransaction({
    required String title,
    required double amount,
    required String accountKey,
    required String type,
  }) async {
    if (amount == 0) return;
    final entry = TransactionEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      timestamp: DateTime.now(),
      type: type,
      accountKey: accountKey,
    );
    final updated = [entry, ...transactions.value];
    transactions.value = updated.take(_maxTransactions).toList();
    await _updateRemoteTransactions();
  }

  static Future<void> _updateRemoteTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final data = transactions.value
        .take(_maxTransactions)
        .map((entry) => entry.toMap())
        .toList();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {
        'transactions': data,
      },
      SetOptions(merge: true),
    );
  }

  static double? _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class TransactionEntry {
  final String id;
  final String title;
  final double amount;
  final DateTime timestamp;
  final String type;
  final String accountKey;

  const TransactionEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.timestamp,
    required this.type,
    required this.accountKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'accountKey': accountKey,
    };
  }

  static TransactionEntry? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final title = raw['title'];
    final amount = raw['amount'];
    final timestamp = raw['timestamp'];
    final type = raw['type'];
    final accountKey = raw['accountKey'];
    if (title is! String || type is! String || accountKey is! String) {
      return null;
    }
    final parsedAmount = _parseAmount(amount);
    if (parsedAmount == null) return null;
    final parsedTime = _parseTimestamp(timestamp);
    if (parsedTime == null) return null;
    final idValue = raw['id'];
    final id =
        idValue is String ? idValue : parsedTime.millisecondsSinceEpoch.toString();
    return TransactionEntry(
      id: id,
      title: title,
      amount: parsedAmount,
      timestamp: parsedTime,
      type: type,
      accountKey: accountKey,
    );
  }

  static double? _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
