import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librus_go/api/notices_api.dart';
import 'package:librus_go/api/store.dart';
import 'package:librus_go/main.dart';

class NoticesFragment extends StatefulWidget {
  @override
  _NoticesFragmentState createState() => _NoticesFragmentState();
}

class _NoticesFragmentState extends State<NoticesFragment> {
  List<dynamic> _data = List();

  @override
  void initState() {
    super.initState();
    _refresh(false);
    Store.actionsSubject.add(<Widget>[]);
  }

  _refresh(bool force) async {
    _data = await NoticesApi.fetch(force: force);
    setState(() {});
    if (force) _showRefreshSnackbar();
  }

  void _showRefreshSnackbar() {
    final scaffold = Scaffold.of(context);
    var now = new DateTime.now();
    scaffold.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content:
            Text('Odświeżono o ' + DateFormat("HH:mm").format(now).toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _data.isEmpty
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () async {
              await _refresh(true);
            },
            child: ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, idx) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          trim(capitalize(_data[idx]["Subject"]), 32),
                          style: TextStyle(fontSize: 20.0),
                          textAlign: TextAlign.justify,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                _data[idx]["Content"],
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 100,
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "\n" +
                                    _data[idx]["CreationDate"] +
                                    " - " +
                                    _data[idx]["addedBy"]["FirstName"] +
                                    " " +
                                    _data[idx]["addedBy"]["LastName"],
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 100,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
}
