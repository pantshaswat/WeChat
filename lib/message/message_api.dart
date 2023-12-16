import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/message/message_model.dart';

class MessageApi {
  String generateChatRoomId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort(); // Sort user IDs alphabetically
    return '${userIds[0]}_and_${userIds[1]}';
  }

  Future<void> onMessageSent(
      String? user1Id, String? user2Id, MessageModel message) async {
    if (user1Id != null && user2Id != null) {
      await FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(generateChatRoomId(user1Id, user2Id))
          .collection('messages')
          .doc()
          .set({
        'msg': message.msg,
        'time': message.time,
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'isSeen': message.isSeen,
      });
    }
  }
}
