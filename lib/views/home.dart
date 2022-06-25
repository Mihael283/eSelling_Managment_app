import 'package:flutter/material.dart';
import 'package:rma_project/constants/routes.dart';
import 'package:rma_project/services/crud/db_services.dart';

import '../enums/menu_action.dart';
import '../services/auth/auth_service.dart';
import '../services/crud/db_services.dart';

class VMView extends StatefulWidget {
  const VMView({Key? key}) : super(key: key);

  @override
  State<VMView> createState() => _VMViewState();
}

List<String> litems = ["1","2","Third","4"];

class _VMViewState extends State<VMView> {
  late final DBService _DBService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _DBService = DBService();
    super.initState();
  }
  @override
  void dispose() {
    _DBService.close();
    super.dispose();
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

            case ConnectionState.none:
              return const Text("AAA");
            case ConnectionState.waiting:
              return const Text("AAAA");
            case ConnectionState.active:
              return const Text("AAAAA");
            case ConnectionState.done:
              return StreamBuilder(
                stream: _DBService.allVMS,
                builder: (context,snapshot) {
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                      return const Text("AAA");
                    case ConnectionState.waiting:
                      return const Text("Please add VM by pressing add button...");
                    case ConnectionState.active:
                      return const Text("AAAAA");
                    case ConnectionState.done:
                      return const Text("Done");
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