import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_chartjs/chartjs.models.dart';
import 'package:flutter_web_chartjs/chartjs.wrapper.dart';
import 'package:silnik_app/api/models/lab.dart';
import 'package:silnik_app/api/models/load_reading.dart';
import 'package:silnik_app/api/models/reading.dart';
import 'package:silnik_app/api/models/task.dart';
import 'package:silnik_app/components/data_table.dart';
import 'package:silnik_app/components/empty_view.dart';
import 'package:silnik_app/lists.dart';
import 'package:silnik_app/pages/base_scaffold.dart';
import 'package:silnik_app/pages/new_lab_view/new_lab_view.dart';
import 'package:silnik_app/utils/date_utils.dart';
import 'package:silnik_app/utils/toast_utils.dart';

class DoneLabView extends StatefulWidget {
  final Lab lab;

  DoneLabView(this.lab, {Key key}) : super(key: key);

  @override
  _DoneLabViewState createState() => _DoneLabViewState(lab);
}

class _DoneLabViewState extends State<DoneLabView> {
  Lab lab;

  EngineState engineState;

  _DoneLabViewState(this.lab);

  TextTheme textTheme;
  List<Task> tasks = new List();
  Task chosenTask;
  List<double> xAxisData = new List();
  List<double> yAxisData = new List();
  String selectedXAxis = "-";
  String selectedYAxis = "-";

  @override
  void initState() {
    tasks = lab.tasks;
    engineState = EngineState.idle;
    fetchData().then((value) => super.initState());
  }

  Future<void> fetchData() async{
      Random r = new Random();
      tasks.forEach((e) {
        List<LoadReading> loads = List.generate(100, (index) => LoadReading((index + r.nextDouble()),
            Reading(
                id: index,
                voltage: r.nextDouble(),
                power: (pow(index,2)).toDouble(),
                statorCurrent: (index+2).toDouble(),
                rotorCurrent: (index+3).toDouble(),
                rotationalSpeed: (index+4).toDouble(),
                powerFrequency: index.toDouble(),
                timeStamp: DateTime.now(),
                task: e)));
        e.loadReadings.addAll(loads);
        // List<IdleReading> idles = List.generate(100, (index) => IdleReading(
        //     Reading(
        //         id: index,
        //         voltage: r.nextDouble(),
        //         power: 1,
        //         statorCurrent: r.nextDouble(),
        //         rotorCurrent: r.nextDouble(),
        //         rotationalSpeed: r.nextDouble(),
        //         powerFrequency: index.toDouble(),
        //         timeStamp: DateTime.now(),
        //         task: e)));
        // e.idleReadings.addAll(idles);
      });
  }

  Widget chart(){
    return Container(
      width: MediaQuery.of(context).size.width*0.65,
      height: MediaQuery.of(context).size.width*0.4,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: ChartJS(
          id: 'my-chart',
          config: ChartConfig(
          type: ChartType.line,
          options: ChartOptions(
            responsive: true,
            legend: ChartLegend(
                position: ChartLegendPosition.top
            ),
            tooltip: ChartTooltip(
              intersect: false,
              mode: ChartTooltipMode.point,
              callbacks: ChartCallbacks(
                label: (ChartTooltipItem tooltip) {
                  return double.parse(tooltip.value).toStringAsFixed(3);
                }
              )
            )
          ),
          data: ChartData(
              labels: xAxisData.map((e){
                return e.toStringAsFixed(3);
              }).toList(),
              datasets: [
                ChartDataset(
                    data: yAxisData,
                    label: "$selectedYAxis = f($selectedXAxis)",
                    backgroundColor:  Colors.blue.withOpacity(0.4)
                )
              ]
          )
      )),
    );
  }

  Widget labAndTaskDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SelectableText("Laboratorium: ",
                          style: textTheme.subtitle1),
                      Expanded(
                          child: SelectableText(lab.name,
                              style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold)))
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SelectableText("Zadanie: ",
                                style: textTheme.subtitle1),
                            Expanded(
                              child: Row(
                                children: [
                                  tasks == null || tasks.isEmpty
                                      ? Container()
                                      : Expanded(
                                          child: FlatButton(
                                            onPressed: () {},
                                            child: DropdownButton<Task>(
                                              value: chosenTask,
                                              underline: Container(),
                                              isExpanded: true,
                                              items: tasks.map((e) {
                                                return DropdownMenuItem(
                                                  child: Text(e.name, style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold)),
                                                  value: e,
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                  if (chosenTask==null || value.id != chosenTask?.id) {
                                                    setState(() {
                                                      chosenTask = value;
                                                      print(chosenTask.toString());
                                                      ToastUtils.showToast(
                                                          "Wybrane ćwiczenie: ${chosenTask.name}");
                                                    });
                                                  }
                                              },
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                new SelectableText("Data rozpoczęcia: ",
                    style: textTheme.subtitle1),
                new SelectableText(
                    DateUtils.formatDateTime(context, lab.date),
                    style: textTheme.subtitle1.copyWith(
                        fontWeight: FontWeight.bold))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget engineStateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                          groupValue: engineState,
                          value: EngineState.idle,
                          onChanged: (x) {
                            if (engineState != EngineState.idle)
                              setState(() {
                                engineState = x;
                              });
                          }),
                      Flexible(child: Text("Stan jałowy"))
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                          groupValue: engineState,
                          value: EngineState.load,
                          onChanged: (x) {
                            if (engineState != EngineState.load)
                              setState(() {
                                engineState = x;
                              });
                          }),
                      Flexible(child: Text("Stan obciążenia"))
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget selectXAxis(){
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        items: engineState==EngineState.idle
            ? (Lists.statsList.where((x) => !x.loadEngineStateReading).map((e) {
          return DropdownMenuItem(
            value: e.symbol,
            child: Text(e.symbol),
          );
        }).toList()..add(DropdownMenuItem(value: "-", child: Text("Oś X"))))
            : Lists.statsList.map((e) {
          return DropdownMenuItem(
            value: e.symbol,
            child: Text(e.symbol),
          );
        }).toList()..add(DropdownMenuItem(value: "-", child: Text("Oś X"))),
        value: selectedXAxis,
        onChanged: (value){
          setState(() {
            selectedXAxis=value;
            if(xAxisData.isNotEmpty) xAxisData.clear();
            switch(engineState){
              case EngineState.load:
                chosenTask.loadReadings.forEach((x) {
                  if(selectedXAxis=="T")
                    xAxisData.add(x.torque);
                  else{
                    xAxisData.add((x.reading.toJson()["${Lists.statsList.firstWhere((e) => e.symbol==value).readingJsonKey}"]));
                  }
                });
                break;
              case EngineState.idle:
                chosenTask.idleReadings.forEach((x) {
                  xAxisData.add((x.reading.toJson()["${Lists.statsList.firstWhere((e) => e.symbol==value).readingJsonKey}"]));
                });
                break;
            }
          });
        },
      ),
    );
  }

  Widget selectYAxis(){
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        items: engineState==EngineState.idle
            ? (Lists.statsList.where((x) => !x.loadEngineStateReading).map((e) {
          return DropdownMenuItem(
            value: e.symbol,
            child: Text(e.symbol),
          );
        }).toList()..add(DropdownMenuItem(value: "-", child: Text("Oś Y"))))
            : Lists.statsList.map((e) {
          return DropdownMenuItem(
            value: e.symbol,
            child: Text(e.symbol),
          );
        }).toList()..add(DropdownMenuItem(value: "-", child: Text("Oś Y"))),
        value: selectedYAxis,
        onChanged: (value){
          setState(() {
            selectedYAxis=value;
            if(yAxisData.isNotEmpty) yAxisData.clear();
            switch(engineState){
              case EngineState.load:
                chosenTask.loadReadings.forEach((x) {
                  if(selectedYAxis=="T")
                    yAxisData.add(x.torque);
                  else{
                    yAxisData.add((x.reading.toJson()["${Lists.statsList.firstWhere((e) => e.symbol==value).readingJsonKey}"]));
                  }
                });
                break;
              case EngineState.idle:
                chosenTask.idleReadings.forEach((x) {
                  yAxisData.add((x.reading.toJson()["${Lists.statsList.firstWhere((e) => e.symbol==value).readingJsonKey}"]));
                });
                break;
            }
          });
        },
      ),
    );
  }

  bool readingsEmpty(){
    return engineState==EngineState.idle ? chosenTask.idleReadings.isEmpty : chosenTask.loadReadings.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;
    return SilnikScaffold.get(context,
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                labAndTaskDetailsCard(),
                chosenTask == null
                    ? EmptyView(
                        message: "Nie wczytano zadania",
                      )
                    : Column(
                  children: [
                    engineStateCard(),
                          readingsEmpty()
                              ? EmptyView(message: "Brak danych")
                              : Column(
                                  children: [
                                    CustomPaginatedTable(
                                      idleReadings: chosenTask.idleReadings,
                                      loadReadings: chosenTask.loadReadings,
                                      isIdleSelected:
                                          engineState == EngineState.idle,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        selectYAxis(),
                                        Flexible(child: chart()),
                                      ],
                                    ),
                                    selectXAxis()
                                  ],
                                )
                        ],
                ),
              ],
            )
        )
    );
  }
}