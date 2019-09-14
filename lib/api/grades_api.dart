import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GradesApi {
  static String apiUrl = 'https://api.librus.pl/2.0';

  static Future<dynamic> fetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var synergiaToken = prefs.getString("synergia_token");
    var dio = Dio();
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (Options options) async {
      options.headers["Authorization"] = 'Bearer $synergiaToken';
      return options;
    }));
    var grades = (await dio.get('$apiUrl/Grades')).data['Grades'] as List;
    var subjects = (await dio.get('$apiUrl/Subjects')).data['Subjects'] as List;
    var categories =
        (await dio.get('$apiUrl/Grades/Categories')).data['Categories'] as List;
    var users = (await dio.get('$apiUrl/Users')).data['Users'] as List;
    print('Fetched data of grades. Merging...');
    grades.forEach((dynamic grade) => grade["category"] =
        (categories.firstWhere(
                (dynamic category) => category["Id"] == grade["Category"]["Id"])
            as dynamic));
    grades.forEach((dynamic grade) => grade["addedBy"] = (users.firstWhere(
        (dynamic user) => user["Id"] == grade["AddedBy"]["Id"]) as dynamic));
    var semesters = [];
    var out = {};
    grades.forEach((dynamic grade) => !semesters.contains(grade["Semester"])
        ? semesters.add(grade["Semester"])
        : null);
    semesters.forEach((dynamic semester) {
      var semesterData = [];
      subjects.forEach((dynamic subject) => semesterData.add(subject));
      semesterData.forEach((dynamic subject) => subject['grades'] = []);
      grades.forEach((dynamic grade) => (semesterData.firstWhere(
                  (dynamic subject) => subject["Id"] == grade["Subject"]["Id"])
              as dynamic)["grades"]
          .add(grade));
      out[semester] = semesterData;
    });
    print('Merging completed');
    return out;
  }
}
