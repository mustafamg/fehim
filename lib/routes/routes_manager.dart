import 'package:flutter/material.dart';
import 'package:holy_quran/screens/home/surah_selection_screen.dart';
import 'package:holy_quran/screens/splash/splash_screen.dart';

class RoutesManager {
  static const String splashRoute = "/";
  static const String loginRoute = "/login";
  static const String registerRoute = "/register";
  static const String homeRoute = "/home";
}

class RouteGenetator {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    //final args = settings.arguments as Map<String, dynamic>;
    switch (settings.name) {
      case RoutesManager.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RoutesManager.loginRoute:
        return MaterialPageRoute(builder: (_) => const SurahSelectionScreen());
      // case RoutesManager.registerRoute:
      //   return MaterialPageRoute(builder: (_) => const RegisterScreen());

      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('No Route')),
          body: const Center(child: Text("No Route")),
        );
      },
    );
  }
}
