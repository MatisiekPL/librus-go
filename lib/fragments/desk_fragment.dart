import 'package:flutter/material.dart';
import 'package:librus_go/api/store.dart';

class DeskFragment extends StatefulWidget {
  @override
  _DeskFragmentState createState() => _DeskFragmentState();
}

class _DeskFragmentState extends State<DeskFragment> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView(
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Ostatnie oceny',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  '5+' ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: false != null && false
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          capitalize('matematyka'),
                                          style: TextStyle(
                                              decoration: false
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        false
                                            ? Text(' - (Odwołane)',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.w500))
                                            : Container()
                                      ],
                                    ),
                                    Text(
//                                      '${_lesson['HourFrom'].toString()} - ${_lesson['HourTo'].toString()}',
                                      'aktywność',
                                      style: TextStyle(
                                          decoration: false
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          fontSize: 16.0,
                                          fontStyle: FontStyle.italic),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                child: Text(
                              'X.D.',
                              style: TextStyle(
                                decoration: false
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            )),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Dziś',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  '1' ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: false != null && false
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          capitalize('coś'),
                                          style: TextStyle(
                                              decoration: false
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        false
                                            ? Text(' - (Odwołane)',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.w500))
                                            : Container()
                                      ],
                                    ),
                                    Text(
//                                      '${_lesson['HourFrom'].toString()} - ${_lesson['HourTo'].toString()}',
                                      '12:40 - 13:25',
                                      style: TextStyle(
                                          decoration: false
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          fontSize: 16.0,
                                          fontStyle: FontStyle.italic),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                child: Text(
                              'X.D.',
                              style: TextStyle(
                                decoration: false
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            )),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  '1' ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: false != null && false
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          capitalize('coś'),
                                          style: TextStyle(
                                              decoration: false
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        false
                                            ? Text(' - (Odwołane)',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.w500))
                                            : Container()
                                      ],
                                    ),
                                    Text(
//                                      '${_lesson['HourFrom'].toString()} - ${_lesson['HourTo'].toString()}',
                                      '12:40 - 13:25',
                                      style: TextStyle(
                                          decoration: false
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          fontSize: 16.0,
                                          fontStyle: FontStyle.italic),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                child: Text(
                              'X.D.',
                              style: TextStyle(
                                decoration: false
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            )),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      onRefresh: () async {},
    );
  }
}
