import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart' show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;

import '../../constants/database.dart';
import 'db_accounts.dart';
import 'db_exceptions.dart';
import 'db_users.dart';
import 'db_vms.dart';

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

  Future<DatabaseVMs> getVM({required String name}) async{
    final db = _getDatabaseOrThrow();
    final results = await db.query(vmTable,limit: 1,where: 'name = ?',whereArgs: [name.toLowerCase()]);

    if(results.isEmpty){
      throw CouldNotFindVM();
    }
    else{
      return DatabaseVMs.fromRow(results.first);
    }
  }

  Future<void> deleteVM({required int id}) async{
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(vmTable,where: 'id = ?', whereArgs: [id],);
    if(deletedCount != 1){
      throw CouldNotDeleteVM();
    }
  }

  Future<DatabaseAccounts> addAccount({required DatabaseVMs vm, required String username, required String password, required String ingamename }) async{
    final db = _getDatabaseOrThrow();
    final dbVM = await getVM(name: vm.name);
    if(dbVM != vm){
      throw CouldNotDeleteVM();
    }

    final accountID = await db.insert(accountsTable,{vmNameColumn: vm.name, usernameColumn: username ,passwordColumn: password, ingamenameColumn: ingamename, isPlayingColumn: 0});
    final acc = DatabaseAccounts(id: accountID, vmName: vm.name, username: username, password: password, ingamename: ingamename, rank: "unknown", isPlaying: false);

    return acc;
  }

  Future<DatabaseAccounts> getAccount({required String ingamename}) async{
    final db = _getDatabaseOrThrow();
    final results = await db.query(accountsTable,limit: 1,where: 'ingamename = ?',whereArgs: [ingamename]);
    if(results.isEmpty){
      throw CouldNotFindAcc();
    }
    else{
      return DatabaseAccounts.fromRow(results.first);
    }
  }

  Future<void> deleteAccount({required int id}) async{
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(accountsTable,where: 'id = ?', whereArgs: [id],);
    if(deletedCount != 1){
      throw CouldNotDeleteAcc();
    }
  }


  Future<Iterable<DatabaseVMs>> getAllVMs() async{
    final db = _getDatabaseOrThrow();
    final vms = await db.query(vmTable);


    return vms.map((vmRow)=>DatabaseVMs.fromRow(vmRow));
  }

  Future<Iterable<DatabaseAccounts>> getAllAccs() async{
    final db = _getDatabaseOrThrow();
    final accs = await db.query(vmTable);


    return accs.map((accRow)=>DatabaseAccounts.fromRow(accRow));
  }

  Future<void> updateAccountRank({required String ingamename, required String rank}) async{
    final db = _getDatabaseOrThrow();
    await getAccount(ingamename: ingamename);
    final countUpdates = await db.update(accountsTable, {rankColumn: rank});
    if(countUpdates == 0){
      throw CouldNotUpdateAccRank();
    }
  }

}





