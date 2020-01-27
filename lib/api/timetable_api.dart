import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetableApi {
  static String apiUrl = 'https://api.librus.pl/2.0';

  static Future<dynamic> fetch(String weekStart, {bool force}) async {
    if (force == null) force = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!force && prefs.containsKey("timetable_cache_$weekStart")) {
      return json.decode(prefs.getString("timetable_cache_$weekStart"));
    }
    var synergiaToken = prefs.getString("synergia_token");
    var dio = Dio();
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (Options options) async {
      options.headers["Authorization"] = 'Bearer $synergiaToken';
      return options;
    }));
    var timetable = (await dio.get('$apiUrl/Timetables?weekStart=$weekStart'))
        .data['Timetable'];
    var classrooms = (await dio.get('$apiUrl/Classrooms')).data['Classrooms'];
    var days = timetable.keys;
    days.forEach((day) {
      timetable[day].forEach((hour) {
        if (hour.length < 1) {
          hour.add({
            'Subject': {'Name': 'Okienko'},
            'Teacher': {'FirstName': '', 'LastName': ''},
            'HourFrom': '',
            'HourTo': ''
          });
        }
        hour.forEach((item) {
          if (item["Classroom"] != null)
            item["classroom"] = classrooms.firstWhere((dynamic classroom) =>
                classroom["Id"].toString() ==
                item["Classroom"]["Id"].toString());
        });
      });
    });
    await prefs.setString("timetable_cache_$weekStart", json.encode(timetable));
    return timetable;
  }
}
