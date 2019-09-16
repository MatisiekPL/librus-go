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
        'desc': homework['category']['Name'],
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
        'desc': substitution['IsShifted'] ? 'Przesunięcie' : 'Odwołanie',
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
        'parentTeacherConference': parentTeacherConference,
        'desc': 'Wywiadówka'
      });
    });
    classFreeDays.forEach((classFreeDay) {
      var date = new DateFormat('yyyy-MM-dd').parse(classFreeDay['DateFrom']);
      var submit = (target) {
        if (!out.containsKey(target)) out[target] = [];
        if (!out[target]
            .where((dynamic item) => item['kind'] == 'classFreeDay')
            .any((dynamic item) => out[target]
                .where((dynamic item2) => item2['kind'] == 'classFreeDay')
                .any((dynamic item2) =>
                    item2['classFreeDay']['Type']['Id'] ==
                    item['classFreeDay']['Type']['Id'])))
          out[target].add({
            'name': 'Brak zajęć',
            'type': 'normal',
            'subject': 'brak',
            'kind': 'classFreeDay',
            'classFreeDay': classFreeDay,
            'desc': ''
          });
      };
      if (date == new DateFormat('yyyy-MM-dd').parse(classFreeDay['DateTo']))
        submit(date);
      var diff = date.difference(
          new DateFormat('yyyy-MM-dd').parse(classFreeDay['DateTo']));
      for (var i = 0; i < diff.inDays; i++) {
        submit(date.add(Duration(days: i)));
      }
    });
    return out;
  }
}
