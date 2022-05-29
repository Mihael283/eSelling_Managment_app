import 'package:flutter/material.dart';
import 'package:rma_project/constants/routes.dart';

import '../services/auth/auth_service.dart';


class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email'),

      ),
      body: Center(
        child: Column(children: [
          const Text("Verification email sent."),
          const Text("If you haven't received a verification email yet, press the button below."),
          TextButton(onPressed: () async{
            final user = AuthService.firebase().currentUser;
            AuthService.firebase().sendEmailVerification();
          }, child: const Text('Send email verification'),),
          TextButton(onPressed: () async{
            await AuthService.firebase().logOut();
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
          }, child: const Text('Back'),)
        ]
          ,),
      ),
    );
  }
}
