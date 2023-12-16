import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/home/view/all_users_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            Text('HomePage'),
            ElevatedButton(
                onPressed: () {
                  try {
                    GoogleSignIn().signOut();
                    FirebaseAuth.instance.signOut();
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text('Logout')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllUserPage()));
                },
                child: Text('All Users'))
          ],
        ),
      )),
    );
  }
}
