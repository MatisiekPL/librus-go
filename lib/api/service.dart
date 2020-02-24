import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:librus_go/api/store.dart';

import 'grades_api.dart';

class BackgroundService {
  static fetchInBackground() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (await Store.attempt()) {
        var notifications = [];
        FlutterLocalNotificationsPlugin notificationsPlugin =
            FlutterLocalNotificationsPlugin();
        var notificationSettings = InitializationSettings(
            AndroidInitializationSettings('notification_icon'), null);
        await notificationsPlugin.initialize(notificationSettings,
            onSelectNotification: (String payload) async {});
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'librus.sync', 'Synchronizacja', 'Synchronizacja z dziennikiem',
            importance: Importance.Default,
            priority: Priority.High,
            ticker: 'ticker',
            enableVibration: false,
            enableLights: false,
            showProgress: true,
            maxProgress: 6,
            progress: 1,
            playSound: false);
        dynamic getSpecifics(String title) {
          return AndroidNotificationDetails(
              'librus.${title.replaceAll(" ", "_")}',
              title,
              '$title z dziennika',
              importance: Importance.Default,
              priority: Priority.High,
              ticker: 'ticker',
              enableVibration: true,
              enableLights: true,
              playSound: true);
        }

        var platformChannelSpecifics =
            NotificationDetails(androidPlatformChannelSpecifics, null);
        var notificationId = DateTime.now().millisecondsSinceEpoch;
        void updateNotification(int x, String title) {
          androidPlatformChannelSpecifics.progress = x;
          notificationsPlugin.show(notificationId, 'Trwa synchronizacja', title,
              platformChannelSpecifics,
              payload: 'sync');
        }

        updateNotification(0, 'Logowanie');

        updateNotification(1, 'Oceny');
        var grades = await GradesApi.fetch(null, force: true, raw: true);
        grades.forEach((grade) {
          if (Store.gradeReadTime <
              DateFormat("yyyy-MM-dd HH:mm:ss")
                  .parse(grade['AddDate'])
                  .millisecondsSinceEpoch) {
            notifications.add({
              'id': grade['Id'],
              'specifics': getSpecifics("Oceny"),
              'title': 'Dodano nową ocenę: ' + grade['Grade'].toString(),
              'description': 'Przedmiot: ' + grade['subject']['Name'],
              'payload': 'grade'
            });
          }
        });
        // DEBUG
        var grade = grades[0];
        notifications.add({
          'id': grade['Id'],
          'specifics': getSpecifics("Oceny"),
          'title': 'Dodano nową ocenę: ' + grade['Grade'].toString(),
          'description': 'Przedmiot: ' + grade['subject']['Name'],
          'payload': 'grade'
        });
        // /DEBUG
        notificationsPlugin.cancel(0);
        notifications.forEach((notification) => notificationsPlugin.show(
            notification['id'],
            notification['title'],
            notification['body'],
            notification['specifics']));
      }
    }
  }
}
