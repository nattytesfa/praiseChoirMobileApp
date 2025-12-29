// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentReportModelAdapter extends TypeAdapter<PaymentReportModel> {
  @override
  final int typeId = 15;

  @override
  PaymentReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentReportModel(
      id: fields[0] as String,
      month: fields[1] as DateTime,
      totalMembers: fields[2] as int,
      paidCount: fields[3] as int,
      pendingCount: fields[4] as int,
      overdueCount: fields[5] as int,
      collectionRate: fields[6] as double,
      totalAmount: fields[7] as double,
      generatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentReportModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.month)
      ..writeByte(2)
      ..write(obj.totalMembers)
      ..writeByte(3)
      ..write(obj.paidCount)
      ..writeByte(4)
      ..write(obj.pendingCount)
      ..writeByte(5)
      ..write(obj.overdueCount)
      ..writeByte(6)
      ..write(obj.collectionRate)
      ..writeByte(7)
      ..write(obj.totalAmount)
      ..writeByte(8)
      ..write(obj.generatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
