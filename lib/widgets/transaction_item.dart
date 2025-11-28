import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../constants/colors.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');

    final isAlacak = transaction.type == TransactionType.alacak;
    final color = isAlacak ? AppColors.koyuYesil : Colors.red;
    final icon = isAlacak ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(transaction.date),
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (isAlacak && transaction.dueDate != null) ...[
              const SizedBox(height: 4),
              Builder(
                builder: (context) {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final due = DateTime(transaction.dueDate!.year, transaction.dueDate!.month, transaction.dueDate!.day);
                  final days = due.difference(today).inDays;

                  String text;
                  Color textColor;

                  if (days > 0) {
                    text = 'Ödemeye $days gün var';
                    textColor = Colors.green;
                  } else if (days == 0) {
                    text = 'Ödeme Günü BUGÜN!';
                    textColor = Colors.orange;
                  } else {
                    text = 'Vadesi ${days.abs()} gün geçti';
                    textColor = Colors.red;
                  }

                  return Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
        trailing: Text(
          currencyFormat.format(transaction.amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
