import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/home/view/chat_page.dart';
import 'package:we_chat/user/user_api.dart';

class AllUserPage extends StatefulWidget {
  const AllUserPage({super.key});

  @override
  State<AllUserPage> createState() => _AllUserPageState();
}

class _AllUserPageState extends State<AllUserPage> {
  var users;
  Future<void> getUsers() async {
    final user = FirebaseAuth.instance.currentUser;
    users = await ChatUserApi().getAllChatUsers(user);
    setState(() {});
    print(users);
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            Text('All Users'),
            Expanded(
              child: ListView.builder(
                  itemCount: users?.length ?? 0,
                  itemBuilder: (context, index) {
                    if (users == null)
                      return Container(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    else {
                      return Container(
                        color: Colors.amber,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChatPage(user: users[index])));
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(users[index]
                                    ['photoUrl'] ??
                                'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                          ),
                          title: Text(
                              '${users[index]['displayName'] ?? 'not found'}'),
                        ),
                      );
                    }
                  }),
            )
          ],
        ),
      )),
    );
  }
}
