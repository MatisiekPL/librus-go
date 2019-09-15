import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librus_go/api/calendar_api.dart';
import 'package:librus_go/api/store.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarFragment extends StatefulWidget {
  @override
  _CalendarFragmentState createState() => _CalendarFragmentState();
}

class _CalendarFragmentState extends State<CalendarFragment>
    with TickerProviderStateMixin {
  CalendarController _calendarController;
  Map<DateTime, List> _events;
  List _selectedEvents;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  _initAsync() async {
    _calendarController = CalendarController();

    final _selectedDay = DateTime.now();
    _calendarController = CalendarController();

    Store.actionsSubject.add(<Widget>[]);
    _refresh();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  Future<void> _refresh() async {
    print("Refreshing!");
    _events = await CalendarApi.fetch();
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

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  @override
  Widget build(BuildContext context) {
    return _events != null
        ? TableCalendar(
            locale: 'pl_PL',
            calendarController: _calendarController,
            events: _events,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              selectedColor: Colors.deepOrange[400],
              todayColor: Colors.deepOrange[200],
              markersColor: Colors.brown[700],
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              formatButtonTextStyle:
                  TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
              formatButtonDecoration: BoxDecoration(
                color: Colors.deepOrange[400],
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            onDaySelected: _onDaySelected,
            onVisibleDaysChanged: _onVisibleDaysChanged,
          )
        : Container();
  }
}
