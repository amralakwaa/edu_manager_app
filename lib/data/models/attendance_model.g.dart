// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceModelAdapter extends TypeAdapter<AttendanceModel> {
  @override
  final int typeId = 7;

  @override
  AttendanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceModel(
      id: fields[0] as String,
      studentId: fields[1] as String,
      studentName: fields[2] as String?,
      materialId: fields[3] as String,
      materialName: fields[4] as String?,
      teacherId: fields[5] as String,
      date: fields[6] as DateTime,
      status: fields[7] as String,
      notes: fields[8] as String?,
      checkInTime: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.studentName)
      ..writeByte(3)
      ..write(obj.materialId)
      ..writeByte(4)
      ..write(obj.materialName)
      ..writeByte(5)
      ..write(obj.teacherId)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.checkInTime)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
