import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:librus_go/api/service.dart';
import 'package:librus_go/main.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static BehaviorSubject fragmentSubject = new BehaviorSubject();
  static BehaviorSubject titleSubject = new BehaviorSubject();
  static BehaviorSubject actionsSubject = new BehaviorSubject();
  static final String baseUrl = 'https://portal.librus.pl';
  static final String baseApiUrl = 'https://api.librus.pl/2.0';
  static final String clientId = '6XPsKf10LPz1nxgHQLcvZ1KM48DYzlBAhxipaXY8';
  static Dio client;
  static DefaultCookieJar jar;
  static dynamic synergiaAccount;
  static Map<String, bool> indicators = Map();
  static int gradeReadTime = 0;
  static dynamic overviewScreenSetState;

  static init() {
    jar = DefaultCookieJar();
    var _client = Dio(BaseOptions(headers: {'user-agent': 'LibrusMobileApp'}));
    _client.interceptors.add(CookieManager(jar));
    client = _client;
  }

  static Future<bool> attempt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("librus_token")) {
      var librusToken = prefs.getString('librus_token');
      var librusRefreshToken = prefs.getString('librus_refresh_token');
      print('Got cached Librus token: $librusToken');
      print('Got cached Librus refresh token: $librusRefreshToken');
      librusToken = await _refreshLibrusToken(librusRefreshToken);
      await _loadSynergiaAccounts(librusToken);
      setupBackgroundService();
      return true;
    }
    return false;
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
    await _refreshLibrusToken(librusRefreshToken);
    await _loadSynergiaAccounts(librusToken);
    return librusToken;
  }

  static Future<String> _refreshLibrusToken(
      String oldLibrusRefreshToken) async {
    var response = await client.post(
      '$baseUrl/oauth2/access_token',
      data: {
        "grant_type": "refresh_token",
        "refresh_token": oldLibrusRefreshToken,
        "client_id": clientId
      },
      options: Options(headers: {"Content-Type": "application/json"}),
    );
    var librusToken = response.data["access_token"];
    var librusRefreshToken = response.data["refresh_token"];
    print('Got refreshed Librus token: ' + librusToken);
    print('Got refreshed Librus refresh token: ' + librusRefreshToken);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("librus_token", librusToken);
    await prefs.setString("librus_refresh_token", librusRefreshToken);
    return librusToken;
  }

  static Future<String> _loadSynergiaAccounts(String librusToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var synergiaLogin = prefs.getString("synergia_login");
    var url = 'https://portal.librus.pl/api/v2/SynergiaAccounts' +
        (synergiaLogin != null ? '/fresh/$synergiaLogin' : '');
    var response = await client.get(url,
        options: Options(headers: {'Authorization': 'Bearer $librusToken'}));
    synergiaAccount = response.data;
    if (synergiaLogin == null) synergiaAccount = synergiaAccount["accounts"][0];
    var synergiaToken = synergiaAccount["accessToken"];
    print("Got Synergia token: $synergiaToken");
    await prefs.setString("synergia_token", synergiaToken);
    await prefs.setString("synergia_login", synergiaAccount['login']);
    return synergiaToken;
  }
}

String capitalize(String s) =>
    s.length > 0 ? s[0].toUpperCase() + s.substring(1) : '';
