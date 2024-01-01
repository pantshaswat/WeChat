import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:we_chat/services/signalling/signalling_service.dart';

class VideoCallPage extends StatefulWidget {
  String firendId;
  VideoCallPage({super.key, required this.firendId});
  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  Signaling signalling = Signaling();
  String? roomId;
  TextEditingController _textEditingController =
      TextEditingController(text: '');

  String generateChatRoomId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort(); // Sort user IDs alphabetically
    return '${userIds[0]}_and_${userIds[1]}';
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    localRenderer.initialize();
    remoteRenderer.initialize();
    signalling.onAddRemoteStream = ((stream) {
      remoteRenderer.srcObject = stream;
      setState(() {});
    });
    signalling.openUserMedia(localRenderer, remoteRenderer);
    super.initState();
  }

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        ElevatedButton(
            onPressed: () {
              signalling.openUserMedia(localRenderer, remoteRenderer);
            },
            child: Text('Open Media')),
        ElevatedButton(
            onPressed: () async {
              roomId = await signalling.createRoom(remoteRenderer,
                  generateChatRoomId(currentUser!.uid, widget.firendId));
              _textEditingController.text = roomId!;
              setState(() {});
            },
            child: Text('create room')),
        ElevatedButton(
            onPressed: () {
              signalling.joinRoom(
                  generateChatRoomId(currentUser!.uid, widget.firendId),
                  remoteRenderer);
            },
            child: Text('join room')),
        IconButton(
          onPressed: () {
            signalling.hangUp(localRenderer,
                generateChatRoomId(currentUser!.uid, widget.firendId));
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.call,
            color: Colors.red,
          ),
        ),
      ]),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: RTCVideoView(
            remoteRenderer,
            placeholderBuilder: (context) {
              return Text('no video');
            },
          )),
          Expanded(
              child: RTCVideoView(
            localRenderer,
            mirror: true,
          )),
          TextField(
            controller: _textEditingController,
          )
        ],
      )),
    );
  }
}
