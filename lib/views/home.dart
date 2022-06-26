import 'package:flutter/material.dart';
import 'package:rma_project/constants/routes.dart';
import 'package:rma_project/services/crud/db_services.dart';
import 'package:rma_project/services/crud/db_vms.dart';

import '../enums/menu_action.dart';
import '../services/auth/auth_service.dart';
import '../services/crud/db_services.dart';

class VMView extends StatefulWidget {
  const VMView({Key? key}) : super(key: key);

  @override
  State<VMView> createState() => _VMViewState();
}

class _VMViewState extends State<VMView> {
  late final DBService _DBService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _DBService = DBService();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).pushNamed(newVMRoute);
          }, icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(onSelected: (value) async{
            switch(value){
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                if (shouldLogout) {
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false,);
                }
                break;
            }
          }, itemBuilder: (context) {
            return[
              const PopupMenuItem<MenuAction>(value: MenuAction.logout ,child: const Text("Sign out"),)
            ];
          },)
        ],
      ),
      body: FutureBuilder(
        future: _DBService.getOrCreateUser(email: userEmail),
        builder: (context,snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              return StreamBuilder(
                stream: _DBService.allVMS,
                builder: (context,snapshot) {
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if(snapshot.hasData){
                        final allVMS = snapshot.data as List<DatabaseVMs>;
                        print(allVMS[0]);
                        return ListView.builder(
                            itemCount: allVMS.length,
                            itemBuilder: (BuildContext context, int index) {
                              final vm_name = allVMS[index].name;
                              final vm_status = allVMS[index].isWorking;
                              var vm_state = "Offline";

                              if(allVMS[index].isWorking){
                                vm_state = "Online";
                              }
                              return ListTile(
                                  leading: const Icon(Icons.computer_rounded),
                                  trailing: Text(
                                    vm_state,

                                    style: TextStyle(color: vm_status ? Colors.green : Colors.red, fontSize: 15),
                                  ),
                                  title: Text("$vm_name"));
                            });
                      }else{
                        return const Text("Please add a VM");
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

Future<bool> showLogOutDialog(BuildContext context){
  return showDialog<bool>(
    context: context,
    builder: (context){
      return AlertDialog(
        title: const Text("Sign out"),
        content: const Text("Are you sure you want to sign out?"),
        actions:[
          TextButton(onPressed: () { Navigator.of(context).pop(false);}, child: const Text("Cancel")),
          TextButton(onPressed: () { Navigator.of(context).pop(true);}, child: const Text("Sign out")),
        ],

      );
    },
  ).then((value) => value ?? false);
}