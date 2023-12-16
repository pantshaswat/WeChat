import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:we_chat/user/user_api.dart';

part 'home_bloc_event.dart';
part 'home_bloc_state.dart';

class HomeBloc extends Bloc<HomeBlocEvent, HomeBlocState> {
  HomeBloc() : super(HomeBlocInitial()) {
    on<HomeBlocEvent>((event, emit) {});
    on<UserLoadingEvent>((event, emit) async {
      try {
        emit(UserLoadingState());
        final User? currentUser = FirebaseAuth.instance.currentUser;
        final List<dynamic> allUsers =
            await ChatUserApi().getAllChatUsers(currentUser);
        emit(UsersLoadedState(allUsers: allUsers, currentUser: currentUser));
      } on FirebaseException catch (e) {
        emit(UserLoadingError(exception: e));
      }
    });
  }
}
