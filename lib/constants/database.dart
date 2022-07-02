const dbName = 'eselling_db';
const userTable = 'user';
const vmTable = 'vms';
const accountsTable = 'accounts';


const idColumn = 'id';
const userIdColumn = 'user_id';
const nameColumn = 'name';
const isWorkingColumn = 'isWorking';
const emailColumn = 'email';
const usernameColumn = 'username';
const passwordColumn = 'password';
const rankColumn = 'rank';
const isPlayingColumn = 'isPlaying';
const vmIdColumn = 'vm_id';
const ingamenameColumn = 'ingamename';


var apiKey = "";

const createAccountsTable = '''
        CREATE TABLE IF NOT EXISTS "accounts" (
        "id"	INTEGER,
        "vm_id"	INTEGER NOT NULL,
        "username"	TEXT,
        "password"	TEXT,
        "ingamename"	TEXT,
        "rank"	TEXT,
        "isPlaying"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';


const createVmsTable = '''
        CREATE TABLE IF NOT EXISTS "vms" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "name"	TEXT,
        "isWorking"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';