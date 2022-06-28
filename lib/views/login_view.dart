import 'package:flutter/material.dart';
import 'package:rma_project/constants/routes.dart';
import 'package:rma_project/firebase_options.dart';
import 'package:rma_project/services/auth/auth_service.dart';

import '../services/auth/auth_exceptions.dart';
import '../utilities/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState(){
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose(){
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),

      ),
      body: FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context,snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.done:
              return Column(
                children: [
                  TextField( controller: _email, decoration: const InputDecoration(hintText: "Enter you email here:"),enableSuggestions: false, autocorrect: false, keyboardType: TextInputType.emailAddress,),
                  TextField( controller: _password, decoration: const InputDecoration(hintText: "Enter you password here:"), obscureText: true, enableSuggestions: false, autocorrect: false,),
                  TextButton(

                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        try {
                          final userCredential = await AuthService.firebase().logIn(email: email, password: password);
                          final user = AuthService.firebase().currentUser;
                          if(user?.isEmailVerified ?? false){
                            Navigator.of(context).pushNamedAndRemoveUntil(VM_ScreenRoute, (route) => false);
                          }else {
                            Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
                          }
                        } on  UserNotFoundAuthException{
                          await showErrorDialog(context, "User not found!");
                        } on WrongPasswordAuthException{
                          await showErrorDialog(context, "Wrong password!");
                        } on GenericAuthException{
                          await showErrorDialog(context, "AuthenticationError!");
                        }catch (e){
                          await showErrorDialog(context, e.toString());
                        }
                      },
                      child: const Text('Login')
                  ),

                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
                      },
                      child: const Text('Sign up')
                  ),
                ],
              );
            default:
              return const Text("Loading...");
          }

        },
      ),
    );
  }
}
