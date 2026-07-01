part of 'goal.dart';

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 0;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      createdAt: fields[4] as DateTime?,
      deadline: fields[5] as DateTime?,
      steps: (fields[6] as List?)?.cast<MicroStep>(),
      isCompleted: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.description)
      ..writeByte(3)..write(obj.category)
      ..writeByte(4)..write(obj.createdAt)
      ..writeByte(5)..write(obj.deadline)
      ..writeByte(6)..write(obj.steps)
      ..writeByte(7)..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class MicroStepAdapter extends TypeAdapter<MicroStep> {
  @override
  final int typeId = 1;

  @override
  MicroStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MicroStep(
      id: fields[0] as String?,
      title: fields[1] as String,
      isDone: fields[2] as bool,
      points: fields[3] as int,
      completedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MicroStep obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.isDone)
      ..writeByte(3)..write(obj.points)
      ..writeByte(4)..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MicroStepAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
