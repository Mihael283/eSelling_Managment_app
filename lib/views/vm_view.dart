import 'package:flutter/material.dart';
import 'package:rma_project/constants/routes.dart';

import '../enums/menu_action.dart';
import '../services/auth/auth_service.dart';

class VMView extends StatefulWidget {
  const VMView({Key? key}) : super(key: key);

  @override
  State<VMView> createState() => _VMViewState();
}

List<String> litems = ["1","2","Third","4"];

class _VMViewState extends State<VMView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
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
      body: ListView.builder
        (
          itemCount: 2,
          itemBuilder: (BuildContext context,int index){
            return ListTile(
                leading: Icon(Icons.list),
                trailing: Text("Online/Offline",
                  style: TextStyle(color: Colors.green,fontSize: 15),),
                title:Text("VM $index"),
                onTap: () => null
            );
          }
      )
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