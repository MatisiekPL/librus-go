import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarApi {
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
    var homeworks =
        (await dio.get('$apiUrl/HomeWorks')).data['HomeWorks'] as List;
    var substitutions = (await dio.get('$apiUrl/Calendars/Substitutions'))
        .data['Substitutions'] as List;
    var categories = (await dio.get('$apiUrl/HomeWorks/Categories'))
        .data['Categories'] as List;
    var subjects = (await dio.get('$apiUrl/Subjects')).data['Subjects'] as List;
    var users = (await dio.get('$apiUrl/Users')).data['Users'] as List;
    var classFreeDays =
        (await dio.get('$apiUrl/ClassFreeDays')).data['ClassFreeDays'] as List;
    var types =
        (await dio.get('$apiUrl/ClassFreeDays/Types')).data['Types'] as List;
    var parentTeacherConferences =
        (await dio.get('$apiUrl/ParentTeacherConferences'))
            .data['ParentTeacherConferences'] as List;
    homeworks.forEach((homework) {
      homework['subject'] = (subjects.firstWhere(
              (dynamic subject) => subject["Id"] == homework["Subject"]["Id"])
          as dynamic);
      homework['category'] = (categories.firstWhere((dynamic category) =>
          category["Id"] == homework["Category"]["Id"]) as dynamic);
    });
    substitutions.forEach((substitution) {
      substitution['orgSubject'] = (subjects.firstWhere((dynamic subject) =>
          subject["Id"] == substitution["OrgSubject"]["Id"]) as dynamic);
      substitution['orgTeacher'] = (users.firstWhere(
              (dynamic user) => user["Id"] == substitution["OrgTeacher"]["Id"])
          as dynamic);
    });
    classFreeDays.forEach((classFreeDay) {
      classFreeDay['type'] = (types.firstWhere(
          (dynamic typ) => typ["Id"] == classFreeDay["Type"]["Id"]) as dynamic);
    });
    var out = new Map<DateTime, List>();
    homeworks.forEach((homework) {
      if (!out
          .containsKey(new DateFormat('yyyy-MM-dd').parse(homework['Date'])))
        out[new DateFormat('yyyy-MM-dd').parse(homework['Date'])] = [];
      out[new DateFormat('yyyy-MM-dd').parse(homework['Date'])].add({
        'name': homework['Content'],
        'type': homework['category']['Name'],
        'from': homework['TimeFrom'],
        'to': homework['TimeTo'],
        'subject': homework['subject'],
        'kind': 'homework',
        'homework': homework
      });
    });
    substitutions.forEach((substitution) {
      if (!out.containsKey(
          new DateFormat('yyyy-MM-dd').parse(substitution['OrgDate'])))
        out[new DateFormat('yyyy-MM-dd').parse(substitution['OrgDate'])] = [];
      out[new DateFormat('yyyy-MM-dd').parse(substitution['OrgDate'])].add({
        'name': substitution['IsShifted']
            ? 'Przesunięcie ${substitution['orgSubject']['Name']} z ${substitution['orgTeacher']['FirstName']} ${substitution['orgTeacher']['LastName']}'
            : 'Odwołane ${substitution['orgSubject']['Name']} z ${substitution['orgTeacher']['FirstName']} ${substitution['orgTeacher']['LastName']}',
        'type': substitution['IsShifted'] ? 'shifting' : 'cancelation',
        'subject': substitution['orgSubject']['Name'],
        'kind': 'substitution',
        'substitution': substitution
      });
    });
    parentTeacherConferences.forEach((parentTeacherConference) {
      if (!out.containsKey(
          new DateFormat('yyyy-MM-dd').parse(parentTeacherConference['Date'])))
        out[new DateFormat('yyyy-MM-dd')
            .parse(parentTeacherConference['Date'])] = [];
      out[new DateFormat('yyyy-MM-dd').parse(parentTeacherConference['Date'])]
          .add({
        'name': parentTeacherConference['Name'],
        'type': 'normal',
        'subject': 'brak',
        'kind': 'parentTeacherConference',
        'parentTeacherConference': parentTeacherConference
      });
    });
//    classFreeDays.forEach((classFreeDay) {
//      if (!out.containsKey(
//          new DateFormat('yyyy-MM-dd').parse(parentTeacherConference['Date'])))
//        out[new DateFormat('yyyy-MM-dd')
//            .parse(parentTeacherConference['Date'])] = [];
//      out[new DateFormat('yyyy-MM-dd').parse(parentTeacherConference['Date'])]
//          .add({
//        'name': parentTeacherConference['Name'],
//        'type': 'normal',
//        'subject': 'brak',
//        'kind': 'parentTeacherConference',
//        'parentTeacherConference': parentTeacherConference
//      });
//    });
    return out;
  }
}
