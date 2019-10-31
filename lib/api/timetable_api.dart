import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetableApi {
  static String apiUrl = 'https://api.librus.pl/2.0';

  static Future<dynamic> fetch(String weekStart) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
    return timetable;
  }
}
