import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/chat/bloc/chat_bloc.dart';
import 'package:we_chat/message/message_api.dart';
import 'package:we_chat/message/message_model.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatBloc _chatBloc = ChatBloc();
  String generateChatRoomId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort(); // Sort user IDs alphabetically
    return '${userIds[0]}_and_${userIds[1]}';
  }

  final user1 = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    _chatBloc.fetchMessages(generateChatRoomId(user1!.uid, widget.user['id']));
  }

  @override
  void dispose() {
    _chatBloc.dispose();
    super.dispose();
  }

  TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.user['photoUrl'] ??
                  'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
            ),
            SizedBox(width: 10),
            Text(widget.user['displayName'] ?? 'not found'),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<List<MessageModel>>(
          stream: _chatBloc.messageStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<MessageModel> messages = snapshot.data!;
              final size = messages.length;
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        reverse: true,
                        itemCount: size,
                        itemBuilder: ((context, index) {
                          return ListTile(
                            leading:
                                messages[index].senderId == widget.user['id']
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(widget
                                                .user['photoUrl'] ??
                                            'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                                      )
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(user1!
                                                .photoURL ??
                                            'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                                      ),
                            title: Text(messages[index].msg),
                            subtitle: Text(messages[index]
                                .time
                                .toDate()
                                .toString()
                                .substring(
                                    0,
                                    messages[index]
                                        .time
                                        .toDate()
                                        .toString()
                                        .lastIndexOf(':'))),
                          );
                        })),
                  ),
                  Container(
                    color: Colors.blue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {}, icon: Icon(Icons.file_copy)),
                        Container(
                          width: MediaQuery.of(context).size.width * .7,
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                                hintText: 'Message...',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              if (_messageController.text.trim() == '') {
                                return;
                              }
                              final MessageModel _message = MessageModel(
                                  msg: _messageController.text.trim(),
                                  time: DateTime.now(),
                                  senderId: user1!.uid,
                                  receiverId: widget.user['id'],
                                  isSeen: false);
                              MessageApi().onMessageSent(
                                  user1!.uid, widget.user['id'], _message);
                              _messageController.clear();
                            },
                            icon: Icon(Icons.play_arrow))
                      ],
                    ),
                  )
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
