import 'package:shared_preferences/shared_preferences.dart';

class GradesApi {
  static Future<dynamic> fetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var synergiaToken = prefs.getString("synergia_token");
    
  }
}
