import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:we_chat/models/message_model.dart';

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
        'msgType': message.msgType,
      });
    }
  }

  Stream<List<MessageModel>> mergedMessagesStream(String currentUserId) {
    final Stream<List<MessageModel>> sentMessagesStream = FirebaseFirestore
        .instance
        .collectionGroup('messages')
        .where('senderId', isEqualTo: currentUserId)
        .orderBy('time', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => MessageModel(
                msg: doc['msg'],
                time: doc['time'],
                senderId: doc['senderId'],
                receiverId: doc['receiverId'],
                isSeen: doc['isSeen'],
                msgType: doc['msgType'],
              ))
          .toList();
    });

    final Stream<List<MessageModel>> receivedMessagesStream = FirebaseFirestore
        .instance
        .collectionGroup('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .orderBy('time', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => MessageModel(
                msg: doc['msg'],
                time: doc['time'],
                senderId: doc['senderId'],
                receiverId: doc['receiverId'],
                isSeen: doc['isSeen'],
                msgType: doc['msgType'],
              ))
          .toList();
    });

    return Rx.combineLatest2(
      sentMessagesStream,
      receivedMessagesStream,
      (List<MessageModel> sentMessages, List<MessageModel> receivedMessages) {
        final List<MessageModel> mergedMessages = [
          ...sentMessages,
          ...receivedMessages
        ];
        mergedMessages.sort((a, b) => b.time.compareTo(a.time));
        return mergedMessages;
      },
    );
  }

  Future<void> lastMessage(
      String? user1Id, String? user2Id, MessageModel message) async {
    if (user1Id != null && user2Id != null) {
      await FirebaseFirestore.instance
          .collection('LastMessage')
          .doc(generateChatRoomId(user1Id, user2Id))
          .set({
        'lastMessage': message.msg,
        'lastMessageTime': message.time,
        'lastMessageSenderId': message.senderId,
        'lastMessageReceiverId': message.receiverId,
        'lastMessageIsSeen': message.isSeen,
        'lastMessageMsgType': message.msgType,
      }, SetOptions(merge: true));
    }
  }

  Stream<MessageModel?> getLastMsg(String currentUserId, String friendId) {
    return FirebaseFirestore.instance
        .collection('LastMessage')
        .doc(generateChatRoomId(currentUserId, friendId))
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return MessageModel(
          msg: doc['lastMessage'],
          time: doc['lastMessageTime'],
          senderId: doc['lastMessageSenderId'],
          receiverId: doc['lastMessageReceiverId'],
          isSeen: doc['lastMessageIsSeen'],
          msgType: doc['lastMessageMsgType'],
        );
      } else {
        return null;
      }
    });
  }

  Future<void> setSeen(String currentUserId, String friendId) async {
    final getDoc = await FirebaseFirestore.instance
        .collection('LastMessage')
        .doc(generateChatRoomId(currentUserId, friendId))
        .get();
    if (getDoc.exists) {
      if (getDoc['lastMessageSenderId'] == friendId) {
        await FirebaseFirestore.instance
            .collection('LastMessage')
            .doc(generateChatRoomId(currentUserId, friendId))
            .update({'lastMessageIsSeen': true});
      }
    }
  }
}
