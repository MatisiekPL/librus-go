import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsencesApi {
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
    var attendances =
        (await dio.get('$apiUrl/Attendances')).data['Attendances'] as List;
    var types =
        (await dio.get('$apiUrl/Attendances/Types')).data['Types'] as List;
    print('Fetched data of attendances. Merging...');
    attendances.forEach((dynamic attendance) => attendance['type'] =
        (types.firstWhere(
                (dynamic type) => type["Id"] == attendance["Type"]["Id"])
            as dynamic));
    return attendances;
  }
}
