import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_chat/services/message/message_api.dart';

class ChatUserApi {
  Future<void> addChatUser(User? user) async {
    if (user != null) {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'id': user.uid,
          'photoUrl': user.photoURL,
          'displayName': user.displayName,
          'chatFriends': []
        });
      }
    }
  }

  Future<void> addChatFriend(User? user, String friendId) async {
    if (user != null) {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isNotEmpty) {
        final List<dynamic> chatFriends = documents.first.get('chatFriends');
        if (!chatFriends.contains(friendId)) {
          chatFriends.add(friendId);
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'chatFriends': chatFriends});
        }
      }
    }
  }

  Future<void> removeChatFriend(User? user, String friendId) async {
    if (user != null) {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isNotEmpty) {
        final List<dynamic> chatFriends = documents.first.get('chatFriends');
        if (chatFriends.contains(friendId)) {
          chatFriends.remove(friendId);
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'chatFriends': chatFriends});
        }
      }
    }
  }

  Future<List<dynamic>> getChatFriends(User? user) async {
    if (user != null) {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isNotEmpty) {
        final List<dynamic> chatFriends = documents.first.get('chatFriends');
        return chatFriends;
      }
    }
    return [];
  }

  Future<List<dynamic>> getAllChatUsers(User? user) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isNotEqualTo: user!.uid)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      final List<dynamic> chatUsers = documents.map((e) => e.data()).toList();
      return chatUsers;
    }

    return [];
  }
}
