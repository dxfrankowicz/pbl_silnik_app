import 'package:flutter/material.dart';
import 'package:silnik_app/api/models/lab.dart';
import 'package:silnik_app/data/api_client.dart';
import 'done_lab_view.dart';

class DoneLabPage extends StatefulWidget {
  final int id;
  const DoneLabPage(this.id);

  @override
  _DoneLabPageState createState() => _DoneLabPageState();
}

class _DoneLabPageState extends State<DoneLabPage> {
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
              return DoneLabView(lab);
            }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return lab == null ? _futureBody : DoneLabView(lab);
  }
}
