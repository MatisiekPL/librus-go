import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librus_go/api/absences_api.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AbsencesFragment extends StatefulWidget {
  @override
  _AbsencesFragmentState createState() => _AbsencesFragmentState();
}

class _AbsencesFragmentState extends State<AbsencesFragment> {
  List<dynamic> _data = List();

  @override
  void initState() {
    super.initState();
    _refresh(false);
  }

  _refresh(bool force) async {
    _data = await AbsencesApi.fetch(force: force);
    setState(() {});
    if (force) _showRefreshSnackbar();
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
    return _data.isEmpty
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () async {
              await _refresh(true);
            },
            child: ListView(
              children: <Widget>[
                Builder(builder: (context) {
                  if (_data.isEmpty)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  List<LessonBeing> statistics = [];
                  _data.forEach((item) {
                    if (!statistics.any(
                        (LessonBeing being) => being.id == item['type']['Id']))
                      statistics.add(LessonBeing(
                          item['type']['Id'], item['type']['Name'], 0));
                    statistics = statistics.map((LessonBeing being) {
                      if (being.id == item['type']['Id']) {
                        return LessonBeing(
                            being.id, being.type, being.count + 1);
                      }
                      return being;
                    }).toList();
                  });
                  return AttendancesChart(statistics);
                })
              ],
            ),
          );
  }
}

class AttendancesChart extends StatelessWidget {
  List<LessonBeing> data = [];

  AttendancesChart(this.data);

  List<charts.Series<LessonBeing, String>> _render() {
    return [
      charts.Series<LessonBeing, String>(
        id: 'Obecności',
        domainFn: (LessonBeing ev, _) => ev.type,
        measureFn: (LessonBeing ev, _) => ev.count,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Podsumowanie',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 160.0,
                child: charts.PieChart(
                  _render(),
                  animate: true,
                  behaviors: [
                    new charts.DatumLegend(
                      position: charts.BehaviorPosition.end,
                      outsideJustification:
                          charts.OutsideJustification.endDrawArea,
                      horizontalFirst: false,
                      desiredMaxRows: 4,
                      cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                      entryTextStyle: charts.TextStyleSpec(fontSize: 15),
                      showMeasures: true,
                      legendDefaultMeasure:
                          charts.LegendDefaultMeasure.firstValue,
                      measureFormatter: (num value) {
                        return value == null ? '-' : '$value';
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LessonBeing {
  final int id;
  final String type;
  final int count;

  LessonBeing(this.id, this.type, this.count);
}
