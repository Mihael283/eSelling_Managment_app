import 'package:flutter/material.dart';
import 'package:rma_project/constants/database.dart';
import 'package:rma_project/constants/routes.dart';
import 'package:rma_project/services/crud/db_accounts.dart';
import 'package:rma_project/views/accounts/add_account_view.dart';

import '../../services/auth/auth_service.dart';
import '../../services/crud/db_services.dart';
import '../../utilities/delete_dialog.dart';

class VMView extends StatefulWidget {
  final int vm_Id;
  final String vm_name;
  const VMView({Key? key, this.vm_Id = 0, this.vm_name = ""}) : super(key: key);

  @override
  State<VMView> createState() => _VMViewState();
}

class _VMViewState extends State<VMView> {
  late final DBService _DBService;

  void initState(){
    _DBService = DBService();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.vm_name),actions: [
        IconButton(onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder: (context) => AddAccount(vm_Id: widget.vm_Id,), ));
        }, icon: const Icon(Icons.add))],),
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
                            itemBuilder: (BuildContext context, int index) {
                              final acc_name = filterAcc[index].ingamename;
                              final acc_status = filterAcc[index].isPlaying;
                              final acc_rank = filterAcc[index].rank;
                              var acc_state = "Offline";
                              final acc_id = filterAcc[index].id;
                              if(filterAcc[index].isPlaying){
                                acc_state = "Online";
                              }
                              return ListTile(
                                  leading: const Icon(Icons.account_circle),
                                  trailing: Wrap(
                                    spacing: 12,
                                    children: <Widget>[
                                      Text(
                                        acc_rank,
                                        style: TextStyle(fontSize: 15, height: 2.5),
                                      ),
                                      Text(
                                        acc_state,
                                        style: TextStyle(color: acc_status ? Colors.green : Colors.red, fontSize: 15, height: 2.5),
                                      ),
                                      IconButton(onPressed: () async {
                                        final shouldDelete = await showDeleteDialog(context);
                                        if(shouldDelete){
                                          _DBService.deleteAccount(id: acc_id );
                                        }
                                      }, icon: const Icon(Icons.delete))
                                    ],
                                  ),
                                  title: Text(acc_name));
                            },
                          );
                        }else{
                          return const Text("Please add an account!");
                        }
                      case ConnectionState.done:
                        return const Text("Done");
                      default:
                        return const CircularProgressIndicator();
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
}
