
import 'package:fballapp/login/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/page_route_anim.dart';


class RouteName {
  static const String tab = '/';
  static const String home = 'homepage';
  static const String register = 'register';
  static const String loginphone = 'loginphone';
  static const String login = 'login';


}

class Router2 {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.login:
        return NoAnimRouteBuilder(LoginScreen());

      default:
        return CupertinoPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('No route defined for ${settings.name}'),
              ),
            ));
    }
  }
}
