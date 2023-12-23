import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:we_chat/home/bloc/home_bloc_bloc.dart';
import 'package:we_chat/home/view/all_users_page.dart';
import 'package:we_chat/services/auth/bloc/auth_bloc_bloc.dart';
import 'firebase_options.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return BlocProvider<HomeBloc>(
                create: (context) => HomeBloc(),
                child: AllUserPage(),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(),
                  child: AuthPage(),
                ),
              ],
              child: AuthPage(),
            );
          },
        ));
  }
}

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
              child: BlocConsumer<AuthBloc, GoogleAuthState>(
        listener: (context, state) {},
        builder: (context, state) {
          return ElevatedButton(
              onPressed: state is GoogleAuthLoadingState
                  ? null
                  : () => context.read<AuthBloc>().add(AuthEventInitialize()),
              child: state is GoogleAuthLoadingState
                  ? const CircularProgressIndicator()
                  : Text('Google Signin'));
        },
      ))),
    );
  }
}
