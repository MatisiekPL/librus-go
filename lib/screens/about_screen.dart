import 'package:flutter/material.dart';
import 'package:librus_go/screens/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: ListView(children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 64.0),
        child: Icon(
          Icons.school,
          color: Colors.blueGrey,
          size: 232.0,
          semanticLabel: 'Librus Go',
        ),
      ),
      Opacity(
        opacity: 0.9,
        child: Center(
          child: Text(
            'Librus Go',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 54.0,
                color: Colors.black),
          ),
        ),
      ),
      SizedBox(
        height: 12.0,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Aplikacja dla Librus Synergia',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            'Stworzone dla uczniów przez uczniów',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            'Icons made by www.flaticon.com',
            style: TextStyle(fontSize: 12.0),
          ),
          SizedBox(
            height: 8.0,
          ),
          RaisedButton(
            onPressed: () {
              launch(
                  'mailto:matisiek11@gmail.com?subject=Opinia%20Librus%20Go');
            },
            child: Text(
              'Kontakt',
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.blue,
          ),
          SizedBox(
            height: 8.0,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.blueGrey,
              size: 32.0,
            ),
          ),
        ],
      ),
    ])));
  }
}
