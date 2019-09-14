import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    return ListView.builder(
        itemCount: _timetable.keys.length,
        itemBuilder: (context, int dayIndex) => DayWidget(
            _timetable[_timetable.keys.toList()[dayIndex]],
            _timetable.keys.toList()[dayIndex]));
  }
}

class DayWidget extends StatelessWidget {
  dynamic _day;
  dynamic _key;

  DayWidget(this._day, this._key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 56.0, top: 20.0),
          child: Container(
            child: Text(
              _processWeekday(new DateFormat('EEEE')
                  .format(DateFormat("yyyy-MM-dd").parse(_key))),
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, int lessonIndex) => LessonWidget()),
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
    print(DateFormat("yyyy-MM-dd").parse(_key).day.toString() +
        " -- " +
        DateTime.now().day.toString());
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _showDetails(context);
      },
      child: Container(
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
                      'M',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Matematyka',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '7:10 - 8:00',
                          style: TextStyle(
                              fontSize: 16.0, fontStyle: FontStyle.italic),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: CustomPaint(painter: DrawCircle()),
                ),
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
