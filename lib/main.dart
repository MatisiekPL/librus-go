import 'package:flutter/material.dart';
import 'package:librus_go/screens/overview_screen.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Librus Go",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OverviewScreen(),
    );
  }
}
