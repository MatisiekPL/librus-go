import 'package:flutter/material.dart';
import 'package:librus_go/api/store.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();

  bool _loading = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          new ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Logo(),
                    Text(
                      'Librus Go',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 54.0),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    TextField(
                      controller: _usernameFieldController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Adres e-mail'),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    TextField(
                      controller: _passwordFieldController,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), hintText: 'Hasło'),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.blue,
                          child: Text(
                            'Wejdź',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: _loading ? null : () => _login(),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          Container(
            child: _loading ? LinearProgressIndicator() : Container(),
          ),
        ],
      )),
    );
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
    });
    try {
      await Store.login(
          _usernameFieldController.text, _passwordFieldController.text);
    } catch (err) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Coś poszło nie tak...'),
        ),
      );
    }
    Store.jar.deleteAll();
    setState(() {
      _loading = false;
    });
  }
}

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Image.asset(
        'assets/logo.png',
      ),
    );
  }
}
