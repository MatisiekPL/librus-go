import 'package:flutter/material.dart';
import 'package:librus_go/api/store.dart';
import 'package:local_auth/local_auth.dart';
import 'package:preferences/preferences.dart';

class SettingsFragment extends StatefulWidget {
  @override
  _SettingsFragmentState createState() => _SettingsFragmentState();
}

class _SettingsFragmentState extends State<SettingsFragment> {
  @override
  void initState() {
    super.initState();
    Store.actionsSubject.add(<Widget>[]);
  }

  @override
  Widget build(BuildContext context) {
    return PreferencePage([
      PreferenceTitle('Aplikacja'),
      FutureBuilder(
          future: LocalAuthentication().canCheckBiometrics,
          builder: (context, snap) {
            if (snap.data != null && !snap.data) return Container();
            return FutureBuilder(
                future: LocalAuthentication().getAvailableBiometrics(),
                builder: (context, snap2) {
                  if (snap2.data != null &&
                      snap2.data.contains(BiometricType.fingerprint))
                    return SwitchPreference(
                        'Loguj odciskiem palca', 'biometric_login');
                  return Container();
                });
          }),
      SwitchPreference(
        'Powiadomienia',
        'use_notifications',
        defaultVal: true,
      ),
//      DropdownPreference(
//        'Czas odświeżania powiadomień',
//        'refresh_time',
//        defaultVal: '60 minut',
//        values: ['30 minut', '60 minut', '90 minut'],
//      ),
    ]);
  }
}
