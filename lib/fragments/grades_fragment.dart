import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librus_go/api/grades_api.dart';
import 'package:librus_go/api/store.dart';
import 'package:librus_go/misc/draw_circle.dart';

class GradesFragment extends StatefulWidget {
  @override
  _GradesFragmentState createState() => _GradesFragmentState();
}

class _GradesFragmentState extends State<GradesFragment> {
  dynamic _semesters = {};
  dynamic _selectedSemester = 1;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    print("Refreshing!");
    _semesters = await GradesApi.fetch();
    setState(() {

    });
    _showRefreshSnackbar();
  }

  void _showRefreshSnackbar() {
    final scaffold = Scaffold.of(context);
    var now = new DateTime.now();
    scaffold.showSnackBar(
      SnackBar(
        content:
            Text('Odświeżono o ' + DateFormat("HH:mm").format(now).toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: _semesters.keys.length == 0
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _semesters[_selectedSemester].length,
              itemBuilder: (context, int subjectIndex) =>
                  SubjectWidget(_semesters[_selectedSemester][subjectIndex])),
    );
  }
}

// Specific subject widget
// ignore: must_be_immutable
class SubjectWidget extends StatelessWidget {
  dynamic _subject;

  SubjectWidget(this._subject);

  @override
  Widget build(BuildContext context) {
    return _subject["grades"].length == 0
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 56.0, top: 20.0),
                child: Container(
                  child: Text(
                    capitalize(_subject["Name"]),
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _subject["grades"].length,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, int gradeIndex) =>
                      GradeWidget(_subject["grades"][gradeIndex])),
            ],
          );
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: CustomPaint(painter: DrawCircle()),
                ),
              ),
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
                    },
                    child: new Text("OK"))
              ],
            ));
  }
}
