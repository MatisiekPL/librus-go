import 'package:flutter/material.dart';
import 'package:librus_go/screens/login_screen.dart';
import 'package:librus_go/screens/overview_screen.dart';

import 'api/store.dart';

void main() {
  Store.init();
  runApp(App());
}

class App extends StatelessWidget {
  Future<Widget> getScreen() async {
    if (await Store.attempt()) return OverviewScreen();
    return LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Librus Go",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: getScreen(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snap) =>
            snap.data != null
                ? snap.data
                : Scaffold(
                    body: Center(child: new CircularProgressIndicator()),
                  ),
      ),
    );
  }
}
