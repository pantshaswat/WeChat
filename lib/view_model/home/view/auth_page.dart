import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:we_chat/services/auth/bloc/auth_bloc_bloc.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SafeArea(
          child: Center(
              child: BlocConsumer<AuthBloc, GoogleAuthState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Column(
            children: [
              Container(
                  height: 250,
                  width: 250,
                  child: Image.asset('assets/photos/bubble-chat.png')),
              const SizedBox(height: 20),
              Text(
                'WeChat',
                style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Stay Connected!',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                  onPressed: state is GoogleAuthLoadingState
                      ? null
                      : () =>
                          context.read<AuthBloc>().add(AuthEventInitialize()),
                  child: state is GoogleAuthLoadingState
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/photos/google-logo.png',
                                height: 20),
                            const SizedBox(width: 10),
                            Text('Google Signin'),
                          ],
                        )),
            ],
          );
        },
      ))),
    );
  }
}
