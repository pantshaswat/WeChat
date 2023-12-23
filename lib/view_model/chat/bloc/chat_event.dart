part of 'chat_bloc.dart';

sealed class ChatEvent {
  const ChatEvent();
}

class ChatInitialEvent extends ChatEvent {
  final Map<String, dynamic> chatFriend;

  ChatInitialEvent({required this.chatFriend});
}
