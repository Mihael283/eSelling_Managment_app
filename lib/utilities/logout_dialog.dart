import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../utilities/generic_dialog.dart';

Future<bool> showLogoutDialog(
    BuildContext context,
    ) {

  return showGenericDialog(context: context, title: 'Logout', content: "Are you sure you want to log out?", optionsBuilder:() =>{ 'Cancel' : false, 'Log out': true,} ).then((value) => value ?? false,);
}