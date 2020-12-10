import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silnik_app/api/models/idle_reading.dart';
import 'package:silnik_app/api/models/lab.dart';
import 'package:silnik_app/api/models/load_reading.dart';
import 'package:silnik_app/api/models/reading.dart';
import 'package:silnik_app/api/models/task.dart';
import 'package:silnik_app/components/empty_view.dart';
import 'package:silnik_app/components/expandable_card.dart';
import 'package:silnik_app/pages/base_scaffold.dart';
import 'package:silnik_app/utils/date_utils.dart';
import 'package:silnik_app/utils/dialog_utils.dart';
import 'package:silnik_app/utils/toast_utils.dart';
import '../../api/models/stat_value.dart';
import '../../lists.dart';

class MainLabView extends StatefulWidget {
  final Lab lab;
  MainLabView(this.lab, {Key key}) : super(key: key);

  @override
  _MainLabViewState createState() => _MainLabViewState(lab);
}

class _MainLabViewState extends State<MainLabView> {

  Lab lab;
  _MainLabViewState(this.lab);

  TextTheme textTheme;
  bool isMacroRunning = false;

  Map<String, TextEditingController> statValueChangeTextController = new Map();
  Map<String, List<TextEditingController>> macroChangeControllerValue = new Map();
  Map<String, bool> macroChangeTextCheckBox = new Map();
  Map<String, bool> statValueChangeTextCheckBox = new Map();

  TextEditingController macroChangeControllerTime = TextEditingController();
  FetchDataType fetchDataType = FetchDataType.manual;

  final _changeValuesCardKey = GlobalKey<FormState>();
  final _macroTimeKey = GlobalKey<FormState>();
  final _macroValueFormKey = GlobalKey<FormState>();

  //fetch data type
  TextEditingController fetchDataIntervalController = TextEditingController(text: 1.toString());
  final _fetchDataIntervalFormKey = GlobalKey<FormState>();

  Timer _labDuration;
  bool addNewTaskTextField = true;

  //tasks
  List<Task> tasks = new List();
  Task chosenTask;

  //engine
  EngineState engineState = EngineState.idle;

  //algorithms
  Map<String,String> algorithms = {
    "VFC open loop, linear": "Skalarny (U/f=  const), charakterystyka liniowa",
    "VFC open loop, quadratic": "Skalarny (U/f = const), charakterystyka kwadratowa",
    "SLVC (sensorless vector control": "Wektorowy bez sprzężenia zwrotnego",
    "SM ASM (servo control for asynchronous motors)": "Wektorowy ze sprzężeniem zwrotnym"
  };
  String code;

  @override
  void initState() {
    code = algorithms.keys.first;
    Lists.statsList.forEach((element) {
      statValueChangeTextController[element.symbol] = TextEditingController();
      statValueChangeTextController[element.symbol].text = 0.toString();

      //macro values: from, step, to
      macroChangeControllerValue[element.symbol] = [TextEditingController(), TextEditingController(), TextEditingController()];
      macroChangeControllerValue[element.symbol].forEach((e) {
        e.text = 0.toString();
      });

      statValueChangeTextCheckBox[element.symbol] = false;
      macroChangeTextCheckBox[element.symbol] = false;
    });
    macroChangeControllerTime.text = 10.toString();
    super.initState();
    if(lab.id==1)
      tasks = Lists.tasksLab1;

    if(tasks!=null && tasks.isNotEmpty)
      chosenTask = tasks.first;
    else
      addNewTaskTextField = tasks.isEmpty;

    _labDuration = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {});
    });
  }

  Timer _timer;
  int macrosDone = 0;
  int macrosTime = 0;

  bool isIdleEngineState() => engineState==EngineState.idle;
  bool isLoadEngineState() => engineState==EngineState.load;

  void _startMacro() {
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (t.tick % int.parse(macroChangeControllerTime.text) == 0)
          changeData();
      });
    });
    isMacroRunning = true;
  }

  void _stopMacro() {
    _timer?.cancel();
    macrosDone = 0;
    isMacroRunning = false;
  }

  void changeData() {
    // macrosDone+=1;
    // if (engineState == EngineState.idle) {
    //   if (macroChangeControllerValue[element.symbol].text != null &&
    //       macroChangeControllerValue[element.symbol].text != "")
    //     setState(() {
    //       chosenTask.value += double.parse(macroChangeControllerValue[element.symbol].text);
    //     });
    // } else{
    //   Lists.statsList.forEach((element) {
    //     if (macroChangeControllerValue[element.symbol].text != null &&
    //         macroChangeControllerValue[element.symbol].text != "")
    //       setState(() {
    //         element.value += double.parse(macroChangeControllerValue[element.symbol].text);
    //       });
    //   });
    // }
  }

  Timer _fetchTimer;
  bool isFetchingPeriodically = false;

  void _startFetchingData() {
    _fetchTimer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (t.tick % int.parse(fetchDataIntervalController.text) == 0)
          fetchData();
      });
    });
    setState(() {
      isFetchingPeriodically = true;
    });
  }

  void _stopFetchingData() {
    setState(() {
      _fetchTimer?.cancel();
      isFetchingPeriodically = false;
    });
  }

  void fetchData() {
    Random r = new Random();
    if (engineState == EngineState.idle) {
      setState(() {
        chosenTask.idleReadings.add(IdleReading(
            Reading(
                id: chosenTask.idleReadings.length+1,
                voltage: r.nextDouble(),
                power: 1,
                statorCurrent: r.nextDouble(),
                rotorCurrent: r.nextDouble(),
                rotationalSpeed: r.nextDouble(),
                powerFrequency: r.nextDouble(),
                timeStamp: DateTime.now(),
                task: chosenTask))
        );
      });
    } else {
      setState(() {
        chosenTask.loadReadings.add(LoadReading(r.nextDouble(),
            Reading(
                id: chosenTask.idleReadings.length+1,
                voltage: r.nextDouble(),
                power: 1,
                statorCurrent: r.nextDouble(),
                rotorCurrent: r.nextDouble(),
                rotationalSpeed: r.nextDouble(),
                powerFrequency: r.nextDouble(),
                timeStamp: DateTime.now(),
                task: chosenTask))
        );
      });
    }
  }


  Widget statValue(StatValue stat, double value) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: TextFormField(
                          controller: TextEditingController(text: value==null
                              ? "-" : "${value.toStringAsFixed(stat.precision)}"),
                          readOnly: true,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            suffix: Container(
                                width: 40,
                                child: Text(stat.unit)),
                            isDense: true,
                            prefix: Container(
                                width: 40,
                                child: Text(stat.symbol)),
                            labelText: stat.desc,
                            border: OutlineInputBorder()
                          ),
                          style: textTheme.subtitle1),
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

  Widget customTextField({StatValue stat, TextEditingController controller,
    bool enabled, String suffixText, String prefixText, String labelText,
    bool showButton = true, bool enableNegative = true,
    bool biggerThantZeroValidation = false, double value}) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    maxLines: 1,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(enableNegative ? '[0-9-.]' : '[0-9.]'))
                    ],
                    validator: (value) {
                      if (value.isEmpty || value=="") {
                        return 'Pole nie może być puste';
                      }
                      else if(double.tryParse(value) == null){
                        return 'Niepoprawny format liczby';
                      }
                      else if(biggerThantZeroValidation && double.tryParse(value)<=0){
                        return 'Wartość musi być większa od 0';
                      }
                      return null;
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 15.0),
                        labelText: labelText ?? "",
                        suffix: Container(
                            width: 40,
                            child: Text(suffixText ?? stat.unit)),
                        prefix: Container(
                            child: Text(prefixText ?? "${stat?.symbol ?? ""}")),
                        border: OutlineInputBorder()
                    ),
                    controller: controller ?? statValueChangeTextController[stat.symbol],
                    enabled: enabled ?? !isMacroRunning,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget fetchDataCard() {
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
                  Text("Pobieranie wartości", style: textTheme.headline6),
                  Container(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Radio(groupValue: fetchDataType,
                                  value: FetchDataType.manual,
                                  onChanged: (x){
                                    setState(() {
                                      fetchDataType = FetchDataType.manual;
                                      _fetchDataIntervalFormKey.currentState.reset();
                                    });
                                  }),
                              Expanded(child: Text("Pobieraj dane po przyciśnięciu przycisku"))
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Radio(groupValue: fetchDataType,
                                  value: FetchDataType.periodically,
                                  onChanged: (x){
                                    setState(() {
                                      fetchDataType = FetchDataType.periodically;
                                      _fetchDataIntervalFormKey.currentState.reset();
                                    });
                                  }),
                              Expanded(child: Row(
                                children: [
                                  Expanded(child: Text("Pobieraj dane cyklicznie")),
                                  Expanded(
                                    child: Form(
                                        key: _fetchDataIntervalFormKey,
                                        child: customTextField(
                                            showButton: false,
                                            suffixText: "s",
                                            labelText: "Interwał",
                                            biggerThantZeroValidation: true,
                                            controller: fetchDataIntervalController,
                                            enableNegative: false)
                                    ),
                                  )
                                ],
                              ))
                            ],
                          ),
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
                            onPressed: (fetchDataType == FetchDataType.manual)
                                ? () {
                                    _stopFetchingData();
                                    fetchData();
                                  }
                                : !_fetchDataIntervalFormKey.currentState.validate()
                                    ? null
                                    : () {
                                        if (!isFetchingPeriodically)
                                          _startFetchingData();
                                        else
                                          _stopFetchingData();
                                      },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${fetchDataType == FetchDataType.manual ? "Odczyt"
                                      : !isFetchingPeriodically ? "Rozpocznij automatyczne pobieranie" : "Zatrzymaj automatyczne pobieranie"}".toUpperCase(),
                                  style: textTheme.bodyText1.copyWith(color: !isFetchingPeriodically ? Colors.black : Colors.red)),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(color: !isFetchingPeriodically ? Colors.black : Colors.red)),
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

  Widget engineStateCard() {
    return ExpandableCard(
        title: "Stan silnika: ${engineState == EngineState.idle ? "Jałowy" : "Obciążenia"}",
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Radio(
                            groupValue: engineState,
                            value: EngineState.idle,
                            onChanged: (x) {
                              if (engineState != EngineState.idle)
                                DialogUtils.showYesNoDialog(context,
                                    "Zmienić stan silnika na: \nStan jałowy",
                                    yesFunction: () {
                                  setState(() {
                                    engineState = x;
                                  });
                                });
                            }),
                        Flexible(child: Text("Stan jałowy"))
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Radio(
                            groupValue: engineState,
                            value: EngineState.load,
                            onChanged: (x) {
                              if (engineState != EngineState.load)
                                DialogUtils.showYesNoDialog(context,
                                    "Zmienić stan silnika na: \nStan obciążenia",
                                    yesFunction: () {
                                  setState(() {
                                    engineState = x;
                                  });
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
        ));
  }

  Widget codingChooseCard() {
    return ExpandableCard(
        title: "Algorytm",
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: FlatButton(
                      onPressed: (){},
                      child: DropdownButton(
                        value: code,
                        underline: Container(),
                        isExpanded: true,
                        items: algorithms.entries.map((e){
                          return DropdownMenuItem(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: new Text(e.value, textAlign: TextAlign.center,
                                        style: textTheme.subtitle1),
                                  ),
                                  Flexible(
                                    child: new Text("(${e.key})", textAlign: TextAlign.center,
                                        style: textTheme.caption),
                                  )
                                ],
                              ),
                            ),
                            value: e.key,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            if (value != code) {
                              code = value;
                              ToastUtils.showToast("Wybrano algorytm: $code");
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget changeValuesCard() {
    return Opacity(
        opacity: !isMacroRunning ? 1 : 0.2,
      child: ExpandableCard(
        title: "Zmień wartość",
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Form(
                  key: _changeValuesCardKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: customTextField(stat: Lists.getStatValue("f"), labelText: Lists.getStatValue("f").desc)
                          ),
                          Checkbox(
                              value: statValueChangeTextCheckBox["f"],
                              onChanged: (x) {
                                setState(() {
                                  statValueChangeTextCheckBox["f"] = !statValueChangeTextCheckBox["f"];
                                });
                              }
                          )
                        ],
                      ),
                      if(isLoadEngineState())
                      Row(
                        children: [
                          Expanded(
                              child: customTextField(stat: Lists.getStatValue("T"), labelText: Lists.getStatValue("T").desc)
                          ),
                          Checkbox(
                              value: statValueChangeTextCheckBox["T"],
                              onChanged: (x) {
                                setState(() {
                                  statValueChangeTextCheckBox["T"] = !statValueChangeTextCheckBox["T"];
                                });
                              }
                          )
                        ],
                      )
                    ],
                  )
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: FlatButton(
                        onPressed: isMacroRunning || (statValueChangeTextCheckBox.values.every((x) => !x) || (isIdleEngineState() ? chosenTask.idleReadings.isEmpty : chosenTask.loadReadings.isEmpty))
                            ? null
                            : () {
                          if (_changeValuesCardKey.currentState.validate())
                            setState(() {
                              if(statValueChangeTextCheckBox["f"]){
                                switch(engineState){
                                  case EngineState.load:
                                    chosenTask.loadReadings.last.reading.powerFrequency = double.parse(statValueChangeTextController["f"].value.text);
                                    break;
                                  case EngineState.idle:
                                    chosenTask.idleReadings.last.reading.powerFrequency = double.parse(statValueChangeTextController["f"].value.text);
                                    break;
                                }
                              }
                              if(statValueChangeTextCheckBox["T"] && isLoadEngineState()){
                                chosenTask.loadReadings.last.torque = double.parse(statValueChangeTextController["T"].value.text);
                              }
                            });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Zatwierdź".toUpperCase(),
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
    );
  }

  Widget changeValuesPeriodicallyCard() {

    Widget customTextFieldMacro({StatValue stat, String controller,
      bool enabled, String suffixText, String prefixText}) {

      Widget textField(String label, int index){
        return TextFormField(
          maxLines: 1,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9-.]')),],
          validator: (value) {
            if (value.isEmpty || value=="") {
              return 'Pole nie może być puste';
            }
            else if(double.tryParse(value) ==null){
              return 'Niepoprawny format liczby';
            }
            else if(double.tryParse(value) == 0){
              return 'Wartość != 0';
            }
            return null;
          },
          decoration: InputDecoration(
              suffixText: suffixText ?? stat.unit,
              prefixText: prefixText ?? "${stat.symbol}",
              labelText: label,
              border: OutlineInputBorder()
          ),
          controller: macroChangeControllerValue[stat.symbol][index],
          enabled: enabled ?? !isMacroRunning,
          onChanged: (s){
            if (s != null && s != "" && double.tryParse(s) != null)
              setState(() {});
          },
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(child: textField("Od", 0)),
                  SizedBox(width: 10),
                  Expanded(child: textField("Krok (+/-)", 1)),
                  SizedBox(width: 10),
                  Expanded(child: textField("Do", 2)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ExpandableCard(
      title: "Zmieniaj wartość cyklicznie (makro)",
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Form(
                key: _macroTimeKey,
                child: customTextField(
                    showButton: false,
                    suffixText: "s",
                    labelText: "Częstotliwość makra",
                    biggerThantZeroValidation: true,
                    controller: macroChangeControllerTime,
                    enableNegative: false)
            ),
            Divider(color: Colors.black, thickness: 0.2, height: 20),
            Form(
              key: _macroValueFormKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: customTextFieldMacro(stat: Lists.getStatValue("f"))
                      ),
                      Checkbox(
                          value: macroChangeTextCheckBox["f"],
                          onChanged: (x) {
                            setState(() {
                              macroChangeTextCheckBox["f"] = !macroChangeTextCheckBox["f"];
                            });
                          }
                      )
                    ],
                  ),
                  if(isLoadEngineState())
                    Row(
                      children: [
                        Expanded(
                            child: customTextFieldMacro(stat: Lists.getStatValue("T"))
                        ),
                        Checkbox(
                            value: macroChangeTextCheckBox["T"],
                            onChanged: (x) {
                              setState(() {
                                macroChangeTextCheckBox["T"] = !macroChangeTextCheckBox["T"];
                              });
                            }
                        )
                      ],
                    )
                ],
              )
            ),
            Divider(color: Colors.black, thickness: 0.2, height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: Duration(seconds: _timer?.tick ?? 0).toString().split('.').first.padLeft(8, "0")),
                    readOnly: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Czas wykonywania makra (HH:mm:ss)"
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: new TextField(
                    controller: TextEditingController(text: macrosDone?.toString() ?? 0),
                    readOnly: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Liczba wykonań makra"
                    ),
                  ),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          if(_macroTimeKey.currentState.validate() && _macroValueFormKey.currentState.validate()
                              && !macroChangeTextCheckBox.values.every((x)=>!x)) {
                            isMacroRunning = !isMacroRunning;
                            if (isMacroRunning)
                              _startMacro();
                            else
                              _stopMacro();
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("${!isMacroRunning ? "Uruchom makro" : "Zatrzymaj makro"}".toUpperCase(),
                            style: textTheme.bodyText1.copyWith(color: !isMacroRunning ? Colors.black : Colors.red)),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: !isMacroRunning ? Colors.black : Colors.red)
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget labAndTaskDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SelectableText("Laboratorium: ", style: textTheme.subtitle1),
                      Expanded(child: SelectableText(lab.name, style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold)))
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SelectableText("Zadanie: ", style: textTheme.subtitle1),
                                Expanded(
                                  child: Row(
                                    children: [
                                      tasks == null || tasks.isEmpty  ?  Container() :  Expanded(
                                        child: FlatButton(
                                          onPressed: (){},
                                          child: DropdownButton<Task>(
                                            value: chosenTask,
                                            underline: Container(),
                                            isExpanded: true,
                                            items: tasks.map((e){
                                              return DropdownMenuItem(
                                                child: Text(e.name, style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold)),
                                                value: e,
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                if (value.id != chosenTask.id) {
                                                  chosenTask = value;
                                                  ToastUtils.showToast("Wybrane ćwiczenie: ${chosenTask.name}");
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                          margin: EdgeInsets.all(8),
                                          child: IconButton(
                                              icon: Icon(Icons.add_circle),
                                              onPressed: (){
                                                _showAddTaskDialog();
                                              },
                                              tooltip: "Dodaj nowe ćwiczenie")
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  children: [
                    Row(
                      children: [
                        SelectableText("Czas trwania", style: textTheme.caption),
                      ],
                    ),
                    Row(
                      children: [
                        SelectableText(Duration(seconds: _labDuration.tick).toString().split('.').first.padLeft(8, "0"), style: textTheme.subtitle1),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;
    return SilnikScaffold.get(
        context,
        appBar: SilnikScaffold.appBar(context, actions: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width/4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new SelectableText("Data rozpoczęcia", style: textTheme.subtitle2.copyWith(color: Colors.white)),
                  new SelectableText(DateUtils.formatDateTime(context, lab.date), style: textTheme.subtitle1.copyWith(color: Colors.white))
                ],
              ),
            ),
          ),
        ]),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                labAndTaskDetailsCard(),
                chosenTask == null
                    ? EmptyView(
                        message: "Nie wczytano zadania",
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(children: [
                            engineStateCard(),
                            Container(
                              child: Column(
                                children: [
                                  statValue(Lists.getStatValue("U"), (isIdleEngineState()
                                      ? chosenTask.idleReadings.isEmpty ? null : chosenTask?.idleReadings?.last?.reading?.voltage
                                      : chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.reading?.voltage)),
                                  statValue(Lists.getStatValue("f"), (isIdleEngineState()
                                      ? chosenTask.idleReadings.isEmpty ? null : chosenTask?.idleReadings?.last?.reading?.powerFrequency
                                      : chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.reading?.powerFrequency)),
                                  statValue(Lists.getStatValue("n"), (isIdleEngineState()
                                      ? chosenTask.idleReadings.isEmpty ? null : chosenTask?.idleReadings?.last?.reading?.rotationalSpeed
                                      : chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.reading?.rotationalSpeed)),
                                  statValue(Lists.getStatValue("P"), (isIdleEngineState()
                                      ? chosenTask.idleReadings.isEmpty ? null : chosenTask?.idleReadings?.last?.reading?.power
                                      : chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.reading?.power)),
                                  statValue(Lists.getStatValue("Is"), (isIdleEngineState()
                                      ? chosenTask.idleReadings.isEmpty ? null : chosenTask?.idleReadings?.last?.reading?.statorCurrent
                                      : chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.reading?.statorCurrent)),
                                  statValue(Lists.getStatValue("Iw"), (isIdleEngineState()
                                      ? chosenTask.idleReadings.isEmpty ? null : chosenTask?.idleReadings?.last?.reading?.rotorCurrent
                                      : chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.reading?.rotorCurrent)),
                                  if(isLoadEngineState())
                                    statValue(Lists.getStatValue("T"), chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.torque)
                                ],
                              ),
                            ),
                          ])),
                          Expanded(
                            child: Column(children: [
                              codingChooseCard(),
                              changeValuesCard(),
                              changeValuesPeriodicallyCard(),
                              fetchDataCard()
                            ]),
                          )
                        ],
                      ),
              ],
            )));
  }

  TextEditingController labNameController;
  _showAddTaskDialog() async {

    _showDialogLoadCreatedTask() async {
      DialogUtils.showYesNoDialog(
          context, "Wczytać dodane ćwiczenie?",
          yesFunction: () {
            chosenTask = tasks.last;
            _stopMacro();
            _stopFetchingData();
            ToastUtils.showToast("Wybrane ćwiczenie: ${chosenTask.name}");
      });
    }

    labNameController = TextEditingController(text: "Nowe ćwiczenie".toString());
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: TextFormField(
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  autofocus: false,
                  decoration: InputDecoration(
                      labelText: "Podaj tytuł nowego ćwiczenia" ?? "",
                      border: OutlineInputBorder()),
                  controller: labNameController,
                )
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: Row(
                  children: [
                    Icon(Icons.clear, color: Colors.red),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Anuluj".toUpperCase(), style: textTheme.button.copyWith(color: Colors.red)),
                    )
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                }),
            new FlatButton(
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.black),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Utwórz".toUpperCase(), style: textTheme.button.copyWith(color: Colors.black)),
                    )
                  ],
                ),
                onPressed: labNameController.value.text!="" ? () {
                  Navigator.pop(context, true);
                  } : null)
          ],
        );
      }
    ).then((value){
      if(value!=null && value) {
        List<IdleReading> idleReadings = new List();
        List<LoadReading> loadReadings = new List();
        tasks.add(Task(tasks.length + 1, labNameController.value.text,
            idleReadings, loadReadings, lab));
        labNameController.clear();
        if (tasks.length == 1) {
          chosenTask = tasks.first;
          ToastUtils.showToast("Wybrane ćwiczenie: ${chosenTask.name}");
          print("sadsadsadasdsa ${chosenTask.toString()}");
        }
        else _showDialogLoadCreatedTask();
      }
    });
  }
}

enum ChangeValueType {offset, fixed}
enum FetchDataType {manual, periodically}
enum EngineState {load, idle}