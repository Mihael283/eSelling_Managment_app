import 'package:flutter/material.dart';
import 'package:rma_project/constants/routes.dart';
import 'package:rma_project/services/auth/auth_service.dart';
import 'package:rma_project/views/accounts/add_account_view.dart';
import 'package:rma_project/views/login_view.dart';
import 'package:rma_project/views/register_view.dart';
import 'package:rma_project/views/verify_email_view.dart';
import 'package:rma_project/views/vms/create_vm_view.dart';
import 'package:rma_project/views/home.dart';
import 'package:rma_project/views/vms/vm_view.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    Phoenix(child:
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        VM_ScreenRoute: (context) => const HomeView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createVMRoute: (context) => const NewVMView(),
        viewVMRoute: (context) => const VMView(),
        addAccRoute: (context) => const AddAccount(),

      },
    ),
  ));
}


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context,snapshot){
        switch (snapshot.connectionState){
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if(user != null){
              if(user.isEmailVerified){
                return const HomeView();
              }
              else{
                return const VerifyEmailView();
              }
            }else{
              return const LoginView();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
