// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TeacherModelAdapter extends TypeAdapter<TeacherModel> {
  @override
  final int typeId = 2;

  @override
  TeacherModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TeacherModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      email: fields[3] as String,
      employeeNumber: fields[4] as String,
      specialization: fields[5] as String,
      qualification: fields[6] as String,
      experienceYears: fields[7] as int,
      phone: fields[8] as String?,
      address: fields[9] as String?,
      avatarUrl: fields[10] as String?,
      teachingMaterials: (fields[11] as List).cast<String>(),
      assignedGrades: (fields[12] as List).cast<String>(),
      status: fields[13] as String,
      hireDate: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TeacherModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.employeeNumber)
      ..writeByte(5)
      ..write(obj.specialization)
      ..writeByte(6)
      ..write(obj.qualification)
      ..writeByte(7)
      ..write(obj.experienceYears)
      ..writeByte(8)
      ..write(obj.phone)
      ..writeByte(9)
      ..write(obj.address)
      ..writeByte(10)
      ..write(obj.avatarUrl)
      ..writeByte(11)
      ..write(obj.teachingMaterials)
      ..writeByte(12)
      ..write(obj.assignedGrades)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.hireDate)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
