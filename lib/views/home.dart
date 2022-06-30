import 'package:flutter/material.dart';
import 'package:rma_project/constants/routes.dart';
import 'package:rma_project/services/crud/db_services.dart';
import 'package:rma_project/services/crud/db_vms.dart';
import 'package:rma_project/utilities/logout_dialog.dart';
import 'package:rma_project/views/vms/vm_view.dart';

import '../enums/menu_action.dart';
import '../services/auth/auth_service.dart';
import '../services/crud/db_services.dart';
import '../utilities/delete_dialog.dart';

import 'package:open_mail_app/open_mail_app.dart';
import 'package:http/http.dart' as http;
import '../utilities/error_dialog.dart';

class CreateUpdateVMView extends StatefulWidget {
  const CreateUpdateVMView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateVMView> createState() => _CreateUpdateVMViewState();
}

class _CreateUpdateVMViewState extends State<CreateUpdateVMView> {
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
          IconButton(onPressed: () async{
            var result = await OpenMailApp.openMailApp();

            if (!result.didOpen && !result.canOpen) {
              showNoMailAppsDialog(context);
            }else if (!result.didOpen && result.canOpen) {
              showDialog(
                context: context,
                builder: (_) {
                  return MailAppPickerDialog(
                    mailApps: result.options,
                  );
                },
              );
            }
          }, icon: const Icon(Icons.email)),
          IconButton(onPressed: () {
            Navigator.of(context).pushNamed(createVMRoute);
          }, icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(onSelected: (value) async{
            switch(value){
              case MenuAction.logout:
                final shouldLogout = await showLogoutDialog(context);
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
                        return ListView.builder(
                            itemCount: allVMS.length,
                            itemBuilder: (BuildContext context, int index) {
                              final vm_name = allVMS[index].name;
                              final vm_status = allVMS[index].isWorking;
                              var vm_state = "Offline";
                              final vm_id = allVMS[index].id;
                              if(allVMS[index].isWorking){
                                vm_state = "Online";
                              }
                              return ListTile(
                                  leading: const Icon(Icons.computer_rounded),
                                  onTap: () {
                                    Navigator.push(context,MaterialPageRoute(builder: (context) => VMView(vm_Id: vm_id, vm_name: vm_name,), ));
                                  },
                                  trailing: Wrap(
                                    spacing: 12,
                                    children: <Widget>[
                                      Text(
                                        vm_state,
                                        style: TextStyle(color: vm_status ? Colors.green : Colors.red, fontSize: 15, height: 2.5),
                                      ),
                                      IconButton(onPressed: () async {
                                        final shouldDelete = await showDeleteDialog(context);
                                        if(shouldDelete){
                                          _DBService.deleteVM(id: vm_id);
                                        }
                                      }, icon: const Icon(Icons.delete))
                                    ],
                                  ),
                                  title: Text("$vm_name"));
                            },
                            );
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

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text("Open Mail App"),
            content: Text("No mail apps installed"),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
        );
      },
    );
  }

}
