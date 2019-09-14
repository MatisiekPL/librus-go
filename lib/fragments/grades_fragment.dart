import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librus_go/api/grades_api.dart';
import 'package:librus_go/misc/draw_circle.dart';

class GradesFragment extends StatefulWidget {
  @override
  _GradesFragmentState createState() => _GradesFragmentState();
}

class _GradesFragmentState extends State<GradesFragment> {
  dynamic _subjects = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    print("Refreshing!");
    _subjects = await GradesApi.fetch();
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
      child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, int subjectIndex) => SubjectWidget()),
    );
  }
}

// Specific subject widget
class SubjectWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 56.0, top: 20.0),
          child: Container(
            child: Text(
              'Matematyka',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, int gradeIndex) => GradeWidget()),
      ],
    );
  }
}

// specific grade widget
class GradeWidget extends StatelessWidget {
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
                      '6+',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Aktywność',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Czwartek',
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
              content: Text('something...'),
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
