part of 'chat_bloc.dart';

sealed class ChatState {
  const ChatState();
}

final class ChatLoadingState extends ChatState {}

class ChatLoadedState extends ChatState {}
