import 'package:flutter/material.dart';
import 'package:rma_project/constants/routes.dart';
import 'package:rma_project/services/crud/db_services.dart';
import 'package:rma_project/services/crud/db_vms.dart';

import '../../enums/menu_action.dart';
import '../../services/auth/auth_service.dart';
import '../../services/crud/db_services.dart';
import '../../utilities/show_error_dialog.dart';

class NewVMView extends StatefulWidget {
  const NewVMView({Key? key}) : super(key: key);

  @override
  State<NewVMView> createState() => _NewVMViewState();
}

class _NewVMViewState extends State<NewVMView> {
  DatabaseVMs? _vm;
  late final DBService _DBService;
  late final TextEditingController _name;


  @override
  void initState(){
    _DBService = DBService();
    _name = TextEditingController();
    super.initState();
  }

  @override
  void dispose(){
    _name.dispose();
    super.dispose();
  }

  Future<DatabaseVMs> createNewVM({required String name}) async {
    final existingVM = _vm;
    if(existingVM != null){
      return existingVM;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _DBService.getUser(email: email);
    return await _DBService.createVM(owner: owner, name: name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add VM'),
      ),
      body:Column(
        children: [
          TextField( controller: _name, decoration: const InputDecoration(hintText: "Enter you VM name here:"),enableSuggestions: false, autocorrect: false, keyboardType: TextInputType.emailAddress,),
          TextButton(

          onPressed: () async {
            final name = _name.text;
            if(_name.text.isEmpty == false){
              createNewVM(name: name);
              Navigator.of(context).pop();
            }
            else{
              await showErrorDialog(context, "Please enter VM name");
            }

          },
          child: const Text('ADD VM'),
          ),

          ],
        )
    );
  }
}
