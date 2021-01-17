import 'package:flutter/material.dart';
import 'package:silnik_app/api/models/lab.dart';
import 'package:silnik_app/data/api_client.dart';
import 'new_lab_view.dart';

class MainLabPage extends StatefulWidget {
  final int id;
  MainLabPage(this.id);

  @override
  _MainLabPageState createState() => _MainLabPageState();
}

class _MainLabPageState extends State<MainLabPage> {

  Lab lab;
  Widget _futureBody;


  @override
  void initState() {
    super.initState();
    _futureBody = new FutureBuilder<Lab>(
      future: new ApiClient().getLab(widget.id),
      builder: (BuildContext context, AsyncSnapshot<Lab> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else {
              lab = snapshot.data;
              return NewLabView(lab);
            }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return lab == null ? _futureBody : NewLabView(lab);
  }
}