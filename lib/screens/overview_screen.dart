import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:librus_go/api/store.dart';
import 'package:librus_go/fragments/absences_fragment.dart';
import 'package:librus_go/fragments/calendar_fragment.dart';
import 'package:librus_go/fragments/desk_fragment.dart';
import 'package:librus_go/fragments/grades_fragment.dart';
import 'package:librus_go/fragments/notices_fragment.dart';
import 'package:librus_go/fragments/settings_fragment.dart';
import 'package:librus_go/fragments/timetable_fragment.dart';
import 'package:librus_go/main.dart';
import 'package:librus_go/misc/draw_circle.dart';
import 'package:librus_go/screens/about_screen.dart';
import 'package:librus_go/screens/login_screen.dart';
import 'package:sentry/sentry.dart';
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
    Store.fragmentSubject.add(DeskFragment());
    Store.titleSubject.add('Biurko');
    Store.overviewScreenSetState = () {
      setState(() {});
    };
  }

  logTap(title) {
    sentry.capture(
        event: Event(
            message: title,
            level: SeverityLevel.info,
            userContext: User(
              id: Store.synergiaAccount["login"],
              username: Store.synergiaAccount["studentName"],
            )));
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
                          Text('Biurko'),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
//                      child: CustomPaint(painter: DrawCircle()),
                                ),
                          ),
                        ],
                      ),
                      onTap: () {
                        logTap("User tapped to desk fragment button");
                        Store.fragmentSubject.add(DeskFragment());
                        Store.titleSubject.add('Biurko');
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
                        logTap("User tapped to grades fragment button");
                        Store.fragmentSubject.add(GradesFragment());
                        Store.titleSubject.add('Oceny');
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.access_time),
                      title: Text('Plan lekcji'),
                      onTap: () {
                        logTap("User tapped to timetable fragment button");
                        Store.fragmentSubject.add(TimetableFragment());
                        Store.titleSubject.add('Plan lekcji');
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('Kalendarz'),
                      onTap: () {
                        logTap("User tapped to calendar fragment button");
                        Store.fragmentSubject.add(CalendarFragment());
                        Store.titleSubject.add('Kalendarz');
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.done_outline),
                      title: Text('Nieobecności'),
                      onTap: () {
                        logTap("User tapped to absences fragment button");
                        Store.fragmentSubject.add(AbsencesFragment());
                        Store.titleSubject.add('Nieobecności');
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.mail_outline),
                      title: Text('Ogłoszenia'),
                      onTap: () {
                        logTap("User tapped to notices fragment button");
                        Store.fragmentSubject.add(NoticesFragment());
                        Store.titleSubject.add('Ogłoszenia');
                        Navigator.of(context).pop();
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Ustawienia'),
                      onTap: () {
                        logTap("User tapped to settings fragment button");
                        Store.fragmentSubject.add(SettingsFragment());
                        Store.titleSubject.add('Ustawienia');
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.lightbulb_outline),
                      title: Text('O aplikacji'),
                      onTap: () {
                        logTap("User tapped to about fragment button");
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AboutScreen()));
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('Wyloguj'),
                      onTap: () async {
                        logTap("User tapped to logout fragment button");
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
