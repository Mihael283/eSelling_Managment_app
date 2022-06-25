import 'package:flutter/material.dart';
import 'package:rma_project/constants/routes.dart';
import 'package:rma_project/services/crud/db_services.dart';

import '../../enums/menu_action.dart';
import '../../services/auth/auth_service.dart';
import '../../services/crud/db_services.dart';

class NewVMView extends StatefulWidget {
  const NewVMView({Key? key}) : super(key: key);

  @override
  State<NewVMView> createState() => _NewVMViewState();
}

class _NewVMViewState extends State<NewVMView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add VM'),
      ),
      body:const Text("Fill up VM Info")
    );
  }
}
