import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:librus_go/screens/login_screen.dart';
import 'package:librus_go/screens/offline_screen.dart';
import 'package:librus_go/screens/overview_screen.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:preferences/preference_service.dart';
import 'package:sentry/sentry.dart';

import 'api/store.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();
FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

const platform = const MethodChannel('librus_go.enteam.pl/utils');

Future<bool> checkIfRunningInAutomatedTestsEnvironment() async {
  return await platform.invokeMethod("checkIfInAutomatedTestsEnvironment")
      as bool;
}

final SentryClient sentry = new SentryClient(
    dsn: "https://b31fd2f23caa45e2b999a3ccc9f81d35@sentry.io/1869678");

void main() {
  initializeDateFormatting()
      .then((_) => WidgetsFlutterBinding.ensureInitialized())
      .then((_) => PrefService.init(prefix: 'pref_'))
      .then((_) => checkIfRunningInAutomatedTestsEnvironment())
      .then((result) {
    if (result) {
      runApp(StopRobot());
      return;
    }
    _firebaseMessaging.getToken().then((token) {
      print("---FCM---");
      print(token);
      print("---FCM---");
    });
    Store.init();
    runZoned(
      () => runApp(App()),
      onError: (Object error, StackTrace stackTrace) {
        try {
          sentry.captureException(
            exception: error,
            stackTrace: stackTrace,
          );
          print('Error sent to sentry.io: $error');
        } catch (e) {
          print('Sending report to sentry.io failed: $e');
          print('Original error: $error');
        }
      },
    );
  });
}

class App extends StatelessWidget {
  Future<bool> _authenticate() async {
    final _auth = LocalAuthentication();
    return await _auth.authenticateWithBiometrics(
        localizedReason: 'Autoryzuj, aby przejść dalej',
        useErrorDialogs: true,
        stickyAuth: true,
        androidAuthStrings: AndroidAuthMessages(
            fingerprintHint: 'Dotknij czytnika',
            fingerprintNotRecognized: 'Nie rozpoznano odcisku palca',
            fingerprintSuccess: 'Prawidłowy odcisk palca',
            cancelButton: 'Odrzuć',
            signInTitle: 'Zaloguj',
            fingerprintRequiredTitle: 'Wymagany odcisk palca',
            goToSettingsButton: 'Przejdź do ustawień',
            goToSettingsDescription:
                'Odcisk palca nie jest ustawiony na tym urządzeniu'));
  }

  Future<Widget> getScreen() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (await Store.attempt()) {
        if (PrefService.getBool("biometric_login") != null &&
            PrefService.getBool("biometric_login")) {
          if (!await _authenticate()) return AccessDenied();
          return OverviewScreen();
        }
        return OverviewScreen();
      }
      return LoginScreen();
    }
    return OfflineScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Librus Go",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: getScreen(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snap) =>
            snap.data != null
                ? snap.data
                : Scaffold(
                    body: Center(child: new CircularProgressIndicator()),
                  ),
      ),
    );
  }
}

class StopRobot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Librus Go",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Przepraszamy, aplikacja nie jest dostępna dla robotów testujących',
            textAlign: TextAlign.center,
          ),
        )),
      ),
    );
  }
}

class AccessDenied extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Librus Go",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Dostęp wzbroniony',
            textAlign: TextAlign.center,
          ),
        )),
      ),
    );
  }
}

String trim(String input, int n) =>
    input.length > n ? input.substring(0, n) + '...' : input;
