import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../constants/colors.dart';

class BalanceCard extends StatelessWidget {
  final List<Transaction> transactions;

  const BalanceCard({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    double totalAlacak = 0;
    double totalAlindi = 0;

    for (var t in transactions) {
      if (t.type == TransactionType.alacak) {
        totalAlacak += t.amount;
      } else if (t.type == TransactionType.alindi) {
        totalAlindi += t.amount;
      }
    }

    final balance = totalAlacak - totalAlindi;
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: AppColors.yaprakYesili,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'GÜNCEL BAKİYE',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              currencyFormat.format(balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              balance >= 0 ? 'Alacaklısınız' : 'Borçlusunuz',
              style: TextStyle(
                color: balance >= 0 ? Colors.white : Colors.redAccent.shade100,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
