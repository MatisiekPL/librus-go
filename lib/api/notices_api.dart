import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticesApi {
  static String apiUrl = 'https://api.librus.pl/2.0';

  static Future<dynamic> fetch({bool force}) async {
    if (force == null) force = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!force && prefs.containsKey("notices_cache")) {
      return json.decode(prefs.getString("notices_cache"));
    }
    var synergiaToken = prefs.getString("synergia_token");
    var dio = Dio();
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (Options options) async {
      options.headers["Authorization"] = 'Bearer $synergiaToken';
      return options;
    }));
    var notices =
        (await dio.get('$apiUrl/SchoolNotices')).data['SchoolNotices'] as List;
    var users = (await dio.get('$apiUrl/Users')).data['Users'] as List;
    notices.forEach((dynamic notice) => notice["addedBy"] = (users.firstWhere(
        (dynamic user) => user["Id"] == notice["AddedBy"]["Id"]) as dynamic));
    await prefs.setString("notices_cache", json.encode(notices));
    return notices;
  }
}
