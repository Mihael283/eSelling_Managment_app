import 'package:flutter/cupertino.dart';

import '../../constants/database.dart';


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
  String toString() => 'VmID = $vmId, Nickname = $ingamename, Rank = $rank, Playing = $isPlaying';

  @override
  bool operator == (covariant DatabaseAccounts other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

//18:23 boolean coop mozda fali

}
