import 'package:flutter/material.dart';
import 'package:rma_project/constants/routes.dart';
import 'package:rma_project/services/crud/db_accounts.dart';
import 'package:rma_project/services/crud/db_services.dart';
import 'package:rma_project/services/crud/db_vms.dart';

import '../../enums/menu_action.dart';
import '../../services/auth/auth_service.dart';
import '../../services/crud/db_services.dart';
import '../../utilities/error_dialog.dart';

class AddAccount extends StatefulWidget {
  final int vm_Id;
  const AddAccount({Key? key, this.vm_Id = 0}) : super(key: key);

  @override
  State<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  DatabaseAccounts? _account;
  late final DBService _DBService;
  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _ingamename;


  @override
  void initState(){
    _DBService = DBService();
    _username = TextEditingController();
    _password = TextEditingController();
    _ingamename = TextEditingController();
    super.initState();
  }

  @override
  void dispose(){
    _username.dispose();
    _password.dispose();
    _ingamename.dispose();
    super.dispose();
  }

  Future<DatabaseAccounts> addNewAcc({required int vmId, required String username, required String password, required String ingamename}) async {
    final existingAcc = _account;
    if(existingAcc != null){
      return existingAcc;
    }
    return await _DBService.addAccount(vm_id: widget.vm_Id, username: username, password: password, ingamename: ingamename);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Add VM'),
        ),
        body:Column(
          children: [
            TextField( controller: _username, decoration: const InputDecoration(hintText: "Enter your acc username here:"),enableSuggestions: false, autocorrect: false, keyboardType: TextInputType.emailAddress,),
            TextField( controller: _password, decoration: const InputDecoration(hintText: "Enter your acc password here:"),enableSuggestions: false, autocorrect: false, keyboardType: TextInputType.emailAddress,),
            TextField( controller: _ingamename, decoration: const InputDecoration(hintText: "Enter your acc ingamename here:"),enableSuggestions: false, autocorrect: false, keyboardType: TextInputType.emailAddress,),
            TextButton(

              onPressed: () async {
                final username = _username.text;
                final password = _password.text;
                final ingamename = _ingamename.text;
                if(_username.text.isEmpty == false && _password.text.isEmpty == false && _ingamename.text.isEmpty == false){
                  addNewAcc(vmId: widget.vm_Id, username: username, password: password, ingamename: ingamename);
                  Navigator.of(context).pop();
                }
                else{
                  await showErrorDialog(context, "Please fill every field!");
                }

              },
              child: const Text('ADD ACC'),
            ),

          ],
        )
    );
  }
}
