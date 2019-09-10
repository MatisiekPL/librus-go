import 'package:flutter/material.dart';
import 'package:librus_go/screens/login_screen.dart';
import 'package:librus_go/screens/overview_screen.dart';

import 'api/store.dart';

void main() {
  Store.init();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Librus Go",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}
