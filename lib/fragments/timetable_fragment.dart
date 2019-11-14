import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:librus_go/api/store.dart';
import 'package:librus_go/api/timetable_api.dart';
import 'package:librus_go/misc/draw_circle.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../main.dart';

class TimetableFragment extends StatefulWidget {
  @override
  _TimetableFragmentState createState() => _TimetableFragmentState();
}

class _TimetableFragmentState extends State<TimetableFragment> {
  dynamic _timetable = Map<String, List<dynamic>>();
  static DateTime _selectedWeek;
  static bool _notCurrentWeek = false;
  dynamic _setState;
  dynamic _ctx;

  final _scrollController = AutoScrollController(
    axis: Axis.horizontal,
  );

  DateTime _selectWeek(time) {
    var monday = 1;
    while (time.weekday != monday) time = time.subtract(new Duration(days: 1));
    return time;
  }

  @override
  void initState() {
    super.initState();
    _selectedWeek = _selectWeek(DateTime.now());
    Store.actionsSubject.add(<Widget>[
      PopupMenuButton<int>(
        onSelected: (int action) async {
          switch (action) {
            case 1:
              _selectedWeek = _selectedWeek.add(Duration(days: 7));
              _setState(() {
                _timetable = new Map();
              });
              await _refresh(false);
              break;
            case 2:
              _selectedWeek = _selectedWeek.subtract(Duration(days: 7));
              _setState(() {
                _timetable = new Map();
              });
              await _refresh(false);
              break;
            case 3:
              var pendingNotificationRequests =
                  await flutterLocalNotificationsPlugin
                      .pendingNotificationRequests();
              for (var pendingNotificationRequest
                  in pendingNotificationRequests) {
                print(
                    'pending notification: [id: ${pendingNotificationRequest.id}, title: ${pendingNotificationRequest.title}, body: ${pendingNotificationRequest.body}, payload: ${pendingNotificationRequest.payload}]');
              }
              break;
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem<int>(
              value: 1,
              child: Text('Następny tydzień'),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Text('Poprzedni tydzień'),
            ),
            PopupMenuItem<int>(value: 3, child: Text('debuguj'))
          ];
        },
      )
    ]);
    _refresh(true);
  }

  Future<void> _refresh(bool showSnackbar) async {
    _notCurrentWeek =
        _selectWeek(DateTime.now()).difference(_selectedWeek).inHours > 24 ||
            _selectWeek(DateTime.now()).difference(_selectedWeek).inHours < -24;
    print("Refreshing!");
    _timetable = await TimetableApi.fetch(
        new DateFormat('yyyy-MM-dd').format(_selectedWeek));
    print("Refreshed!");
    _setState(() {});
    if (showSnackbar) _showRefreshSnackbar();
    if (!_notCurrentWeek)
      _scrollController.scrollToIndex(DateTime.now().weekday - 1,
          preferPosition: AutoScrollPosition.begin,
          duration: Duration(milliseconds: 1000));
  }

  void _showRefreshSnackbar() {
    final scaffold = Scaffold.of(_ctx);
    var now = new DateTime.now();
    scaffold.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content:
            Text('Odświeżono o ' + DateFormat("HH:mm").format(now).toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        _setState = setState;
        _ctx = context;
        return RefreshIndicator(
          child: _timetable.keys.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _timetable.keys.length,
                  itemBuilder: (context, int dayIndex) => AutoScrollTag(
                      key: ValueKey(dayIndex),
                      index: dayIndex,
                      controller: _scrollController,
                      child: DayWidget(
                          _timetable[_timetable.keys.toList()[dayIndex]],
                          _timetable.keys.toList()[dayIndex],
                          _notCurrentWeek))),
          onRefresh: () async {
            await _refresh(true);
          },
        );
      },
    );
  }
}

class DayWidget extends StatelessWidget {
  dynamic _day;
  dynamic _key;
  dynamic _notCurrentWeek;

  DayWidget(this._day, this._key, this._notCurrentWeek);

  @override
  Widget build(BuildContext context) {
    return _day.every((dynamic day) => day[0]['Subject']['Name'] == 'Okienko')
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 56.0, top: 20.0),
                child: Container(
                  child: Text(
                    _processWeekday(new DateFormat('EEEE')
                            .format(DateFormat("yyyy-MM-dd").parse(_key))) +
                        (_notCurrentWeek ? ' ($_key)' : ''),
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _day.length,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, int lessonIndex) => ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: _day[lessonIndex] != null
                          ? _day[lessonIndex].length
                          : 0,
                      itemBuilder: (context, ind) {
                        // _scheduleNotification(_day[lessonIndex][ind], _key);
                        // return LessonWidget(_day[lessonIndex ][ind], _key);
                        return Builder(builder: (context) {
                          _scheduleNotification(_day[lessonIndex][ind], _key);
                          return LessonWidget(_day[lessonIndex][ind], _key);
                        });
                      })),
            ],
          );
  }

  static List scheduledLessons = [];

  _scheduleNotification(dynamic lesson, key) async {
    // scheduledLessons = [];
    if (lesson['HourFrom'] != "" &&
        !scheduledLessons.contains(int.parse(lesson['Lesson']['Id']))) {
      for (int i = 0; i < 45; i++) {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'Timetable', 'Plan lekcji', 'Powiadomienia o planie lekcji',
            importance: Importance.Low,
            priority: Priority.Min,
            icon: 'app_icon',
            ticker: 'ticker',
            enableVibration: false,
            enableLights: false,
            showProgress: true,
            maxProgress: 45,
            progress: i);
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        if (DateTime.parse('$key ${lesson['HourFrom']}')
                .add(Duration(minutes: i))
                .millisecondsSinceEpoch >
            DateTime.now().millisecondsSinceEpoch) {
          print(DateTime.parse('$key ${lesson['HourFrom']}')
              .add(Duration(minutes: i)));
          await flutterLocalNotificationsPlugin.schedule(
              int.parse(lesson['Lesson']['Id']),
              lesson['Subject']['Name'],
              'Pozostało: ${45 - i}',
              DateTime.parse('$key ${lesson['HourFrom']}')
                  .add(Duration(minutes: i)),
              platformChannelSpecifics);
        }
        scheduledLessons.add(int.parse(lesson['Lesson']['Id']));
      }
    }
  }

  String _translateWeekday(String weekday) {
    switch (weekday) {
      case "Monday":
        return "Poniedziałek";
      case "Tuesday":
        return "Wtorek";
      case "Wednesday":
        return "Środa";
      case "Thursday":
        return "Czwartek";
      case "Friday":
        return "Piątek";
      case "Saturday":
        return "Sobota";
      case "Sunday":
        return "Niedziela";
    }
    return "Nie rozumiem";
  }

  String _processWeekday(String weekday) {
    if (DateFormat("yyyy-MM-dd").parse(_key).day == DateTime.now().day)
      return "Dziś";
    if (DateFormat("yyyy-MM-dd").parse(_key).day == DateTime.now().day - 1)
      return "Wczoraj";
    if (DateFormat("yyyy-MM-dd").parse(_key).day == DateTime.now().day + 1)
      return "Jutro";
    return _translateWeekday(weekday);
  }
}

class LessonWidget extends StatelessWidget {
  dynamic _lesson;
  dynamic _key;

  LessonWidget(this._lesson, this._key);

  void _showDetails(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Szczegóły"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Lekcja:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(capitalize(_lesson['Subject']['Name'])),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Numer lekcji:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(capitalize(_lesson['LessonNo'])),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Kiedy:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  StatefulBuilder(builder: (context, setState) {
                    var timer = '';
                    if ((new DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now())
                                    .toString() ==
                                _key ||
                            new DateFormat('yyyy-MM-dd')
                                    .format(
                                        DateTime.now().add(Duration(days: 1)))
                                    .toString() ==
                                _key) &&
                        (new DateFormat('yyyy-MM-dd HH:mm')
                                .parse('$_key ${_lesson['HourFrom']}')
                                .difference(DateTime.now())
                                .inMilliseconds >
                            0)) {
                      var diff = new DateFormat('yyyy-MM-dd HH:mm')
                          .parse('$_key ${_lesson['HourFrom']}')
                          .difference(DateTime.now());
                      timer = ' (';
                      if (diff.inHours != 0)
                        timer = '$timer${diff.inHours} godz. ';
                      if (diff.inMinutes != 0)
                        timer =
                            '$timer${diff.inMinutes - diff.inHours * 60} min. ';
                      if (diff.inSeconds != 0)
                        timer =
                            '$timer${diff.inSeconds - diff.inHours * 3600 - (diff.inMinutes - diff.inHours * 60) * 60} sekund)';
                      new Timer.periodic(
                          Duration(seconds: 1), (Timer t) => setState(() {}));
                    }
                    return Text(
                        '${_lesson['HourFrom']} - ${_lesson['HourTo']} $timer');
                  }),
                  SizedBox(
                    height: 8.0,
                  ),
                  Container(
                    child: _lesson['classroom'] != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Klasa:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(capitalize(_lesson['classroom']['Symbol'])),
                              SizedBox(
                                height: 8.0,
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  Text(
                    'Nauczyciel:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                      '${capitalize(_lesson['Teacher']['FirstName'])} ${capitalize(_lesson['Teacher']['LastName'])}'),
                  SizedBox(
                    height: 8.0,
                  ),
                ],
              ),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text("OK"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _showDetails(context);
        },
        child: _lesson['Subject']['Name'] == 'Okienko'
            ? Container()
            : Column(
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  _lesson['LessonNo'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: _lesson['IsCanceled'] != null &&
                                            _lesson['IsCanceled']
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          capitalize(
                                              _lesson['Subject']['Name']),
                                          style: TextStyle(
                                              decoration:
                                                  _lesson['IsCanceled'] !=
                                                              null &&
                                                          _lesson['IsCanceled']
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : TextDecoration.none,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        _lesson['IsCanceled'] != null &&
                                                _lesson['IsCanceled']
                                            ? Text(' - (Odwołane)',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.w500))
                                            : Container()
                                      ],
                                    ),
                                    Text(
                                      '${_lesson['HourFrom'].toString()} - ${_lesson['HourTo'].toString()}',
                                      style: TextStyle(
                                          decoration:
                                              _lesson['IsCanceled'] != null &&
                                                      _lesson['IsCanceled']
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                          fontSize: 16.0,
                                          fontStyle: FontStyle.italic),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                child: Text(
                              _lesson['classroom'] != null
                                  ? _lesson['classroom']['Symbol']
                                  : '',
                              style: TextStyle(
                                decoration: _lesson['IsCanceled'] != null &&
                                        _lesson['IsCanceled']
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            )),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ));
  }
}
