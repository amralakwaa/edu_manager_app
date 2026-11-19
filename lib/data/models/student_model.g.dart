// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudentModelAdapter extends TypeAdapter<StudentModel> {
  @override
  final int typeId = 1;

  @override
  StudentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudentModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      email: fields[3] as String,
      studentNumber: fields[4] as String,
      grade: fields[5] as String,
      section: fields[6] as String,
      dateOfBirth: fields[7] as DateTime?,
      gender: fields[8] as String?,
      phone: fields[9] as String?,
      guardianName: fields[10] as String?,
      guardianPhone: fields[11] as String?,
      address: fields[12] as String?,
      avatarUrl: fields[13] as String?,
      gpa: fields[14] as double,
      status: fields[15] as String,
      enrolledMaterials: (fields[16] as List).cast<String>(),
      enrollmentDate: fields[17] as DateTime,
      updatedAt: fields[18] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StudentModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.studentNumber)
      ..writeByte(5)
      ..write(obj.grade)
      ..writeByte(6)
      ..write(obj.section)
      ..writeByte(7)
      ..write(obj.dateOfBirth)
      ..writeByte(8)
      ..write(obj.gender)
      ..writeByte(9)
      ..write(obj.phone)
      ..writeByte(10)
      ..write(obj.guardianName)
      ..writeByte(11)
      ..write(obj.guardianPhone)
      ..writeByte(12)
      ..write(obj.address)
      ..writeByte(13)
      ..write(obj.avatarUrl)
      ..writeByte(14)
      ..write(obj.gpa)
      ..writeByte(15)
      ..write(obj.status)
      ..writeByte(16)
      ..write(obj.enrolledMaterials)
      ..writeByte(17)
      ..write(obj.enrollmentDate)
      ..writeByte(18)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
