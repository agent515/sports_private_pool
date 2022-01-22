// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonAdapter extends TypeAdapter<Person> {
  @override
  final int typeId = 0;

  @override
  Person read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Person(
      email: fields[0] as String?,
      firstName: fields[1] as String?,
      lastName: fields[2] as String?,
      username: fields[4] as String?,
      purse: fields[3] as double?,
      contestsCreated: (fields[5] as List?)?.cast<dynamic>(),
      contestsJoined: (fields[6] as List?)?.cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.purse)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.contestsCreated)
      ..writeByte(6)
      ..write(obj.contestsJoined);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
