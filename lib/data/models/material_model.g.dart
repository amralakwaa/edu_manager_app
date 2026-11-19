// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaterialModelAdapter extends TypeAdapter<MaterialModel> {
  @override
  final int typeId = 3;

  @override
  MaterialModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialModel(
      id: fields[0] as String,
      name: fields[1] as String,
      code: fields[2] as String,
      description: fields[3] as String?,
      teacherId: fields[4] as String,
      teacherName: fields[5] as String?,
      grade: fields[6] as String,
      semester: fields[7] as String,
      creditHours: fields[8] as int,
      totalMarks: fields[9] as double,
      passingMarks: fields[10] as double,
      days: (fields[11] as List).cast<String>(),
      startTime: fields[12] as String?,
      endTime: fields[13] as String?,
      status: fields[14] as String,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
      cacheExpiresAt: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.teacherId)
      ..writeByte(5)
      ..write(obj.teacherName)
      ..writeByte(6)
      ..write(obj.grade)
      ..writeByte(7)
      ..write(obj.semester)
      ..writeByte(8)
      ..write(obj.creditHours)
      ..writeByte(9)
      ..write(obj.totalMarks)
      ..writeByte(10)
      ..write(obj.passingMarks)
      ..writeByte(11)
      ..write(obj.days)
      ..writeByte(12)
      ..write(obj.startTime)
      ..writeByte(13)
      ..write(obj.endTime)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.cacheExpiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
