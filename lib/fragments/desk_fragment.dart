import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librus_go/api/grades_api.dart';
import 'package:librus_go/api/store.dart';

class DeskFragment extends StatefulWidget {
  @override
  _DeskFragmentState createState() => _DeskFragmentState();
}

class _DeskFragmentState extends State<DeskFragment> {
  dynamic _semesters;
  var _lastGrades;

  @override
  void initState() {
    super.initState();
    Store.actionsSubject.add(<Widget>[]);
    _refresh();
  }

  Future<void> _refresh() async {
    _lastGrades = new List<dynamic>();
    print("Refreshing!");
    _semesters = await GradesApi.fetch(null);
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView(
        children: <Widget>[
          _lastGrades.length > 0
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Ostatnie oceny',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 16.0,
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
                                                  backgroundColor: Colors.blue,
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
                                                              : TextDecoration
                                                                  .none,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                                ['category']
                                                            ['Name'],
                                                        style: TextStyle(
                                                            decoration: false
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : TextDecoration
                                                                    .none,
                                                            fontSize: 16.0,
                                                            fontStyle: FontStyle
                                                                .italic),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                  child: Text(
                                                _lastGrades[gradeIndex]
                                                            ['category']
                                                        ['CountToTheAverage']
                                                    ? 'Waga: ${_lastGrades[gradeIndex]['category']['Weight'].toString()}'
                                                    : 'Nieliczone',
                                                style: TextStyle(
                                                  decoration: false
                                                      ? TextDecoration
                                                          .lineThrough
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
                )
              : Container(),
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
//                                 backgroundColor: Colors.blue,
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
//                                 backgroundColor: Colors.blue,
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
        ],
      ),
      onRefresh: () async {
        await _refresh();
      },
    );
  }
}
