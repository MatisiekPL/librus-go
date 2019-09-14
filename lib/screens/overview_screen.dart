import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:librus_go/api/store.dart';
import 'package:librus_go/fragments/grades_fragment.dart';
import 'package:librus_go/fragments/timetable_fragment.dart';
import 'package:librus_go/misc/draw_circle.dart';
import 'package:librus_go/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  _initAsync() async {
    await initializeDateFormatting('pl_PL', null);
    Store.fragmentSubject.add(GradesFragment());
    Store.titleSubject.add('Oceny');
    Store.overviewScreenSetState = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Store.actionsSubject,
        builder: (context, actionsSnap) => Scaffold(
              appBar: AppBar(
                  actions: actionsSnap.data != null ? actionsSnap.data : null,
                  title: StreamBuilder(
                    stream: Store.titleSubject,
                    builder: (context, snap) =>
                        snap.data != null ? Text(snap.data) : Text('Ładowanie'),
                  )),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      accountName: Text(Store.synergiaAccount["studentName"]),
                      accountEmail: Text(Store.synergiaAccount["login"]),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).platform == TargetPlatform.iOS
                                ? Colors.blue
                                : Colors.white,
                        child: Text(
                          Store.synergiaAccount["studentName"][0]
                              .toString()
                              .toUpperCase(),
                          style: TextStyle(fontSize: 40.0),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.home),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Przegląd'),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
//                      child: CustomPaint(painter: DrawCircle()),
                                ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.library_books),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Oceny'),
                          (Store.indicators['grades'] ?? false)
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: CustomPaint(painter: DrawCircle()),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                      onTap: () {
                        Store.fragmentSubject.add(GradesFragment());
                        Store.titleSubject.add('Oceny');
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.access_time),
                      title: Text('Plan lekcji'),
                      onTap: () {
                        Store.fragmentSubject.add(TimetableFragment());
                        Store.titleSubject.add('Plan lekcji');
                        Navigator.of(context).pop();
                      },
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
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('Wyloguj'),
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.clear();
                        exit(0);
                      },
                    ),
                  ],
                ),
              ),
              body: StreamBuilder(
                stream: Store.fragmentSubject,
                builder: (context, snap) => snap.data != null
                    ? snap.data
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ));
  }
}
