import 'package:flutter/material.dart';

class GradesFragment extends StatefulWidget {
  @override
  _GradesFragmentState createState() => _GradesFragmentState();
}

class _GradesFragmentState extends State<GradesFragment> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 25,
        itemBuilder: (context, int subjectIndex) => SubjectWidget());
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
          padding: const EdgeInsets.only(left: 54.0, top: 20.0),
          child: Container(
            child: Text(
              'Matematyka',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: 20,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, int gradeIndex) => GradeWidget())
      ],
    );
  }
}

// specific grade widget
class GradeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
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
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Aktywność',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Czwartek',
                  style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
