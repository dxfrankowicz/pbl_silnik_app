import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:silnik_app/api/api_client.dart';
import 'package:silnik_app/api/models/lab.dart';
import 'package:silnik_app/utils/date_utils.dart';
import 'base_scaffold.dart';

class LabChooser extends StatefulWidget {
  static const String route = '/';
  LabChooser({Key key}) : super(key: key);

  @override
  _LabChooserState createState() => _LabChooserState();
}

class _LabChooserState extends State<LabChooser> {
  TextTheme textTheme;
  List<DateTime> dateRange = [null, null];

  Lab newLab;
  TextEditingController labNameController;
  final _labNameKey = GlobalKey<FormState>();
  List<Lab> labs = [];

  bool isLoading;

  @override
  void initState() {
    fetchLabsList();
    super.initState();
    newLab = new Lab.empty();
    labNameController = new TextEditingController();
    initializeDateFormatting();
  }

  void fetchLabsList(){
    labs.clear();
    setState(() {
      isLoading = true;
    });
    ApiClient().getLabsList().then((value) => setState((){
      labs.addAll(value.labs);
      isLoading = false;
    }));
  }

  List<Lab> getLabsList(){
    List<Lab> l = labs;
    if(dateRange.first!=null && dateRange.last!=null){
      l = labs.where((d) => d.date.isAfter(dateRange.first) && d.date.isBefore(dateRange.last.add(Duration(days: 1)))).toList();
    }
    else if(dateRange.first!=null){
      l = labs.where((d) => d.date.isAfter(dateRange.first)).toList();
    }
    else if(dateRange.last!=null){
      l = labs.where((d) => d.date.isBefore(dateRange.last.add(Duration(days: 1)))).toList();
    }
    return l;
  }

  List<Lab> getSortedByDateLabsList(){
    return getLabsList()..sort((a, b) => b.date.compareTo(a.date));
  }


  Widget labsList() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Wczytaj laboratorium", style: textTheme.headline6),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child:  isLoading ? CircularProgressIndicator() : Column(
                      children: [
                        new Row(
                          children: [
                            Expanded(child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FlatButton(
                                      padding: EdgeInsets.all(0),
                                      onPressed: (){
                                        showDatePicker(
                                          context: context,
                                          initialDate: dateRange.first ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now().add(Duration(days: 1000))
                                        ).then((DateTime value){
                                          if(value!=null){
                                            setState(() {
                                              dateRange.first = value;
                                            });
                                          }
                                        });
                                      },
                                      child: TextField(
                                        readOnly: true,
                                        enabled: false,
                                        controller: TextEditingController(text: dateRange.first!=null
                                            ? DateFormat("dd-M-yyyy").format(dateRange.first)
                                            : ""),
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Sortuj od dnia"
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(" - ")),
                                  Expanded(
                                    child: FlatButton(
                                      padding: EdgeInsets.all(0),
                                      onPressed: (){
                                        showDatePicker(
                                          context: context,
                                          initialDate: dateRange.last ?? dateRange.first ?? DateTime.now(),
                                            firstDate: dateRange.first ?? DateTime(2000),
                                            lastDate: DateTime.now().add(Duration(days: 1000))
                                        ).then((DateTime value){
                                          if(value!=null){
                                            setState(() {
                                              dateRange.last = value;
                                            });
                                          }
                                        });
                                      },
                                      child: TextField(
                                        readOnly: true,
                                        enabled: false,
                                        controller: TextEditingController(text: dateRange.last!=null
                                            ? DateFormat("dd-MM-yyyy").format(dateRange.last)
                                            : ""),
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Do"
                                        ),
                                      ),
                                    ),
                                  )

                                ],
                              ),
                            ))
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 8),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: getSortedByDateLabsList().length,
                          itemBuilder: (BuildContext context, int index) {
                            Lab l = getSortedByDateLabsList()[index];
                            return FlatButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/lab/${l.id}');
                              },
                              child: ListTile(
                                title: Text(l.name),
                                subtitle: Text(
                                    MyDateUtils.formatDateTime(context, l.date)),
                                leading: Icon(Icons.assessment_outlined),
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget createLab() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Utwórz nowe laboratorium", style: textTheme.headline6),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: new Row(
                            children: [
                              Expanded(child: Form(
                                key: _labNameKey,
                                child: TextFormField(
                                  controller: labNameController,
                                  validator: (value) {
                                    if (value.isEmpty || value=="") {
                                      return 'Pole nie może być puste';
                                    }
                                    return null;
                                  },
                                  onChanged: (x){
                                    setState(() {
                                      newLab.name = x;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Nazwa laboratorium",
                                    hintText: "Wpisz nazwę laboratorium"
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
                              if(_labNameKey.currentState.validate()) {
                                if (newLab != null) {
                                  int id;
                                  setState(() {
                                    ApiClient().addLab(newLab).then((value) {
                                      id = value.id;
                                      labNameController.clear();
                                      Navigator.of(context).pushNamed(
                                          '/new-lab/$id').then((value) => fetchLabsList());
                                    });
                                  });
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Utwórz i przejdź do laboratorium".toUpperCase(),
                                  style: textTheme.bodyText1),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(color: Colors.black)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;
    return SilnikScaffold.get(
        context,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  child: labsList(),
                )
              ),
              Expanded(
                child: Container(
                    child: createLab()
                ),
              ),
            ],
          ),
        )
    );
  }
}

enum DateFilter {all, byDate}