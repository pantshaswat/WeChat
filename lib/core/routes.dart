import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:we_chat/services/auth/bloc/auth_bloc_bloc.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/core/not_found_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoutes(RouteSettings _settings) {
    switch (_settings.name) {
      case '/':
        return _materialRoute(
            _settings,
            BlocProvider(
              create: (context) => AuthBloc(),
              child: const AuthPage(),
            ));
      default:
        return _materialRoute(_settings, const NotFoundPage());
    }
  }

  static Route<dynamic> _materialRoute(RouteSettings settings, Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
