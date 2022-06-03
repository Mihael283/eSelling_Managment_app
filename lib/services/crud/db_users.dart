import 'package:flutter/cupertino.dart';

import '../../constants/database.dart';

@immutable
class DatabaseUser{
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map): id = map[idColumn] as int, email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, Email = $email';

  @override
  bool operator == (covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;


}