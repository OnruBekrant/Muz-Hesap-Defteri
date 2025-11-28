// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 2;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      seasonId: fields[1] as String,
      type: fields[2] as TransactionType,
      date: fields[3] as DateTime,
      amount: fields[4] as double,
      description: fields[5] as String,
      weight: fields[6] as double?,
      unitCount: fields[7] as int?,
      unitPrice: fields[8] as double?,
      relatedTransactionId: fields[9] as String?,
      dueDate: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.seasonId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.unitCount)
      ..writeByte(8)
      ..write(obj.unitPrice)
      ..writeByte(9)
      ..write(obj.relatedTransactionId)
      ..writeByte(10)
      ..write(obj.dueDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 1;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.alacak;
      case 1:
        return TransactionType.alindi;
      default:
        return TransactionType.alacak;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.alacak:
        writer.writeByte(0);
        break;
      case TransactionType.alindi:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
