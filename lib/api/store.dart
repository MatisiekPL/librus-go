import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static BehaviorSubject fragmentSubject = new BehaviorSubject();
  static final String baseUrl = 'https://portal.librus.pl';
  static final String baseApiUrl = 'https://api.librus.pl/2.0';
  static final String clientId = 'wmSyUMo8llDAs4y9tJVYY92oyZ6h4lAt7KCuy0Gv';
  static Dio client;
  static DefaultCookieJar jar;

  static init() {
    jar = DefaultCookieJar();
    var _client = Dio(BaseOptions(headers: {'user-agent': 'LibrusMobileApp'}));
    _client.interceptors.add(CookieManager(jar));
    client = _client;
  }

  static Future<String> login(String username, String password) async {
    var response = await client.get(
        '$baseUrl/oauth2/authorize?client_id=$clientId&redirect_uri=http://localhost/bar&response_type=code');
    var document = parse(response.data);
    var csrf = document
        .querySelector('meta[name="csrf-token"][content]')
        .attributes['content'];
    print('Got CSRF: ' + csrf);
    await client.post('$baseUrl/rodzina/login/action',
        data: json.encode({'email': username, 'password': password}),
        options: Options(headers: {
          'X-CSRF-TOKEN': csrf,
          'Content-Type': "application/json"
        }));
    var codeResponse = await client.get(
        '$baseUrl/oauth2/authorize?client_id=$clientId&redirect_uri=http://localhost/bar&response_type=code',
        options: Options(
            followRedirects: false, validateStatus: (status) => status < 500));
    var authCode = codeResponse.headers.value('location').split('code=')[1];
    var exchangeToken = await client.post(
      '$baseUrl/oauth2/access_token',
      data: {
        "grant_type": "authorization_code",
        "code": authCode,
        "client_id": clientId,
        "redirect_uri": "http://localhost/bar"
      },
      options: Options(headers: {"Content-Type": "application/json"}),
    );
    var librusToken = exchangeToken.data['access_token'];
    var librusRefreshToken = exchangeToken.data['refresh_token'];
    print('Got Librus token: ' + librusToken);
    print('Got Librus refresh token: ' + librusRefreshToken);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("librus_token", librusToken);
    await prefs.setString("librus_refresh_token", librusRefreshToken);
    librusToken = await _refreshLibrusToken(librusRefreshToken);
    await prefs.setString("librus_token", librusToken);
    await _loadSynergiaAccounts(librusToken);
    return librusToken;
  }

  static Future<String> _refreshLibrusToken(String librusRefreshToken) async {
    var response = await client.post(
      '$baseUrl/oauth2/access_token',
      data: {
        "grant_type": "refresh_token ",
        "refresh_token": librusRefreshToken,
        "client_id": clientId
      },
      options: Options(headers: {"Content-Type": "application/json"}),
    );
    var librusToken = response.data["access_token"];
    print("Got refreshed librus token: $librusToken");
    return librusToken;
  }

  static Future<String> _loadSynergiaAccounts(String librusToken) async {
    var response = await client.get(
        'https://portal.librus.pl/api/v2/SynergiaAccounts',
        options: Options(headers: {'Authorization': 'Bearer $librusToken'}));
    var synergiaToken = response.data["accounts"][0]["accessToken"];
    print("Got Synergia token: $synergiaToken");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("synergia_token", synergiaToken);
    return synergiaToken;
  }
}
