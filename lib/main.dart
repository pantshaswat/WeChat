import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:page_transition/page_transition.dart';
import 'package:we_chat/services/auth/bloc/auth_bloc_bloc.dart';
import 'package:we_chat/view_model/home/view/auth_page.dart';
import 'package:we_chat/view_model/home/bloc/home_bloc_bloc.dart';
import 'package:we_chat/view_model/home/view/all_users_page.dart';
import 'package:we_chat/view_model/home/view/splash_screen.dart';
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
        home: AnimatedSplashScreen(
          backgroundColor: Colors.blueGrey,
          splashTransition: SplashTransition.rotationTransition,
          pageTransitionType: PageTransitionType.fade,
          splash: SplashScreen(),
          nextScreen: AuthOrHomePage(),
          duration: 500,
          animationDuration: Durations.extralong4,
        ));
  }
}

class AuthOrHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
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
      ),
    );
  }
}
