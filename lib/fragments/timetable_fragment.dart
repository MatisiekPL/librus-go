import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librus_go/api/store.dart';
import 'package:librus_go/api/timetable_api.dart';
import 'package:librus_go/misc/draw_circle.dart';

class TimetableFragment extends StatefulWidget {
  @override
  _TimetableFragmentState createState() => _TimetableFragmentState();
}

class _TimetableFragmentState extends State<TimetableFragment> {
  dynamic _timetable = Map<String, List<dynamic>>();

  @override
  void initState() {
    super.initState();
    Store.actionsSubject.add(<Widget>[]);
    _refresh();
  }

  Future<void> _refresh() async {
    print("Refreshing!");
    _timetable = await TimetableApi.fetch();
    setState(() {});
    _showRefreshSnackbar();
  }

  void _showRefreshSnackbar() {
    final scaffold = Scaffold.of(context);
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
    return RefreshIndicator(
      child: ListView.builder(
          itemCount: _timetable.keys.length,
          itemBuilder: (context, int dayIndex) => DayWidget(
              _timetable[_timetable.keys.toList()[dayIndex]],
              _timetable.keys.toList()[dayIndex])),
      onRefresh: _refresh,
    );
  }
}

class DayWidget extends StatelessWidget {
  dynamic _day;
  dynamic _key;

  DayWidget(this._day, this._key);

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
                        .format(DateFormat("yyyy-MM-dd").parse(_key))),
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
                      itemBuilder: (context, ind) =>
                          LessonWidget(_day[lessonIndex][ind]))),
            ],
          );
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

  LessonWidget(this._lesson);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _showDetails(context);
      },
      child: _lesson['Subject']['Name'] == 'Okienko'
          ? Container()
          : Container(
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
                                    capitalize(_lesson['Subject']['Name']),
                                    style: TextStyle(
                                        decoration:
                                            _lesson['IsCanceled'] != null &&
                                                    _lesson['IsCanceled']
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  _lesson['IsCanceled'] != null &&
                                          _lesson['IsCanceled']
                                      ? Text(' - (Odwołane)',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500))
                                      : Container()
                                ],
                              ),
                              Text(
                                '${_lesson['HourFrom'].toString()} - ${_lesson['HourTo'].toString()}',
                                style: TextStyle(
                                    decoration: _lesson['IsCanceled'] != null &&
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
    );
  }

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
}
