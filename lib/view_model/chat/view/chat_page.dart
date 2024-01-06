import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/services/message/message_api.dart';
import 'package:we_chat/models/message_model.dart';
import 'package:we_chat/services/signalling/signalling_service.dart';
import 'package:we_chat/view_model/chat/bloc/chat_bloc.dart';
import 'package:we_chat/view_model/chat/view/video_call_page.dart';

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

  //for video call

  @override
  void initState() {
    _chatBloc.fetchMessages(generateChatRoomId(user1!.uid, widget.user['id']));

    super.initState();
  }

  @override
  void dispose() {
    _chatBloc.dispose();
    _messageController.dispose();
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
          StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('rooms').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                String chatRoomId =
                    generateChatRoomId(user1!.uid, widget.user['id']);
                if (snapshot.hasData &&
                    snapshot.data!.docs.any((doc) => doc.id == chatRoomId)) {
                  return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoCallPage(
                                firendId: widget.user['id'],
                                isJoin: true,
                              ),
                            ));
                      },
                      child: Text('Join call'));
                } else {
                  return IconButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoCallPage(
                              firendId: widget.user['id'],
                              isJoin: false,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.video_call));
                }
              })
        ],
      ),
      body: StreamBuilder<List<MessageModel>>(
          stream: _chatBloc.messageStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              MessageApi().setSeen(user1!.uid, widget.user['id']);
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
                                ? Image.network(
                                    messages[index].msg,
                                    height: 200,
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
                                    MessageApi().lastMessage(user1!.uid,
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
                              MessageApi().lastMessage(
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
