import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/user/user_api.dart';
part 'auth_bloc_event.dart';
part 'auth_bloc_state.dart';

class AuthBloc extends Bloc<AuthBlocEvent, GoogleAuthState> {
  AuthBloc() : super(GoogleAuthInitialState()) {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final _auth = FirebaseAuth.instance;
    void login() async {
      emit(GoogleAuthLoadingState());
      try {
        //select google account
        final userAccount = await _googleSignIn.signIn();
        //if user dissmiss the account dialoug
        if (userAccount == null) return;

        //get authentication object from account
        final GoogleSignInAuthentication googleAuth =
            await userAccount.authentication;

        //create OAuthCredentials from auth object
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        ChatUserApi().addChatUser(userCredential.user);
        emit(GoogleAuthSuccessState(user: userCredential.user!));
      } catch (e) {
        emit(GoogleAuthFailedState(errorMsg: e.toString()));
      }
    }

    on<AuthEventInitialize>((event, emit) {
      login();
    });
  }
}
