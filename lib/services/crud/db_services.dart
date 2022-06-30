import 'dart:async';

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
  List<DatabaseVMs> _vms = [];
  List<DatabaseAccounts> _accs = [];

  static final DBService _shared = DBService._sharedInstance();
  DBService._sharedInstance() {
    _vmStreamController = StreamController<List<DatabaseVMs>>.broadcast(
      onListen: (){
        _vmStreamController.sink.add(_vms);
      }
    );
    _accStreamController = StreamController<List<DatabaseAccounts>>.broadcast(
      onListen: (){
        _accStreamController.sink.add(_accs);
      }
    );
  }
  factory DBService() => _shared;

  late final StreamController<List<DatabaseVMs>> _vmStreamController;
  late final StreamController<List<DatabaseAccounts>> _accStreamController;

  Stream<List<DatabaseVMs>> get allVMS => _vmStreamController.stream;
  Stream<List<DatabaseAccounts>> get allAccs => _accStreamController.stream;

  Future<void> cacheVms() async{
    final allVMs = await getAllVMs();
    _vms = allVMs.toList();
    _vmStreamController.add(_vms);
  }

  Future<void> cacheAccounts() async{
    final allAccs = await getAllAccs();
    _accs = allAccs.toList();
    _accStreamController.add(_accs);
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async{
    try{
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch(e){
      rethrow;
    }


  }

  Database _getDatabaseOrThrow(){
    final db = _db;
    if(db == null){
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> ensureDbIsOpen() async {
    try{
      await open();
    } on DatabaseAlreadyOpenException{
      //TODO
    }

  }

  Future<void> open() async {
    if(_db != null){
      throw DatabaseAlreadyOpenException();
    }
    try{
      final docsPath = await getDatabasesPath();
      final dbPath = join(docsPath,dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createUserTable);
      await db.execute(createVmsTable);
      await db.execute(createAccountsTable);

      await cacheVms();
      await cacheAccounts();

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
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(userTable,where: 'email = ?', whereArgs: [email.toLowerCase()],);
    if(deletedCount != 1){
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async{
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,limit: 1,where: 'email = ?',whereArgs: [email.toLowerCase()]);
    if(results.isNotEmpty){
      throw UserAlreadyExits();
    }

    final userId = await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async{
    await ensureDbIsOpen();
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
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if(dbUser != owner){
      throw CouldNotFindUser();
    }


    final VMId = await db.insert(vmTable,{userIdColumn: owner.id , nameColumn: name , isWorkingColumn: 0});
    final VM = DatabaseVMs(id: VMId, userId: owner.id, name: name, isWorking: false);

    _vms.add(VM);
    _vmStreamController.add(_vms);
    return VM;
  }

  Future<DatabaseVMs> getVM({required int id}) async{
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(vmTable,limit: 1,where: 'id = ?',whereArgs: [id]);

    if(results.isEmpty){
      throw CouldNotFindVM();
    }
    else{
      final vm = DatabaseVMs.fromRow(results.first);
      _vms.removeWhere((vm) => vm.id == id);
      _vms.add(vm);
      _vmStreamController.add(_vms);
      return vm;
    }
  }

  Future<void> deleteVM({required int id}) async{
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(vmTable,where: 'id = ?', whereArgs: [id],);
    if(deletedCount != 1){
      throw CouldNotDeleteVM();
    }else{
      _vms.removeWhere((vm) => vm.id == id);
      _vmStreamController.add(_vms);
    }

  }

  Future<DatabaseAccounts> addAccount({required int vm_id, required String username, required String password, required String ingamename }) async{
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final accountID = await db.insert(accountsTable,{vmIdColumn: vm_id, usernameColumn: username ,passwordColumn: password, ingamenameColumn: ingamename, rankColumn: "unknown", isPlayingColumn: 0});
    final acc = DatabaseAccounts(id: accountID, vmId: vm_id, username: username, password: password, ingamename: ingamename, rank: "unknown", isPlaying: false);

    _accs.add(acc);
    _accStreamController.add(_accs);
    return acc;
  }

  Future<DatabaseAccounts> getAccount({required String ingamename}) async{
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(accountsTable,limit: 1,where: 'ingamename = ?',whereArgs: [ingamename]);
    if(results.isEmpty){
      throw CouldNotFindAcc();
    }
    else{
      return DatabaseAccounts.fromRow(results.first);
    }
  }

  Future<Iterable<DatabaseAccounts>> getAccounts({required int vm_id}) async{
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(accountsTable,where: 'vm_id = ?',whereArgs: [vm_id]);
    if(results.isEmpty){
      throw CouldNotFindAcc();
    }
    else{

      return results.map((accRow)=>DatabaseAccounts.fromRow(accRow));
    }
  }

  Future<void> deleteAccount({required int id}) async{
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(accountsTable,where: 'id = ?', whereArgs: [id],);
    if(deletedCount != 1){
      throw CouldNotDeleteAcc();
    }
    else{
      _accs.removeWhere((acc) => acc.id == id);
      _accStreamController.add(_accs);
    }
  }


  Future<Iterable<DatabaseVMs>> getAllVMs() async{
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final vms = await db.query(vmTable);


    return vms.map((vmRow)=>DatabaseVMs.fromRow(vmRow));
  }

  Future<Iterable<DatabaseAccounts>> getAllAccs() async{
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final accs = await db.query(accountsTable);
    return accs.map((accRow)=>DatabaseAccounts.fromRow(accRow));
  }

  Future<void> updateAccountRank({required String ingamename, required String rank}) async{
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getAccount(ingamename: ingamename);
    final countUpdates = await db.update(accountsTable, {rankColumn: rank});
    if(countUpdates == 0){
      throw CouldNotUpdateAccRank();
    }
  }

}





