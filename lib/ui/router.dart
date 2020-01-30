import 'package:flutter/material.dart';
import 'package:infrastrucktor/ui/views/dashboard.dart';
import 'package:infrastrucktor/ui/views/main-page.dart';
import 'package:infrastrucktor/ui/views/splash.dart';

class Router {
  static Route<dynamic> generateRoute(settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashView());
      case '/main':
        return MaterialPageRoute(builder: (_) => DashboardMain());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}
