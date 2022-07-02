import 'package:flutter/material.dart';
import 'package:rma_project/constants/database.dart';
import 'package:rma_project/constants/routes.dart';
import 'package:rma_project/services/crud/db_accounts.dart';
import 'package:rma_project/views/accounts/add_account_view.dart';

import '../../services/auth/auth_service.dart';
import '../../services/crud/db_services.dart';
import '../../utilities/delete_dialog.dart';
import 'package:dart_lol/dart_lol.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VMView extends StatefulWidget {
  final int vm_Id;
  final String vm_name;
  const VMView({Key? key, this.vm_Id = 0, this.vm_name = ""}) : super(key: key);

  @override
  State<VMView> createState() => _VMViewState();
}

class _VMViewState extends State<VMView> {
  late final DBService _DBService;
  late final TextEditingController _text_input;

  void initState(){
    _DBService = DBService();
    _text_input = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.vm_name),actions: [
        IconButton(onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder: (context) => AddAccount(vm_Id: widget.vm_Id,), ));
        }, icon: const Icon(Icons.add)),
        IconButton(onPressed: () {
          Phoenix.rebirth(context);
        }, icon: const Icon(Icons.refresh)),
        IconButton(onPressed: () async {
         _displayTextInputDialog(context);
        }, icon: const Icon(Icons.key)),
      ],

      ),

      body: FutureBuilder(
        future: _DBService.getAccounts(vm_id: widget.vm_Id),
        builder: (context,snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              return StreamBuilder(
                  stream: _DBService.allAccs,
                  builder: (context,snapshot) {
                    switch(snapshot.connectionState){
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if(snapshot.hasData){
                          final allAcc = snapshot.data as List<DatabaseAccounts>;
                          final filterAcc = allAcc.where((acc) => acc.vmId == widget.vm_Id).toList();
                          return ListView.builder(
                            itemCount: filterAcc.length,
                            itemBuilder: (BuildContext context, int index){
                              final acc_name = filterAcc[index].ingamename;
                              final acc_status = filterAcc[index].isPlaying;
                              var acc_rank = filterAcc[index].rank;
                              var acc_state = "Offline";
                              final acc_id = filterAcc[index].id;

                              getAccountRank(ingamename: filterAcc[index].ingamename).then((rank) { acc_rank = rank;});
                              //getAccountState(ingamename: filterAcc[index].ingamename);
                              if(acc_rank == "no tier unranked"){
                                acc_rank = "UNRANKED";
                              }
                              if(filterAcc[index].isPlaying){
                                acc_state = "Online";
                              }
                              return ListTile(
                                  leading: const Icon(Icons.account_circle),
                                  trailing: Wrap(
                                    spacing: 12,
                                    children: <Widget>[
                                      Text(
                                        "Rank:  $acc_rank",
                                        style: TextStyle(fontSize: 15, height: 2.5),
                                      ),
                                      IconButton(onPressed: () async {
                                        final shouldDelete = await showDeleteDialog(context);
                                        if(shouldDelete){
                                          _DBService.deleteAccount(id: acc_id );
                                        }
                                      }, icon: const Icon(Icons.delete))
                                    ],
                                  ),
                                  onLongPress: (){
                                    Clipboard.setData(ClipboardData(text: "${filterAcc[index].username}--${filterAcc[index].password}"));
                                  },
                                  title: Text(acc_name));
                            },
                          );
                        }else{
                          return Center(
                            child:Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               CircularProgressIndicator(),
                               SizedBox(height: 16,),
                               Text("Please add account an account...")
                             ],
                            )
                          );
                        }
                      case ConnectionState.done:
                        return const Text("Done");
                      default:
                        return Center(
                            child:Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16,),
                                Text("Loading...")
                              ],
                            )
                        );
                    }
                  }
              );
            default:
              return const CircularProgressIndicator();

          }
        },
      ),
    );
  }

  Future<String> getAccountRank({required String ingamename}) async {
    final prefs = await SharedPreferences.getInstance();
    apiKey = prefs.getString('apiKey') ?? "Empty";
    final league = League(apiToken: apiKey, server: "EUW1");
    var rank = "";
    try{
      var player = await league.getSummonerInfo(summonerName: ingamename);
      var rankInfo = await league.getRankInfos(summonerID: player.summonerID);
      rank = rankInfo.tier! + " " + rankInfo.rank!;
      _DBService.updateAccountRank(ingamename: ingamename, rank: rank);
    }catch (e){

    }


    return rank;
  }
  //Unfortunately this function does not work since riot match api is down atm of writing this
  Future<void> getAccountState({required String ingamename}) async {
    final prefs = await SharedPreferences.getInstance();
    apiKey = prefs.getString('apiKey') ?? "Empty";
    final league = League(apiToken: apiKey, server: "EUW1");
    var player = await league.getSummonerInfo(summonerName: ingamename);
    print(player.summonerID);
    var inGame = await league.getCurrentGame(summonerID: player.summonerID, summonerName: player.summonerName);
    print(inGame?.gameDuration);

  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    print((prefs.getString('apiKey') ?? "Empty"));
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Please enter you Riot API Key'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  apiKey = value;
                });
              },
              controller: _text_input,
              decoration: InputDecoration(hintText: "ApiKey"),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  setState(() {
                    prefs.setString('apiKey', apiKey);
                    Navigator.of(context).pop();
                  });
                },
              )
            ],
          );
        });

  }
}
