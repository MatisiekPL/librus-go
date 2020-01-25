import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librus_go/api/grades_api.dart';
import 'package:librus_go/api/store.dart';
import 'package:librus_go/api/timetable_api.dart';
import 'package:librus_go/fragments/timetable_fragment.dart';

class DeskFragment extends StatefulWidget {
  @override
  _DeskFragmentState createState() => _DeskFragmentState();
}

class _DeskFragmentState extends State<DeskFragment> {
  dynamic _timetable = Map<String, List<dynamic>>();
  dynamic _semesters;
  dynamic _currentDay;
  dynamic _currentLesson;
  var _lastGrades;

  @override
  void initState() {
    super.initState();
    Store.actionsSubject.add(<Widget>[]);
    _refresh(false);
  }

  DateTime _selectWeek(time) {
    var monday = 1;
    while (time.weekday != monday) time = time.subtract(new Duration(days: 1));
    return time;
  }

  Future<void> _refresh(bool force) async {
    if (force == null) force = false;
    _lastGrades = new List<dynamic>();
    print("Refreshing!");
    _semesters = await GradesApi.fetch(null, force: force);
    setState(() {});
    _semesters.forEach((dynamic key, dynamic semester) {
      semester.forEach((dynamic subject) {
        subject['grades'].forEach((dynamic grade) {
          var g = Map.from(grade);
          g['subject'] = {'Name': subject['Name']};
          _lastGrades.add(g);
        });
      });
    });
    _lastGrades.sort((a, b) => DateFormat("yyyy-MM-dd HH:mm:ss")
        .parse(b['AddDate'])
        .millisecondsSinceEpoch
        .compareTo(DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(a['AddDate'])
            .millisecondsSinceEpoch));
    _lastGrades = _lastGrades.take(3).toList();
    print('Loaded ${_lastGrades.length} grades');
    _timetable = await TimetableApi.fetch(
        new DateFormat('yyyy-MM-dd').format(_selectWeek(DateTime.now())));
    _currentDay =
        _timetable[DateFormat('yyyy-MM-dd').format(DateTime.now())] ?? null;
    if (_currentDay != null)
      for (dynamic item in _currentDay) {
        item = item[0];
        try {
          if (DateTime.parse(
                          "${new DateFormat('yyyy-MM-dd').format(DateTime.now())} ${item["HourFrom"]}")
                      .millisecondsSinceEpoch <
                  DateTime.now().millisecondsSinceEpoch &&
              DateTime.parse(
                          "${new DateFormat('yyyy-MM-dd').format(DateTime.now())} ${item["HourTo"]}")
                      .millisecondsSinceEpoch >
                  DateTime.now().millisecondsSinceEpoch) {
            _currentLesson = item;
          }
        } catch (err) {}
      }
    try {
      setState(() {});
    } catch (err) {}
  }

  void _showGradeDetails(BuildContext context, dynamic grade) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Szczegóły"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Ocena:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    grade['Grade'],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Przedmiot:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    grade['subject']['Name'],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Data:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    grade['Date'],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Data dodania:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    grade['AddDate'],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Kategoria:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    grade['category']['Name'],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Liczone do średniej:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    grade['category']['CountToTheAverage'] ? 'Tak' : 'Nie',
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Waga:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    grade['category']['CountToTheAverage']
                        ? grade['category']['Weight'].toString()
                        : 'Brak',
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

  Widget _buildWhatsNowCard() {
    return _currentDay == null || _currentLesson == null
        ? Container()
        : Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: new Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Co teraz?',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          Text('Sala: 3')
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(Icons.school),
                              SizedBox(
                                width: 8.0,
                              ),
                              Text(
                                capitalize(_currentLesson['Subject']['Name']),
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                          StatefulBuilder(builder: (context, timerSetState) {
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              timerSetState(() {});
                            });
                            if (DateFormat('yyyy-MM-dd HH:mm')
                                    .parse((new DateFormat('yyyy-MM-dd')
                                            .format(DateTime.now())
                                            .toString() +
                                        " " +
                                        _currentLesson["HourTo"].toString()))
                                    .difference(DateTime.now())
                                    .inSeconds <
                                0)
                              setState(() {
                                _currentLesson = null;
                              });
                            return Text(
                                'Pozostało ${DateFormat('yyyy-MM-dd HH:mm').parse((new DateFormat('yyyy-MM-dd').format(DateTime.now()).toString() + " " + _currentLesson["HourTo"].toString())).difference(DateTime.now()).inMinutes} m, ${DateFormat('yyyy-MM-dd HH:mm').parse((new DateFormat('yyyy-MM-dd').format(DateTime.now()).toString() + " " + _currentLesson["HourTo"].toString())).difference(DateTime.now()).inSeconds - DateFormat('yyyy-MM-dd HH:mm').parse((new DateFormat('yyyy-MM-dd').format(DateTime.now()).toString() + " " + _currentLesson["HourTo"].toString())).difference(DateTime.now()).inMinutes * 60} s.');
                          })
                        ],
                      ),
                    ),
                    StatefulBuilder(builder: (context, setState) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        setState(() {});
                      });
                      return LinearProgressIndicator(
                        value: 1 -
                            DateFormat('yyyy-MM-dd HH:mm')
                                    .parse((new DateFormat('yyyy-MM-dd')
                                            .format(DateTime.now())
                                            .toString() +
                                        " " +
                                        _currentLesson["HourTo"].toString()))
                                    .difference(DateTime.now())
                                    .inSeconds /
                                (45 * 60),
                      );
                    })
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildLastGradesCard() {
    return _lastGrades.length > 0
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Ostatnie oceny',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Container(
                        child: ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _lastGrades.length,
                            itemBuilder: (context, gradeIndex) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      _showGradeDetails(
                                          context, _lastGrades[gradeIndex]);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            CircleAvatar(
                                              backgroundColor:
                                                  const Color(0xFF2255FF),
                                              child: Text(
                                                _lastGrades[gradeIndex]
                                                        ['Grade'] ??
                                                    '',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  decoration:
                                                      false != null && false
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        capitalize(_lastGrades[
                                                                    gradeIndex]
                                                                ['subject']
                                                            ['Name']),
                                                        style: TextStyle(
                                                            decoration: false
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : TextDecoration
                                                                    .none,
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      false
                                                          ? Text(
                                                              ' - (Odwołane)',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500))
                                                          : Container()
                                                    ],
                                                  ),
                                                  Text(
//                                      '${_lesson['HourFrom'].toString()} - ${_lesson['HourTo'].toString()}',
                                                    _lastGrades[gradeIndex]
                                                        ['category']['Name'],
                                                    style: TextStyle(
                                                        decoration: false
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none,
                                                        fontSize: 16.0,
                                                        fontStyle:
                                                            FontStyle.italic),
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
                                            _lastGrades[gradeIndex]['category']
                                                    ['CountToTheAverage']
                                                ? 'Waga: ${_lastGrades[gradeIndex]['category']['Weight'].toString()}'
                                                : 'Nieliczone',
                                            style: TextStyle(
                                              decoration: false
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                            ),
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                ))),
                  ],
                ),
              ),
            ),
          )
        : Container();
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     'Dziś',
//                     style:
//                         TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(
//                     height: 16.0,
//                   ),
//                   Container(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               CircleAvatar(
//                                 backgroundColor: const Color(0xFF2255FF),
//                                 child: Text(
//                                   '1' ?? '',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     decoration: false != null && false
//                                         ? TextDecoration.lineThrough
//                                         : TextDecoration.none,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: <Widget>[
//                                     Row(
//                                       children: <Widget>[
//                                         Text(
//                                           capitalize('coś'),
//                                           style: TextStyle(
//                                               decoration: false
//                                                   ? TextDecoration.lineThrough
//                                                   : TextDecoration.none,
//                                               fontSize: 16.0,
//                                               fontWeight: FontWeight.w500),
//                                         ),
//                                         false
//                                             ? Text(' - (Odwołane)',
//                                                 style: TextStyle(
//                                                     fontSize: 16.0,
//                                                     fontWeight:
//                                                         FontWeight.w500))
//                                             : Container()
//                                       ],
//                                     ),
//                                     Text(
// //                                      '${_lesson['HourFrom'].toString()} - ${_lesson['HourTo'].toString()}',
//                                       '12:40 - 13:25',
//                                       style: TextStyle(
//                                           decoration: false
//                                               ? TextDecoration.lineThrough
//                                               : TextDecoration.none,
//                                           fontSize: 16.0,
//                                           fontStyle: FontStyle.italic),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Container(
//                                 child: Text(
//                               'X.D.',
//                               style: TextStyle(
//                                 decoration: false
//                                     ? TextDecoration.lineThrough
//                                     : TextDecoration.none,
//                               ),
//                             )),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   Divider(),
//                   Container(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               CircleAvatar(
//                                 backgroundColor: const Color(0xFF2255FF),
//                                 child: Text(
//                                   '1' ?? '',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     decoration: false != null && false
//                                         ? TextDecoration.lineThrough
//                                         : TextDecoration.none,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: <Widget>[
//                                     Row(
//                                       children: <Widget>[
//                                         Text(
//                                           capitalize('coś'),
//                                           style: TextStyle(
//                                               decoration: false
//                                                   ? TextDecoration.lineThrough
//                                                   : TextDecoration.none,
//                                               fontSize: 16.0,
//                                               fontWeight: FontWeight.w500),
//                                         ),
//                                         false
//                                             ? Text(' - (Odwołane)',
//                                                 style: TextStyle(
//                                                     fontSize: 16.0,
//                                                     fontWeight:
//                                                         FontWeight.w500))
//                                             : Container()
//                                       ],
//                                     ),
//                                     Text(
// //                                      '${_lesson['HourFrom'].toString()} - ${_lesson['HourTo'].toString()}',
//                                       '12:40 - 13:25',
//                                       style: TextStyle(
//                                           decoration: false
//                                               ? TextDecoration.lineThrough
//                                               : TextDecoration.none,
//                                           fontSize: 16.0,
//                                           fontStyle: FontStyle.italic),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Container(
//                                 child: Text(
//                               'X.D.',
//                               style: TextStyle(
//                                 decoration: false
//                                     ? TextDecoration.lineThrough
//                                     : TextDecoration.none,
//                               ),
//                             )),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
  }

  Widget _buildGradesAverageChartCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Średnia ocen',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Container(
                  height: 200.0,
                  child: charts.TimeSeriesChart(
                    _createGradesAverageData(),
                    animate: true,
                    dateTimeFactory: const charts.LocalDateTimeFactory(),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  List<charts.Series<AverageDay, DateTime>> _createGradesAverageData() {
    var data = <AverageDay>[];
    var averageValues = {};
    var averageDividers = {};
    if (_semesters != null && _semesters.length > 0)
      _semesters["1"].forEach((dynamic subject) {
        if (subject['grades'] != null)
          subject['grades'].forEach((dynamic grade) {
            print(json.encode(grade));
            if (grade['category']['CountToTheAverage'] != null &&
                grade['category']['CountToTheAverage'] &&
                grade['Grade'] != "0") {
              if (averageValues[grade['Date']] == null)
                averageValues[grade['Date']] = 0;
              if (averageDividers[grade['Date']] == null)
                averageDividers[grade['Date']] = 0;
              try {
                averageValues[grade['Date']] = averageValues[grade['Date']] +
                    grade['category']['Weight'].toDouble() *
                        (grade['Grade'].toString().contains('+')
                                ? int.parse(grade['Grade']
                                        .toString()
                                        .replaceAll("+", "")) +
                                    0.5
                                : (grade['Grade'].toString().contains('-')
                                    ? int.parse(grade['Grade']
                                            .toString()
                                            .replaceAll("-", "")) -
                                        0.25
                                    : int.parse(grade['Grade'])))
                            .toDouble();
                averageDividers[grade['Date']]++;
              } catch (err) {}
            }
          });
      });
    averageValues.keys.forEach((date) {
      data.add(AverageDay(DateTime.parse(date),
          (averageValues[date] / averageDividers[date] as double)));
    });
    data.sort((a, b) {
      return b.time.compareTo(a.time);
    });
    return [
      new charts.Series<AverageDay, DateTime>(
        id: 'Average',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (AverageDay sales, _) => sales.time,
        measureFn: (AverageDay sales, _) => sales.value,
        data: data.take(6).toList(),
      )
    ];
  }

  Widget _buildTodayCard() {
    try {
      return _timetable[_timetable.keys.toList()[DateTime.now().weekday - 1]]
              .every((dynamic day) => day[0]['Subject']['Name'] == 'Okienko')
          ? Container()
          : Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Card(
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Dziś',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Container(
                            child: DayWidget(
                          _timetable[_timetable.keys
                              .toList()[DateTime.now().weekday - 1]],
                          _timetable.keys.toList()[DateTime.now().weekday - 1],
                          false,
                          showTitle: false,
                        )),
                      ],
                    ),
                  )),
            );
    } catch (err) {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView(
        children: <Widget>[
          _buildLastGradesCard(),
//          _buildWhatsNowCard(),
//          _buildGradesAverageChartCard(),
          _buildTodayCard()
        ],
      ),
      onRefresh: () async {
        await _refresh(true);
      },
    );
  }
}

class AverageDay {
  final DateTime time;
  final double value;

  AverageDay(this.time, this.value);
}
