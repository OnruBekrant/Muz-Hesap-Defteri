import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  alacak, // Muz Verdik / Komisyoncu Borçlandı (Credit/Sale)

  @HiveField(1)
  alindi, // Biz Para Aldık (Payment/Collection)
}

@HiveType(typeId: 2)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String seasonId;

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final String description;

  // Fields for 'alacak' (Sale)
  @HiveField(6)
  final double? weight;

  @HiveField(7)
  final int? unitCount;

  @HiveField(8)
  final double? unitPrice;

  // Fields for 'alindi' (Payment)
  @HiveField(9)
  final String? relatedTransactionId;

  @HiveField(10)
  final DateTime? dueDate;

  Transaction({
    required this.id,
    required this.seasonId,
    required this.type,
    required this.date,
    required this.amount,
    required this.description,
    this.weight,
    this.unitCount,
    this.unitPrice,
    this.relatedTransactionId,
    this.dueDate,
  });
}
