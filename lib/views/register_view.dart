import 'package:flutter/material.dart';
import 'package:rma_project/constants/routes.dart';
import 'package:rma_project/firebase_options.dart';

import '../services/auth/auth_exceptions.dart';
import '../services/auth/auth_service.dart';
import '../utilities/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

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
      appBar: AppBar(title: const Text('Register'),

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
                          final userCredential = await AuthService.firebase().createUser(email: email, password: password);
                          Navigator.of(context).pushNamed(verifyEmailRoute);
                          final user = AuthService.firebase().currentUser;
                          AuthService.firebase().sendEmailVerification();
                        } on WeakPasswordAuthException {
                            await showErrorDialog(context, "Weak password!");
                        } on EmailAlreadyInUseAuthException{
                            await showErrorDialog(context, "Email is already in use!");
                        } on InvalidEmailAuthException{
                            await showErrorDialog(context, "Invalid email address!");
                        } on GenericAuthException{
                            await showErrorDialog(context, "AuthenticationError!");
                        }catch (e){
                            await showErrorDialog(context, e.toString());
                        }
                      },
                      child: const Text('Register')
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                      },
                      child: const Text('Sign in')
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