import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:rxdart/rxdart.dart';

class Store {
  static BehaviorSubject fragmentSubject = new BehaviorSubject();
  static final String baseUrl = 'https://portal.librus.pl';
  static final String baseApiUrl = 'https://api.librus.pl/2.0';
  static final String clientId = 'wmSyUMo8llDAs4y9tJVYY92oyZ6h4lAt7KCuy0Gv';
  static Dio client;

  static init() {
    var _client = Dio(BaseOptions(headers: {'user-agent': 'LibrusMobileApp'}));
    _client.interceptors.add(CookieManager(CookieJar()));
    client = _client;
  }

  static Future<String> login(String username, String password) async {
    var response = await client.get(
        '$baseUrl/oauth2/authorize?client_id=$clientId&redirect_uri=http://localhost/bar&response_type=code');
    var document = parse(response.data);

    // Get CSRF from HTML
    var csrfToken = document
        .querySelector('meta[name="csrf-token"][content]')
        .attributes['content'];

    print(csrfToken);
    // Authorize by POSTing credentials
    await client.post('$baseUrl/rodzina/login/action',
        data: json.encode({'email': username, 'password': password}),
        options: Options(headers: {
          'X-CSRF-TOKEN': csrfToken,
          'Content-Type': "application/json"
        }));

    // Get auth code by re-visiting the code URL
    // It will now redirect to localhost with auth code supplied as a parameter.
    var codeResponse = await client.get(
        '$baseUrl/oauth2/authorize?client_id=$clientId&redirect_uri=http://localhost/bar&response_type=code',
        options: Options(
            followRedirects: false, validateStatus: (status) => status < 500));

    var authCode = codeResponse.headers.value('location').split('code=')[1];

    // Exchange auth code for Librus account token
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

    var accessToken = exchangeToken.data['access_token'];
    print(accessToken);

    return accessToken;
  }
}
