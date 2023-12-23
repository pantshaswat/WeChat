import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/services/message/message_api.dart';
import 'package:we_chat/models/message_model.dart';
import 'package:we_chat/view_model/chat/bloc/chat_bloc.dart';

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
            Text(
              widget.user['displayName'] ?? 'not found',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.call)),
          IconButton(onPressed: () {}, icon: Icon(Icons.video_call))
        ],
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
                            title: messages[index].msgType == 1
                                ? Container(
                                    child: Image.network(messages[index].msg),
                                  )
                                : Text(messages[index].msg),
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
                            onPressed: () async {
                              ImagePicker imagePicker = ImagePicker();
                              XFile? pickedFile = await imagePicker
                                  .pickImage(source: ImageSource.gallery)
                                  .catchError((onError) {
                                SnackBar(content: Text('error'));
                              });
                              File? image;

                              String fileName = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              if (pickedFile == null) {
                                return;
                              } else if (pickedFile != null) {
                                image = File(pickedFile.path);
                                if (image != null) {
                                  UploadTask uploadTask =
                                      ChatBloc().uploadImage(image, fileName);
                                  print(uploadTask);
                                  try {
                                    TaskSnapshot snapshot = await uploadTask;
                                    final imageUrl =
                                        await snapshot.ref.getDownloadURL();
                                    print(imageUrl);
                                    final MessageModel _message = MessageModel(
                                      msg: imageUrl,
                                      time: DateTime.now(),
                                      senderId: user1!.uid,
                                      receiverId: widget.user['id'],
                                      isSeen: false,
                                      msgType: 1,
                                    );
                                    MessageApi().onMessageSent(user1!.uid,
                                        widget.user['id'], _message);
                                  } catch (e) {
                                    print(e);
                                  }
                                }
                              }
                            },
                            icon: Icon(Icons.file_copy)),
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
                                isSeen: false,
                                msgType: 0,
                              );
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
