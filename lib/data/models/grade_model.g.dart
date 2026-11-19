// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GradeModelAdapter extends TypeAdapter<GradeModel> {
  @override
  final int typeId = 6;

  @override
  GradeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GradeModel(
      id: fields[0] as String,
      studentId: fields[1] as String,
      studentName: fields[2] as String?,
      materialId: fields[3] as String,
      materialName: fields[4] as String?,
      teacherId: fields[5] as String,
      gradeType: fields[6] as String,
      title: fields[7] as String,
      score: fields[8] as double,
      totalMarks: fields[9] as double,
      percentage: fields[10] as double?,
      notes: fields[11] as String?,
      gradedAt: fields[12] as DateTime,
      semester: fields[13] as String,
      academicYear: fields[14] as String,
      updatedAt: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GradeModel obj) {
    writer
      ..writeByte(16)
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
      ..write(obj.gradeType)
      ..writeByte(7)
      ..write(obj.title)
      ..writeByte(8)
      ..write(obj.score)
      ..writeByte(9)
      ..write(obj.totalMarks)
      ..writeByte(10)
      ..write(obj.percentage)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.gradedAt)
      ..writeByte(13)
      ..write(obj.semester)
      ..writeByte(14)
      ..write(obj.academicYear)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
