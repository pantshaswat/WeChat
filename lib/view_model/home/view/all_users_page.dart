import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/models/message_model.dart';
import 'package:we_chat/services/message/message_api.dart';
import 'package:we_chat/services/user/user_api.dart';
import 'package:we_chat/view_model/chat/view/chat_page.dart';
import 'package:we_chat/view_model/home/bloc/home_bloc_bloc.dart';

class AllUserPage extends StatelessWidget {
  const AllUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    context.read<HomeBloc>().add(UserLoadingEvent());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lets Chat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () async {
                FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
              },
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      backgroundColor: Colors.black,
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
                  TextField(
                    decoration: InputDecoration(
                      fillColor: Colors.grey,
                      filled: true,
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: state.allUsers.length,
                        itemBuilder: (context, index) {
                          return StreamBuilder<MessageModel?>(
                              stream: MessageApi().getLastMsg(currentUser!.uid,
                                  state.allUsers[index]['id']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center();
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error getting last message',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    padding: EdgeInsets.only(top: 10),
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border(
                                          top: BorderSide(
                                              color: Colors.white, width: 0.2)),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                    user: state
                                                        .allUsers[index])));
                                      },
                                      leading: CircleAvatar(
                                        radius: 25,
                                        backgroundImage: NetworkImage(state
                                                .allUsers[index]['photoUrl'] ??
                                            'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                                      ),
                                      title: Text(
                                        '${state.allUsers[index]['displayName'] ?? 'not found'}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: snapshot.data?.isSeen ==
                                                        false &&
                                                    snapshot.data?.senderId !=
                                                        currentUser.uid
                                                ? FontWeight.w900
                                                : FontWeight.normal),
                                      ),
                                      subtitle: Text(
                                        snapshot.data?.msg ?? '',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: snapshot.data?.isSeen ==
                                                        false &&
                                                    snapshot.data?.senderId !=
                                                        currentUser.uid
                                                ? FontWeight.w900
                                                : FontWeight.normal),
                                      ),
                                      trailing: Text(
                                        snapshot.data?.time
                                                .toDate()
                                                .toString()
                                                .substring(
                                                    0,
                                                    snapshot.data!.time
                                                        .toDate()
                                                        .toString()
                                                        .lastIndexOf(':')) ??
                                            '',
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              });
                        }),
                  )
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      )),
    );
  }
}
