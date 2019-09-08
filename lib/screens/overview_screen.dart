import 'package:flutter/material.dart';
import 'package:librus_go/screens/login_screen.dart';

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
//      Navigator.push(
//          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Przegląd')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Mateusz Woźniak"),
              accountEmail: Text("3656771u"),
              currentAccountPicture: CircleAvatar(
                backgroundColor:
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? Colors.blue
                        : Colors.white,
                child: Text(
                  "M",
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Przegląd'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text('Oceny'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Plan lekcji'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Kalendarz'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Ustawienia'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.lightbulb_outline),
              title: Text('O aplikacji'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}
