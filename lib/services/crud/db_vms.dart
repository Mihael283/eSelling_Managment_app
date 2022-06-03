import 'package:flutter/cupertino.dart';
import '../../constants/database.dart';

@immutable
class DatabaseVMs{
  final int id;
  final int userId;
  final String name;
  final bool isWorking;

  const DatabaseVMs({
    required this.id,
    required this.userId,
    required this.name,
    required this.isWorking,
  });

  DatabaseVMs.fromRow(Map<String, Object?> map): id = map[idColumn] as int, userId = map[userIdColumn] as int,name = map[nameColumn] as String, isWorking = (map[isWorkingColumn] as int) == 1 ? true : false;

  @override
  String toString() => 'VM, ID = $id, Name = $name, Working = $isWorking';

  //18:23 boolean coop mozda fali
  @override
  bool operator == (covariant DatabaseVMs other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}