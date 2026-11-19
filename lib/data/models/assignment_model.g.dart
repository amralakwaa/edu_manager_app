// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssignmentModelAdapter extends TypeAdapter<AssignmentModel> {
  @override
  final int typeId = 4;

  @override
  AssignmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssignmentModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      materialId: fields[3] as String,
      materialName: fields[4] as String?,
      teacherId: fields[5] as String,
      teacherName: fields[6] as String?,
      grade: fields[7] as String,
      startDate: fields[8] as DateTime,
      dueDate: fields[9] as DateTime,
      totalMarks: fields[10] as double,
      status: fields[11] as String,
      attachments: (fields[12] as List).cast<String>(),
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      cacheExpiresAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AssignmentModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.materialId)
      ..writeByte(4)
      ..write(obj.materialName)
      ..writeByte(5)
      ..write(obj.teacherId)
      ..writeByte(6)
      ..write(obj.teacherName)
      ..writeByte(7)
      ..write(obj.grade)
      ..writeByte(8)
      ..write(obj.startDate)
      ..writeByte(9)
      ..write(obj.dueDate)
      ..writeByte(10)
      ..write(obj.totalMarks)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.attachments)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.cacheExpiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AssignmentSubmissionModelAdapter
    extends TypeAdapter<AssignmentSubmissionModel> {
  @override
  final int typeId = 5;

  @override
  AssignmentSubmissionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssignmentSubmissionModel(
      id: fields[0] as String,
      assignmentId: fields[1] as String,
      studentId: fields[2] as String,
      studentName: fields[3] as String?,
      content: fields[4] as String,
      attachments: (fields[5] as List).cast<String>(),
      submittedAt: fields[6] as DateTime,
      score: fields[7] as double?,
      feedback: fields[8] as String?,
      status: fields[9] as String,
      gradedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AssignmentSubmissionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.assignmentId)
      ..writeByte(2)
      ..write(obj.studentId)
      ..writeByte(3)
      ..write(obj.studentName)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.attachments)
      ..writeByte(6)
      ..write(obj.submittedAt)
      ..writeByte(7)
      ..write(obj.score)
      ..writeByte(8)
      ..write(obj.feedback)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.gradedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentSubmissionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
