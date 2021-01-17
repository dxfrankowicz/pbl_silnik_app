
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_chartjs/chartjs.models.dart';
import 'package:flutter_web_chartjs/chartjs.wrapper.dart';
import 'package:silnik_app/api/models/lab.dart';
import 'package:silnik_app/api/models/stat_value.dart';
import 'package:silnik_app/api/models/task.dart';
import 'package:silnik_app/components/data_table.dart';
import 'package:silnik_app/components/empty_view.dart';
import 'package:silnik_app/data/api_client.dart';
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

  EngineState engineState = EngineState.idle;

  _DoneLabViewState(this.lab);

  TextTheme textTheme;
  List<Task> tasks = [];
  Task chosenTask;
  List<double> xAxisData = [];
  List<double> yAxisData = [];

  List<String> loadSymbols = [];
  List<String> idleSymbols = [];

  String selectedXAxis;
  String selectedYAxis;

  bool isLoading = true;
  RangeValues _currentRangeValues;
  final String xAxisT = "t (czas, kolejne pomiary)";

  @override
  void initState() {
    engineState = EngineState.idle;
    super.initState();
    fetchData();
    selectedXAxis = xAxisT;
    selectedYAxis = "f";
    idleSymbols = Lists.statsList.where((x) => !x.loadEngineStateReading).map((e) => e.symbol).toList();
    idleSymbols.add(xAxisT);
    loadSymbols = Lists.statsList.map((e) => e.symbol).toList();
    loadSymbols.add(xAxisT);
  }

  Future<void> fetchData() async{
      setState(() {
        isLoading = true;
      });
     ApiClient().getLab(lab.id).then((l){
       setState(() {
          lab = l;
          tasks = l.tasks;
          isLoading = false;
       });
     }).catchError((onError){
       ToastUtils.showToast(onError.toString());
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
              animationConfiguration: ChartAnimationConfiguration(
                  duration: Duration(milliseconds: 0)
              ),
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
              labels: xAxisData.map((e) =>e.toStringAsFixed(selectedXAxis==xAxisT ? 0 : 3))
                  .toList().getRange(_currentRangeValues?.start?.toInt() ?? 0, _currentRangeValues?.end?.toInt() ?? xAxisData.length).toList(),
              datasets: [
                ChartDataset(
                    data: yAxisData.getRange(_currentRangeValues?.start?.toInt() ?? 0, _currentRangeValues?.end?.toInt() ?? yAxisData.length).toList(),
                    label: "$selectedYAxis = f($selectedXAxis)",
                    backgroundColor:  Colors.blue.withOpacity(0.4)
                )
              ]
          )
      )),
    );
  }

  bool isIdleEngineState() => engineState==EngineState.idle;

  void fetchYAxisData(){
    if(yAxisData.isNotEmpty) yAxisData.clear();
    switch(engineState){
      case EngineState.load:
        chosenTask.loadReadings.forEach((x) {
          if(selectedYAxis=="T")
            yAxisData.add(x.torque);
          else{
            yAxisData.add((x.reading.toJson()["${Lists.statsList.firstWhere((e) => e.symbol==selectedYAxis).readingJsonKey}"]));
          }
        });
        break;
      case EngineState.idle:
        chosenTask.idleReadings.forEach((x) {
          yAxisData.add((x.reading.toJson()["${Lists.statsList.firstWhere((e) => e.symbol==selectedYAxis).readingJsonKey}"]));
        });
        break;
    }
    setState(() {});
  }

  void fetchXAxisData(){
    if(xAxisData.isNotEmpty) xAxisData.clear();
    switch(engineState){
      case EngineState.load:
        int i = 0;
        chosenTask.loadReadings.forEach((x) {
          if(selectedXAxis=="T")
            xAxisData.add(x.torque);
          else if(selectedXAxis==xAxisT)
            xAxisData.add((i+1).toDouble());
          else{
            xAxisData.add((x.reading.toJson()["${Lists.statsList.firstWhere((e) => e.symbol==selectedXAxis).readingJsonKey}"]));
          }
          i++;
        });
        break;
      case EngineState.idle:
        chosenTask.idleReadings.forEach((x) {
          if(selectedXAxis==xAxisT)
            xAxisData.add(chosenTask.idleReadings.indexOf(x)+1.toDouble());
          else
            xAxisData.add((x.reading.toJson()["${Lists.statsList.firstWhere((e) => e.symbol==selectedXAxis).readingJsonKey}"]));
        });
        break;
    }
    setState(() {});
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
                                                    chosenTask = value;
                                                    setState(() {
                                                      fetchXAxisData();
                                                      fetchYAxisData();
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
                    MyDateUtils.formatDateTime(context, lab.date),
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
        items: engineState == EngineState.idle
            ? idleSymbols.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList()
            : loadSymbols.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
        value: selectedXAxis,
        onChanged: (value){
          setState(() {
            selectedXAxis=value;
            fetchXAxisData();
          });
        },
      ),
    );
  }

  Widget selectYAxis(){
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        items: engineState == EngineState.idle
            ? idleSymbols.where((x) => x!=xAxisT).map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e),
          );
        }).toList()
            : loadSymbols.where((x) => x!=xAxisT).map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e),
          );
        }).toList(),
        value: selectedYAxis,
        onChanged: (value){
          setState(() {
            selectedYAxis=value;
            fetchYAxisData();
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
            child: isLoading
                ? CircularProgressIndicator()
                : Column(
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
                                            isIdleSelected: engineState == EngineState.idle,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              selectYAxis(),
                                              Flexible(child: chart()),
                                            ],
                                          ),
                                          selectXAxis(),
                                          if (xAxisData.isNotEmpty && yAxisData.isNotEmpty)
                                            Container(
                                              width: MediaQuery.of(context).size.width*0.7,
                                              child: RangeSlider(
                                                values: _currentRangeValues == null
                                                    ? RangeValues(
                                                        0,
                                                        isIdleEngineState()
                                                            ? chosenTask.idleReadings?.length?.toDouble() ?? 0
                                                            : chosenTask.loadReadings?.length?.toDouble() ?? 0)
                                                    : _currentRangeValues,
                                                min: 0,
                                                max: xAxisData.length <= 0 ? 1000 : xAxisData.length,
                                                divisions: xAxisData.length<100
                                                    ? xAxisData.length
                                                    : (xAxisData.length <= 0 ? 1000 : xAxisData.length) ~/ 20,
                                                labels: RangeLabels(
                                                  (_currentRangeValues == null
                                                          ? ((isIdleEngineState()
                                                                      ? chosenTask.idleReadings
                                                                      : chosenTask.loadReadings)?.length?.toDouble() ?? 0)
                                                          : _currentRangeValues.start.round()).toString(),
                                                  (_currentRangeValues == null
                                                          ? ((isIdleEngineState()
                                                                      ? chosenTask.idleReadings
                                                                      : chosenTask.loadReadings)?.length?.toDouble() ?? 0)
                                                          : _currentRangeValues.end.round()).toString(),
                                                ),
                                                onChanged: (RangeValues values) {
                                                  setState(() {
                                                    _currentRangeValues = values;
                                                  });
                                                },
                                              ),
                                            ),
                                        ],
                                      )
                              ],
                            ),
                    ],
                  )));
  }
}