part of 'home_bloc_bloc.dart';

@immutable
sealed class HomeBlocState {}

final class HomeBlocInitial extends HomeBlocState {}

class UserLoadingState extends HomeBlocState {}

class UsersLoadedState extends HomeBlocState {
  final List<dynamic> allUsers;
  final User? currentUser;

  UsersLoadedState({required this.allUsers, required this.currentUser});
}

class UserLoadingError extends HomeBlocState {
  final Exception exception;

  UserLoadingError({required this.exception});
}
