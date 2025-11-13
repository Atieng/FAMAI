import 'package:flutter/material.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // TODO: Add routes
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Not Found'))));
    }
  }
}
