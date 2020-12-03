import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:silnik_app/api/models/lab.dart';
import 'package:silnik_app/pages/main_lab_view.dart';
import 'package:silnik_app/utils/date_utils.dart';
import 'package:silnik_app/utils/navigation_utils.dart';

import '../lists.dart';
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
  List<Lab> labs = Lists.labs;

  @override
  void initState() {
    super.initState();
    newLab = new Lab.empty();
    labNameController = new TextEditingController();
    newLab.date = DateTime.now();
    newLab.id = labs.fold<int>(0, (max, e) => e.id > max ? e.id : max)+1;
    initializeDateFormatting();
  }



  List<Lab> getLabsList(){
    labs.sort((a, b) => b.date.compareTo(a.date));
    if(dateRange.first!=null && dateRange.last!=null){
      return labs.where((d) => d.date.isAfter(dateRange.first) && d.date.isBefore(dateRange.last.add(Duration(days: 1)))).toList();
    }
    else if(dateRange.first!=null){
      return labs.where((d) => d.date.isAfter(dateRange.first)).toList();
    }
    else if(dateRange.last!=null){
      return labs.where((d) => d.date.isBefore(dateRange.last.add(Duration(days: 1)))).toList();
    }
    else
      return labs;
  }

  Widget labsList() {
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
                  Text("Wczytaj laboratorium", style: textTheme.headline6),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
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
                                            labelText: "Od"
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
                  Container(
                    padding: EdgeInsets.only(top: 8),
                    child: ListView(
                      shrinkWrap: true,
                      children: getLabsList().map((l){
                        return FlatButton(
                          onPressed: (){
                            Navigator.of(context).pushNamed(
                                '/lab/${l.id}');
                          },
                          child: ListTile(
                            title: Text(l.name),
                            subtitle: Text(DateUtils.formatDateTime(context, l.date)),
                            leading: Icon(Icons.assessment_outlined),
                          ),
                        );
                      }).toList()
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
                  Text("Stwórz nowe laboratorium", style: textTheme.headline6),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: new Row(
                            children: [
                              Expanded(child: TextField(
                                controller: labNameController,
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
                              ))
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: (){
                                  showDatePicker(
                                      context: context,
                                      initialDate: newLab.date ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now().add(Duration(days: 1000))
                                  ).then((DateTime value){
                                    if(value!=null){
                                      setState(() {
                                        newLab.date = value;
                                      });
                                    }
                                  });
                                },
                                child: TextField(
                                  readOnly: true,
                                  enabled: false,
                                  controller: TextEditingController(text: newLab.date!=null
                                      ? DateUtils.formatDateYMD(context, newLab.date)
                                      : ""),
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Data"
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: (){
                                  showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                  ).then((value){
                                    if(value!=null){
                                      setState(() {
                                        newLab.date = DateTime(
                                            newLab.date.year,
                                            newLab.date.month,
                                            newLab.date.day,
                                            value.hour,
                                            value.minute);
                                      });
                                    }
                                  });
                                },
                                child: TextField(
                                  readOnly: true,
                                  enabled: false,
                                  controller: TextEditingController(text: newLab.date!=null
                                      ? DateUtils.formatHour(context, newLab.date)
                                      : ""),
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Godzina"
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
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
                              if(newLab!=null) {
                                setState(() {
                                  Lists.labs.add(newLab);
                                  Navigator.of(context).pushNamed(
                                    '/lab/${newLab.id}');
                                });
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
                  child: labsList()
                ),
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