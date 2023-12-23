part of 'auth_bloc_bloc.dart';

@immutable
abstract class GoogleAuthState {}

class GoogleAuthInitialState extends GoogleAuthState {}

class GoogleAuthLoadingState extends GoogleAuthState {}

class GoogleAuthSuccessState extends GoogleAuthState {
  final User user;

  GoogleAuthSuccessState({required this.user});
}

class GoogleAuthFailedState extends GoogleAuthState {
  final String errorMsg;

  GoogleAuthFailedState({required this.errorMsg});
}
