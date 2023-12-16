import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_chat/message/message_model.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc {
  final _messageController = StreamController<List<MessageModel>>.broadcast();
  Stream<List<MessageModel>> get messageStream => _messageController.stream;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _subscription;

  void dispose() {
    _messageController.close();
    _subscription.cancel();
  }

  void fetchMessages(String chatRoomId) async {
    try {
      _subscription = await FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        List<MessageModel> messages = [];
        for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
            in querySnapshot.docs) {
          Map<String, dynamic> data = documentSnapshot.data();
          MessageModel message = MessageModel(
            msg: data['msg'],
            time: data['time'],
            senderId: data['senderId'],
            receiverId: data['receiverId'],
            isSeen: data['isSeen'],
          );
          messages.add(message);
        }
        _messageController.add(messages);
      });
    } catch (e) {
      // Handle error
      print("Error fetching messages: $e");
    }
  }
}
