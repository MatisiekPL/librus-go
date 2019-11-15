import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librus_go/api/grades_api.dart';
import 'package:librus_go/api/store.dart';
import 'package:librus_go/misc/draw_circle.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GradesFragment extends StatefulWidget {
  @override
  _GradesFragmentState createState() => _GradesFragmentState();
}

class _GradesFragmentState extends State<GradesFragment> {
  dynamic _semesters;
  dynamic _selectedSemester = 1;

  @override
  void initState() {
    super.initState();
    _refreshReadTime();
    Store.actionsSubject.add(<Widget>[
      PopupMenuButton<String>(
        onSelected: (String action) {
          switch (action) {
            case "mark_as_read":
              _markAsRead();
              break;
            case "switch_semester":
              _switchSemester();
              break;
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem<String>(
              value: 'mark_as_read',
              child: Text('Oznacz jako przeczytane'),
            ),
            PopupMenuItem<String>(
              value: 'switch_semester',
              child: Text('Zmień semestr'),
            )
          ];
        },
      )
    ]);
    _refresh();
  }

  Future<void> _switchSemester() async {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Zmień semestr"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    _semesters.keys.length,
                    (index) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _semesters.keys.length > 1 && index != 0
                                ? SizedBox(
                                    height: 16.0,
                                  )
                                : Container(),
                            GestureDetector(
                              child: Text(
                                'Semestr ${_semesters.keys.toList()[index]}',
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedSemester =
                                      _semesters.keys.toList()[index];
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        )).toList(),
              ),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text("Anuluj"))
              ],
            ));
  }

  Future<void> _markAsRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        "grade_read_time", new DateTime.now().millisecondsSinceEpoch);
    await _refreshReadTime();
    Store.indicators['grades'] = false;
    Store.overviewScreenSetState();
  }

  Future<void> _refreshReadTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Store.gradeReadTime = prefs.getInt("grade_read_time") ?? 0;
    });
    print('Recently grades was displayed on: ${Store.gradeReadTime}');
  }

  Future<void> _refresh() async {
    print("Refreshing!");
    _semesters = await GradesApi.fetch(null);
    try {
      setState(() {});
    } catch (err) {}
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
        onRefresh: _refresh,
        child: _semesters == null
            ? Center(child: CircularProgressIndicator())
            : (_semesters.keys.length == 0
                ? Center(child: Text('Brak ocen'))
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _semesters[_selectedSemester].length,
                    itemBuilder: (context, int subjectIndex) => SubjectWidget(
                        _semesters[_selectedSemester][subjectIndex]))));
  }
}

// Specific subject widget
// ignore: must_be_immutable
class SubjectWidget extends StatelessWidget {
  dynamic _subject;

  SubjectWidget(this._subject);

  @override
  Widget build(BuildContext context) {
    (_subject["grades"] as List<dynamic>).sort((a, b) =>
        (DateTime.parse(a["AddDate"]).millisecondsSinceEpoch <
                DateTime.parse(b["AddDate"]).millisecondsSinceEpoch)
            ? 1
            : 0);
    return _subject["grades"].length == 0
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () => _simulate(context),
                child: Padding(
                  padding: const EdgeInsets.only(left: 56.0, top: 20.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      capitalize(_subject["Name"]),
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: (_subject["grades"] as List).length,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, int gradeIndex) {
                    _subject["grades"][gradeIndex]['simulate'] = _simulate;
                    _subject["grades"][gradeIndex]['subject'] = {
                      'Name': _subject['Name'],
                    };
                    return GradeWidget(_subject["grades"][gradeIndex]);
                  }),
            ],
          );
  }

  double _calculateAverage(grades) {
    double counter = 0.0;
    double denominator = 0.0;
    if (grades.length < 1) denominator = 1.0;
    grades.forEach((grade) {
      if (grade['category']['CountToTheAverage'] != null &&
          grade['category']['CountToTheAverage'] &&
          grade['Grade'] != "0") {
        try {
          counter = counter +
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
                                  0.5
                              : int.parse(grade['Grade'])))
                      .toDouble();
          denominator = denominator + grade['category']['Weight'].toDouble();
        } catch (err) {}
      }
    });
    return counter / denominator;
  }

  Future<void> _simulate(BuildContext context) async {
    var grades = (_subject['grades'] as List)
        .where((grade) => grade['category']['CountToTheAverage'])
        .toList();
    var dialogSetState;
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Szczegóły dla: ${_subject['Name']}"),
              content: StatefulBuilder(
                builder: (context, setState) {
                  dialogSetState = setState;
                  var average = _calculateAverage(grades) != double.nan
                      ? _calculateAverage(grades).toStringAsFixed(2)
                      : 'brak';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Średnia bieżąca symulowana: $average',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      Text(
                        'Oceny:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Column(
                        children: List.generate(grades.length, (int index) {
                          var grade = grades[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                grades.remove(grade);
                              });
                            },
                            child: Row(
                              children: <Widget>[
                                Text(
                                  '• Ocena ${grade['Grade']} wagi ${grade['category']['Weight']}',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      Text(
                        'Dotyknij ocenę, by zasymulować jej usunięcie',
                      ),
                    ],
                  );
                },
              ),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: Text('Dodaj ocenę'),
                                content: Builder(builder: (context) {
                                  var gradeValue = "1";
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text('Ocena: '),
                                          Builder(builder: (context) {
                                            String selection = gradeValue;
                                            return StatefulBuilder(
                                                builder: (context, setState) {
                                              var counter = -1;
                                              return DropdownButton<String>(
                                                items:
                                                    List.generate(18, (index) {
                                                  var target = ((index + 2) / 3)
                                                      .round()
                                                      .toString();
                                                  if (counter == -1)
                                                    target = target + "-";
                                                  if (counter == 1)
                                                    target = target + "+";
                                                  counter++;
                                                  if (counter > 1) counter = -1;
                                                  return DropdownMenuItem(
                                                    value: target.toString(),
                                                    child: Text(
                                                      target.toString(),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    selection = value;
                                                    gradeValue = selection;
                                                  });
                                                },
                                                value: selection,
                                              );
                                            });
                                          }),
                                          SizedBox(
                                            width: 16.0,
                                          ),
                                          Text('Waga: '),
                                          DropdownButton<int>(
                                              value: 1,
                                              onChanged: (value) {
                                                grades.add({
                                                  'Grade': gradeValue,
                                                  'category': {
                                                    'Weight': value,
                                                    'CountToTheAverage': true
                                                  }
                                                });
                                                dialogSetState(() {});
                                                Navigator.of(context).pop();
                                              },
                                              items: List.generate(
                                                  9,
                                                  (weight) => DropdownMenuItem(
                                                        value: (weight + 1),
                                                        child: Text((weight + 1)
                                                            .toString()),
                                                      )).toList())
                                        ],
                                      ),
                                    ],
                                  );
                                }),
                              ));
                    },
                    child: new Text("Dodaj ocenę")),
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text("OK"))
              ],
            ));
  }
}

// specific grade widget
class GradeWidget extends StatelessWidget {
  dynamic _grade;

  GradeWidget(this._grade);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _showDetails(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
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
                      _grade["Grade"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          capitalize(_grade["category"]["Name"]),
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          _grade["AddDate"],
                          style: TextStyle(
                              fontSize: 16.0, fontStyle: FontStyle.italic),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Store.gradeReadTime <
                      DateFormat("yyyy-MM-dd HH:mm:ss")
                          .parse(_grade['AddDate'])
                          .millisecondsSinceEpoch
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 16.0, top: 8.0, bottom: 8.0),
                      child: Container(
                        child: CustomPaint(painter: DrawCircle()),
                      ),
                    )
                  : Container(),
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
                    'Ocena:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _grade['Grade'],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Przedmiot:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _grade['subject']['Name'],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Data:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _grade['Date'],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Data dodania:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _grade['AddDate'],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Kategoria:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _grade['category']['Name'],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Liczone do średniej:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _grade['category']['CountToTheAverage'] ? 'Tak' : 'Nie',
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Waga:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _grade['category']['CountToTheAverage']
                        ? _grade['category']['Weight'].toString()
                        : 'Brak',
                  ),
                ],
              ),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _grade['simulate'](context);
                    },
                    child: new Text("Sprawdź średnią")),
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text("OK"))
              ],
            ));
  }
}
