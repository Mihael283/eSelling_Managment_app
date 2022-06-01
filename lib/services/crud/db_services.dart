import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart' show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;

import '../../constants/database.dart';

class DatabaseAlreadyOpenException implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class CouldNotDeleteUser implements Exception {}

class UserAlreadyExits implements Exception {}
class CouldNotFindUser implements Exception {}

class DBService {
  Database? _db;

  Database _getDatabaseOrThrow(){
    final db = _db;
    if(db == null){
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if(_db != null){
      throw DatabaseAlreadyOpenException();
    }
    try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path,dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createVmsTable);
      await db.execute(createAccountsTable);

    } on MissingPlatformDirectoryException{
      throw MissingPlatformDirectoryException("Jbga");
    }
  }

  Future<void> close() async{
    final db = _db;
    if(db == null){
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> deleteUser({required String email}) async{
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(userTable,where: 'email = ?', whereArgs: [email.toLowerCase()],);
    if(deletedCount != 1){
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async{
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,limit: 1,where: 'email = ?',whereArgs: [email.toLowerCase()]);
    if(results.isNotEmpty){
      throw UserAlreadyExits();
    }

    final userId = await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async{
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,limit: 1,where: 'email = ?',whereArgs: [email.toLowerCase()]);

    if(results.isEmpty){
      throw CouldNotFindUser();
    }
    else{
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseVMs> createVM({required DatabaseUser owner, required String name}) async{
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if(dbUser != owner){
      throw CouldNotFindUser();
    }


    final VMId = await db.insert(vmTable,{userIdColumn: owner.id , nameColumn: name , isWorkingColumn: 0});
    final VM = DatabaseVMs(id: VMId, userId: owner.id, name: name, isWorking: false);

    return VM;
  }
}
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
  bool operator == (covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseAccounts{
  final int id;
  final int vmId;
  final String username;
  final String password;
  final String ingamename;
  final String rank;
  final bool isPlaying;

  const DatabaseAccounts({
    required this.id,
    required this.vmId,
    required this.username,
    required this.password,
    required this.ingamename,
    required this.rank,
    required this.isPlaying,
  });

  DatabaseAccounts.fromRow(Map<String, Object?> map): id = map[idColumn] as int, vmId = map[vmIdColumn] as int,
                                                      username = map[usernameColumn] as String,password = map[passwordColumn] as String,
                                                      ingamename = map[ingamenameColumn] as String,
                                                      rank = map[rankColumn] as String , isPlaying = (map[isPlayingColumn] as int) == 1 ? true : false;

  @override
  String toString() => 'VM = = $vmId, Nickname = $ingamename, Rank = $rank, Playing = $isPlaying';

  @override
  bool operator == (covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

//18:23 boolean coop mozda fali

}
