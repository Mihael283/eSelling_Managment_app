import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rma_project/firebase_options.dart';
import 'package:rma_project/main.dart';

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
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
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
                          final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
                        } on FirebaseAuthException catch(e) {
                          if (e.code == 'user-not-found'){
                            print('User not found');
                          }
                          else if (e.code == 'wrong-password'){
                            print("Wrong password");
                          }
                        }

                      },
                      child: const Text('Login')
                  ),

                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('/register/', (route) => false);
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