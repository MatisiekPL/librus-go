import 'package:flutter/material.dart';

class OfflineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.signal_wifi_off,
              size: 112.0,
            ),
            Text(
              'Urządzenie jest offline',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'Spróbuj ponownie później',
            )
          ],
        ),
      ),
    );
  }
}
