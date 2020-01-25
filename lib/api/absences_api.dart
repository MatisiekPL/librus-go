import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsencesApi {
  static String apiUrl = 'https://api.librus.pl/2.0';

  static Future<dynamic> fetch({bool force}) async {
    if (force == null) force = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!force && prefs.containsKey("absences_cache")) {
      return json.decode(prefs.getString("absences_cache"));
    }
    var synergiaToken = prefs.getString("synergia_token");
    var dio = Dio();
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (Options options) async {
      options.headers["Authorization"] = 'Bearer $synergiaToken';
      return options;
    }));
    var attendances =
        (await dio.get('$apiUrl/Attendances')).data['Attendances'] as List;
    var types =
        (await dio.get('$apiUrl/Attendances/Types')).data['Types'] as List;
    print('Fetched data of attendances. Merging...');
    attendances.forEach((dynamic attendance) => attendance['type'] =
        (types.firstWhere(
                (dynamic type) => type["Id"] == attendance["Type"]["Id"])
            as dynamic));
    await prefs.setString("absences_cache", json.encode(attendances));
    return attendances;
  }
}
