import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:librus_go/screens/login_screen.dart';
import 'package:librus_go/screens/offline_screen.dart';
import 'package:librus_go/screens/overview_screen.dart';

import 'api/store.dart';

void main() {
  initializeDateFormatting().then((_) {
    Store.init();
    runApp(App());
  });
}

class App extends StatelessWidget {
  Future<Widget> getScreen() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (await Store.attempt()) return OverviewScreen();
      return LoginScreen();
    }
    return OfflineScreen();
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
