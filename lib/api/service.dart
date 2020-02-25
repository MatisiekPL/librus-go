import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:librus_go/api/store.dart';
import 'package:preferences/preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'grades_api.dart';

class BackgroundService {
  static fetchInBackground() {
    runZoned(
      () async {
        Store.init();
        await PrefService.init();
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
            return NotificationDetails(
                AndroidNotificationDetails(
                    'librus.${title.replaceAll(" ", "_")}',
                    title,
                    '$title z dziennika',
                    importance: Importance.Default,
                    priority: Priority.High,
                    ticker: 'ticker',
                    enableVibration: true,
                    enableLights: true,
                    playSound: true),
                null);
          }

          var platformChannelSpecifics =
              NotificationDetails(androidPlatformChannelSpecifics, null);
          var notificationId = 0;
          void updateNotification(int x, String title) {
            androidPlatformChannelSpecifics.progress = x;
            notificationsPlugin.show(notificationId, 'Trwa synchronizacja',
                title, platformChannelSpecifics,
                payload: 'sync');
          }

//        updateNotification(0, 'Logowanie');
//        updateNotification(1, 'Oceny');
          var grades = await GradesApi.fetch(null, force: true, raw: true);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          grades.forEach((grade) {
            if ((prefs.containsKey("grade_notify_time")
                    ? prefs.getInt('grade_notify_time')
                    : 0) <
                DateFormat("yyyy-MM-dd HH:mm:ss")
                    .parse(grade['AddDate'])
                    .millisecondsSinceEpoch) {
              notifications.add({
                'id': grade['Id'],
                'specifics': getSpecifics("Oceny"),
                'title': 'Dodano nową ocenę ' +
                    grade['Grade'].toString() +
                    ' z ' +
                    grade['subject']['Name'],
                'description': grade['category']['CountToTheAverage']
                    ? 'Waga: ' + grade['category']['Weight'].toString()
                    : 'Brak wagi',
                'payload': 'grade'
              });
            }
          });
//          notifications = [];
//          var grade = grades[0];
//          notifications.add({
//            'id': grade['Id'],
//            'specifics': getSpecifics("Oceny"),
//            'title': 'Dodano nową ocenę ' +
//                grade['Grade'].toString() +
//                ' z ' +
//                grade['subject']['Name'],
//            'description': grade['category']['CountToTheAverage']
//                ? 'Waga: ' + grade['category']['Weight'].toString()
//                : 'Brak wagi',
//            'payload': 'grade'
//          });

//        notificationsPlugin.cancel(0);
          if (PrefService.getBool("use_notifications") ?? true) {
            print("Showing notifications");
            notifications.forEach((notification) => notificationsPlugin.show(
                notification['id'],
                notification['title'],
                notification['description'],
                notification['specifics']));
            await prefs.setInt(
                "grade_notify_time", DateTime.now().millisecondsSinceEpoch);
          }
        } else {
          print("Cannot login to the account");
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        try {
          sentry.captureException(
            exception: error,
            stackTrace: stackTrace,
          );
          print('Error sent to sentry.io: $error');
        } catch (e) {
          print('Sending report to sentry.io failed: $e');
          print('Original error: $error');
        }
      },
    );
  }
}
