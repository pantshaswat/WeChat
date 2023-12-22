import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/home/bloc/home_bloc_bloc.dart';
import 'package:we_chat/chat/chat_page.dart';
import 'package:we_chat/user/user_api.dart';

class AllUserPage extends StatelessWidget {
  const AllUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<HomeBloc>().add(UserLoadingEvent());
    return Scaffold(
      appBar: AppBar(
        title: Text('Lets Chat'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              onPressed: () async {
                FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: SafeArea(
          child: Center(
        child: BlocConsumer<HomeBloc, HomeBlocState>(
          listener: (context, state) {
            // TODO: implement listener
          },
          builder: (context, state) {
            if (state is UserLoadingState) {
              return CircularProgressIndicator();
            }
            if (state is UserLoadingError) {
              return Center(
                child: Text('Firebase exception: ${state.exception}'),
              );
            }
            if (state is UsersLoadedState) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: state.allUsers.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.all(5),
                            color: Colors.amber,
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                            user: state.allUsers[index])));
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(state
                                        .allUsers[index]['photoUrl'] ??
                                    'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                              ),
                              title: Text(
                                  '${state.allUsers[index]['displayName'] ?? 'not found'}'),
                            ),
                          );
                        }),
                  )
                ],
              );
            } else {
              return Center(
                child: Text('Error'),
              );
            }
          },
        ),
      )),
    );
  }
}
