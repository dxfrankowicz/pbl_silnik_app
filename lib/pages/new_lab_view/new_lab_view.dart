import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_chartjs/chartjs.models.dart';
import 'package:flutter_web_chartjs/chartjs.wrapper.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:silnik_app/api/api_client.dart';
import 'package:silnik_app/api/models/lab.dart';
import 'package:silnik_app/api/models/task.dart';
import 'package:silnik_app/components/create_task_dialog.dart';
import 'package:silnik_app/components/data_table.dart';
import 'package:silnik_app/components/empty_view.dart';
import 'package:silnik_app/components/expandable_card.dart';
import 'package:silnik_app/components/stat_value_card.dart';
import 'package:silnik_app/pages/base_scaffold.dart';
import 'package:silnik_app/utils/consts.dart';
import 'package:silnik_app/utils/date_utils.dart';
import 'package:silnik_app/utils/dialog_utils.dart';
import 'package:silnik_app/utils/toast_utils.dart';
import '../../api/models/stat_value.dart';
import '../../lists.dart';

class NewLabView extends StatefulWidget {
  final Lab lab;
  NewLabView(this.lab, {Key key}) : super(key: key);

  @override
  _NewLabViewState createState() => _NewLabViewState(lab);
}

class _NewLabViewState extends State<NewLabView> {

  Lab lab;

  String selectedYAxis = "U";
  List<double> yAxisData = new List();

  int _currentSliderValue = 50;

  _NewLabViewState(this.lab);

  TextTheme textTheme;
  bool isMacroRunning = false;

  //macro controller
  Map<String, double> macroCurrentValues = {
    "T" : 0.0,
    "f" : 0.0,
  };

  Map<String, TextEditingController> statValueChangeTextController = new Map();
  Map<String, bool> statValueChangeTextCheckBox = new Map();

  FetchDataType fetchDataType = FetchDataType.manual;

  final _changeValuesCardKey = GlobalKey<FormState>();

  //fetch data type
  TextEditingController fetchDataIntervalController = TextEditingController(text: 1.toString());
  final _fetchDataIntervalFormKey = GlobalKey<FormState>();

  Timer _labDuration;
  bool addNewTaskTextField = true;

  //tasks
  Task chosenTask;
  bool currentTaskEnded = true;

  //engine
  EngineState engineState = EngineState.idle;

  //algorithms
  Map<String,String> algorithms = Const.algorithms;
  String code;

  //macro
  final _macroTimeKey = GlobalKey<FormState>();
  final _macroValueFormKey = GlobalKey<FormState>();
  TextEditingController macroChangeControllerTime = TextEditingController();
  Map<String, List<TextEditingController>> macroChangeControllerValue = new Map();
  Map<String, List<TextEditingController>> macroChangeControllerSubLoopValue = new Map();
  Map<String, bool> macroChangeTextCheckBox = new Map();
  bool addSubLoop = false;
  Timer _timer;
  int macrosDone = 0;
  int macrosTime = 0;
  TextEditingController macroSubLoopChangeControllerTime = TextEditingController();
  String subLoopStatFrequency = "T";
  final _macroTimeSubLoopKey = GlobalKey<FormState>();

  Logger logger = new Logger("LAB");

  @override
  void dispose() {
    _timer?.cancel();
    _fetchTimer?.cancel();
    _subLoopTimer?.cancel();
    _labDuration?.cancel();
    super.dispose();
  }

  void updateLab() async {
    print("LAB $lab");
    ApiClient().updateLab(lab);
  }

  @override
  void initState() {
    code = algorithms.keys.first;
    lab.tasks = [];

    Lists.statsList.forEach((element) {
      statValueChangeTextController[element.symbol] = TextEditingController();
      statValueChangeTextController[element.symbol].text = 0.toString();

      //macro values: from, step, to
      macroChangeControllerValue[element.symbol] = [TextEditingController(), TextEditingController(), TextEditingController()];
      macroChangeControllerValue[element.symbol].forEach((e) {
        e.text = 0.toString();
      });

      macroChangeControllerSubLoopValue[element.symbol] = [TextEditingController(), TextEditingController(), TextEditingController()];
      macroChangeControllerSubLoopValue[element.symbol].forEach((e) {
        e.text = 0.toString();
      });

      statValueChangeTextCheckBox[element.symbol] = false;
      macroChangeTextCheckBox[element.symbol] = false;
    });
    macroChangeControllerTime.text = 10.toString();
    macroSubLoopChangeControllerTime.text=10.toString();

    super.initState();

    if(lab.tasks!=null && lab.tasks.isNotEmpty)
      chosenTask = lab.tasks.first;
    else
      addNewTaskTextField = lab.tasks.isEmpty;

    _labDuration = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {});
    });
  }

  bool isIdleEngineState() => engineState==EngineState.idle;
  bool isLoadEngineState() => engineState==EngineState.load;

  Timer _macroDuration;
  void _startMacro() {
    macrosDone = 0;
    _macroDuration = new Timer.periodic(Duration(milliseconds: 1), (t) { });
    if(addSubLoop && isLoadEngineState()){
      startSubLoop();
    }
    else {
          switch(engineState){
      case EngineState.load:
        if(macroChangeTextCheckBox["f"]) {
          ApiClient().setValue(
            engineState: EngineState.load,
            value: {"f" : double.parse(macroChangeControllerValue["f"][0].text)}).then((v){
          if(v) {
            ToastUtils.showToast("Ustawiono f = ${double.parse(macroChangeControllerValue["f"][0].text)}");
            setState(() {
              macroCurrentValues["f"] = double.parse(macroChangeControllerValue["f"][0].text);
            });
          }
          else
            ToastUtils.showToast("Nie ustawiono f = ${double.parse(macroChangeControllerValue["f"][0].text)}");
          setState(() {

          });
        });
        }
        else if(macroChangeTextCheckBox["T"])
          ApiClient().setValue(
            engineState: EngineState.load,
            value: {"T": double.parse(macroChangeControllerValue["T"][0].text)}).then((v){
            if(v) {
              ToastUtils.showToast("Ustawiono T = ${double.parse(
                  macroChangeControllerValue["T"][0].text)}");
              setState(() {
                macroCurrentValues["T"] = double.parse(macroChangeControllerValue["T"][0].text);
              });
            }
            else
              ToastUtils.showToast("Nie ustawiono T = ${double.parse(macroChangeControllerValue["T"][0].text)}");
            setState(() {

            });
        });
        break;
      case EngineState.idle:
        ApiClient().setValue(
          engineState: EngineState.idle,
          value: {"f" : double.parse(macroChangeControllerValue["f"][0].text)}).then((v){
          if(v) {
            ToastUtils.showToast("Ustawiono f = ${double.parse(
                macroChangeControllerValue["f"][0].text)}");
            setState(() {
              macroCurrentValues["f"] = double.parse(macroChangeControllerValue["f"][0].text);
            });
          }
          else
            ToastUtils.showToast("Nie ustawiono f = ${double.parse(macroChangeControllerValue["f"][0].text)}");
          setState(() {

          });
        });
        break;
    }
      _timer = Timer.periodic(Duration(milliseconds: int.parse(macroChangeControllerTime.text)), (t) {
        setState(() {
          changeData();
        });
      });
    }
    isMacroRunning = true;
  }

  Timer _subLoopTimer;
  void startSubLoop() {
    macroCurrentValues["T"] = double.parse(macroChangeControllerSubLoopValue["T"][0].text);
    macroCurrentValues["f"] = macrosDone==0
        ? double.parse(macroChangeControllerValue["f"][0].text)
        : (macroCurrentValues["f"] + double.parse(macroChangeControllerValue["f"][1].text) >= double.parse(macroChangeControllerValue["f"][2].text))
        ? double.parse(macroChangeControllerValue["f"][2].text)
        : macroCurrentValues["f"] + double.parse(macroChangeControllerValue["f"][1].text);

      ApiClient().setValue(
                engineState: engineState,
                value: {
                  "T" : macroCurrentValues["T"],
                  "f" : macroCurrentValues["f"],
                }).then((value){
        if(value){
          ToastUtils.showToast(
              "Wykonano podrzędną pętlę makra T = ${macroCurrentValues["T"]} "
                  "dla f = ${macroCurrentValues["f"]}");
        }
        else{
          ToastUtils.showToast(
              "Nie wykonano podrzędnek pętli makra T = ${macroCurrentValues["T"]} "
                  "dla f = ${macroCurrentValues["f"]}");
        }
        setState(() {

        });
              });
    _subLoopTimer = Timer.periodic(Duration(milliseconds: int.parse(macroSubLoopChangeControllerTime.text)), (t1) {
        setState(() {
          if ((macroCurrentValues["T"] + double.parse(macroChangeControllerSubLoopValue["T"][1].text))
              > double.parse(macroChangeControllerSubLoopValue["T"][2].text))
            ApiClient().setValue(
              engineState: engineState,
              value: {
                "T" : double.parse(macroChangeControllerSubLoopValue["T"][2].text),
                "f": macroCurrentValues["f"]
                }).then((value) {
              if (value) {
                ToastUtils.showToast(
                    "Wykonano podrzędną pętlę makra T = ${macroCurrentValues["T"]} "
                    "dla f = ${macroCurrentValues["f"]}");
              } else {
                ToastUtils.showToast(
                    "Nie wykonano podrzędnek pętli makra T = ${macroCurrentValues["T"]} "
                    "dla f = ${macroCurrentValues["f"]}");
              }
              setState(() {});
            });
          else {
            macroCurrentValues["T"] += double.parse(macroChangeControllerSubLoopValue["T"][1].text);
            ApiClient().setValue(
                engineState: engineState,
                value: {
                  "T": macroCurrentValues["T"],
                  "f": macroCurrentValues["f"]
                }).then((value) {
              if (value) {
                ToastUtils.showToast(
                    "Wykonano podrzędną pętlę makra T = ${macroCurrentValues["T"]} ""dla f = ${macroCurrentValues["f"]}");
              }
              else {
                ToastUtils.showToast(
                    "Nie wykonano podrzędnek pętli makra T = ${macroCurrentValues["T"]} ""dla f = ${macroCurrentValues["f"]}");
              }
              setState(() {

              });
            });
          }
          if (macroCurrentValues["T"] >= double.parse(macroChangeControllerSubLoopValue["T"][2].text)) {
            _subLoopTimer.cancel();
            macrosDone+=1;
            if (macroCurrentValues["T"] >= double.parse(macroChangeControllerValue["f"][2].text))
                _stopMacro();
            else
              Future.delayed(Duration(seconds: int.parse(macroChangeControllerTime.text)), () {
                startSubLoop();
            });
          }
        });
    });
  }

  void _stopMacro() {
    _timer?.cancel();
    _macroDuration?.cancel();
    isMacroRunning = false;
  }

  void changeData() {
    switch (engineState) {
      case EngineState.load:
        if (macroChangeTextCheckBox["f"]) {
          macrosDone += 1;
          if (macroChangeControllerValue["f"].every((x) => x != null) && macroChangeControllerValue["f"].every((x) => x.value.text != ""))
            setState(() {
              if ((macroCurrentValues["f"] + double.parse(macroChangeControllerValue["f"][1].text)) > double.parse(macroChangeControllerValue["f"][2].value.text)){
                    ApiClient().setValue(
                      engineState: EngineState.load,
                      value: {"f" : double.parse(macroChangeControllerValue["f"][2].text)}).then((v){
                      if(v)
                        ToastUtils.showToast("Wykonano makro, ustawiono f = ${double.parse(macroChangeControllerValue["f"][2].text)}");
                      else
                        ToastUtils.showToast("Nie wykonano makro, nie ustawiono f = ${double.parse(macroChangeControllerValue["f"][2].text)}");;
                      });
                  }
              else{
                macroCurrentValues["f"]+=double.parse(macroChangeControllerValue["f"][1].text);
                ApiClient().setValue(
                  engineState: EngineState.load,
                  value: {"f" : macroCurrentValues["f"]}).then((v){
                  if(v)
                    ToastUtils.showToast("Wykonano makro, ustawiono f = ${macroCurrentValues["f"]}");
                  else
                    ToastUtils.showToast("Nie wykonano makro, nie ustawiono f = ${macroCurrentValues["f"]}");
                  });
              }
              if (macroCurrentValues["f"] >= double.parse(macroChangeControllerValue["f"][2].value.text))
                _stopMacro();
            });

        } else if(macroChangeTextCheckBox["T"]) {
            macrosDone += 1;
            if (macroChangeControllerValue["T"].every((x) => x != null) && macroChangeControllerValue["T"].every((x) => x.value.text != ""))
              setState(() {
                if ((macroCurrentValues["T"] + double.parse(macroChangeControllerValue["T"][1].text)) > double.parse(macroChangeControllerValue["T"][2].value.text))
                  ApiClient().setValue(
                      engineState: EngineState.load,
                      value: {"T" : double.parse(macroChangeControllerValue["T"][2].text)}).then((v){
                    if(v)
                      ToastUtils.showToast("Wykonano makro, ustawiono T = ${macroCurrentValues["T"]}");
                    else
                      ToastUtils.showToast("Nie wykonano makro, nie ustawiono T = ${macroCurrentValues["T"]}");
                      });
                else {
                  macroCurrentValues["T"]+=double.parse(macroChangeControllerValue["T"][1].text);
                  ApiClient().setValue(
                      engineState: EngineState.load,
                      value: {"T": macroCurrentValues["T"]}).then((v) {
                    if(v)
                      ToastUtils.showToast("Wykonano makro, ustawiono T = ${macroCurrentValues["T"]}");
                    else
                      ToastUtils.showToast("Nie wykonano makro, nie ustawiono T = ${macroCurrentValues["T"]}");
                  });
                }
                if (macroCurrentValues["T"] >= double.parse(macroChangeControllerValue["T"][2].value.text))
                  _stopMacro();
              });
        }
        break;
      case EngineState.idle:
          macrosDone += 1;
          print("last value 1 = ${macroCurrentValues["f"]}");
          if (macroChangeControllerValue["f"].every((x) => x != null) && macroChangeControllerValue["f"].every((x) => x.value.text != ""))
              if ((macroCurrentValues["f"] + double.parse(macroChangeControllerValue["f"][1].text)) > double.parse(macroChangeControllerValue["f"][2].value.text)) {
                ApiClient().setValue(
                    engineState: EngineState.idle,
                    value: {
                      "f": double.parse(macroChangeControllerValue["f"][2].text)
                    }).then((v) {
                  if(v)
                    ToastUtils.showToast("Wykonano makro, ustawiono f = ${macroCurrentValues["f"]}");
                  else
                    ToastUtils.showToast("Nie wykonano makro, nie ustawiono f = ${macroCurrentValues["f"]}");
                });
              }
              else {
                macroCurrentValues["f"] =  macroCurrentValues["f"] + double.parse(macroChangeControllerValue["f"][1].text);
                ApiClient().setValue(
                      engineState: EngineState.idle,
                      value: {"f" : macroCurrentValues["f"]}).then((v){
                  if(v)
                    ToastUtils.showToast("Wykonano makro, ustawiono f = ${macroCurrentValues["f"]}");
                  else
                    ToastUtils.showToast("Nie wykonano makro, nie ustawiono f = ${macroCurrentValues["f"]}");
                      });
              }
              if (macroCurrentValues["f"] >= double.parse(macroChangeControllerValue["f"][2].value.text))
                _stopMacro();
        break;
    }
  }

  //Pobieranie danych
  Timer _fetchTimer;
  bool isFetchingPeriodically = false;
  
  void _startFetchingData() {
    _fetchTimer = Timer.periodic(Duration(milliseconds: int.parse(fetchDataIntervalController.text)), (t) {
      setState(() {
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
    ApiClient().fetchData(engineState: engineState, chosenTask: chosenTask).then((value){
      setState(() {
        switch (engineState) {
          case EngineState.load:
            chosenTask.loadReadings.add(value);
            break;
          case EngineState.idle:
            chosenTask.idleReadings.add(value);
            break;
        }
        ToastUtils.showToast("Pobrano dane");
      });
    });
  }
  //Koniec sekcji pobierania danych

  Widget statValue(StatValue stat, double value) => StatCard(stat: stat, value: value);

  Widget customTextField({StatValue stat, TextEditingController controller,
    bool enabled, String suffixText, String prefixText, String labelText,
    bool showButton = true, bool enableNegative = true,
    bool biggerThantZeroValidation = false, double value}) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
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
                                            suffixText: "ms",
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
        title: "Stan silnika: ${engineState == EngineState.idle ? "Jałowy".toUpperCase() : "Obciążenia".toUpperCase()}",
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

  Widget algorithmChooseCard() {
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
                        onPressed: isMacroRunning || (statValueChangeTextCheckBox.values.every((x) => !x))
                            ? null
                            : () {
                          if (_changeValuesCardKey.currentState.validate())
                            setState(() {
                              if(statValueChangeTextCheckBox["f"]){
                                 ApiClient().setValue(
                                      engineState: engineState,
                                      value: {"f" : double.parse(statValueChangeTextController["f"].value.text)}
                                    ).then((value){
                                      if(value){
                                        ToastUtils.showToast("Zmieniono wartość częstotliwości na: ${double.parse(statValueChangeTextController["f"].value.text)}");
                                      }
                                      else{
                                        ToastUtils.showToast("Nie zmieniono wartość częstotliwości na: ${double.parse(statValueChangeTextController["f"].value.text)}");
                                      }
                                      setState(() {});
                                    });
                              }
                              if(statValueChangeTextCheckBox["T"] && isLoadEngineState()){
                                ApiClient().setValue(
                                      engineState: engineState,
                                      value: {"T" : double.parse(statValueChangeTextController["T"].value.text)}
                                    ).then((value){
                                  if (value) {
                                          ToastUtils.showToast("Zmieniono wartość momentu na: ${double.parse(statValueChangeTextController["T"].value.text)}");
                                        } else {
                                          ToastUtils.showToast("Nie zmieniono wartość momentu na: ${double.parse(statValueChangeTextController["T"].value.text)}");
                                        }
                                        setState(() {});
                                      });
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
            if(isLoadEngineState() && !macroChangeTextCheckBox[stat.symbol])
              return null;
            else if (value.isEmpty || value=="") {
              return 'Pole nie może być puste';
            }
            else if(double.tryParse(value) ==null){
              return 'Niepoprawny format liczby';
            }
            else if(double.tryParse(value) == 0 && index>0){
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

    Widget customTextFieldSubLoopMacro({StatValue stat, String controller,
      bool enabled, String suffixText, String prefixText}) {

      Widget textField(String label, int index){
        return TextFormField(
          maxLines: 1,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9-.]')),],
          validator: (value) {
            if(isLoadEngineState() && !macroChangeTextCheckBox[stat.symbol])
              return null;
            else if (value.isEmpty || value=="") {
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
          controller: macroChangeControllerSubLoopValue[stat.symbol][index],
          enabled: enabled ?? !isMacroRunning,
          onChanged: (s){
            if (s != null && s != "" && double.tryParse(s) != null)
              setState(() {});
          },
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(Icons.subdirectory_arrow_right),
              ],
            ),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: new Column(
                    children: [
                      Form(
                          key: _macroTimeSubLoopKey,
                          child: customTextField(
                              showButton: false,
                              suffixText: "ms",
                              labelText: "Częstotliwość podrzędnej pętli",
                              biggerThantZeroValidation: true,
                              controller: macroSubLoopChangeControllerTime,
                              enableNegative: false)
                      ),
                      Row(
                        children: [
                          Expanded(child: textField("Od", 0)),
                          SizedBox(width: 10),
                          Expanded(child: textField("Krok (+/-)", 1)),
                          SizedBox(width: 10),
                          Expanded(child: textField("Do", 2)),
                        ],
                      )
                    ],
                  ),
                ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Form(
                  key: _macroTimeKey,
                  child: customTextField(
                      showButton: false,
                      suffixText: "ms",
                      labelText: "Częstotliwość makra",
                      biggerThantZeroValidation: true,
                      controller: macroChangeControllerTime,
                      enableNegative: false)
              ),
            ),
            Divider(color: Colors.black, thickness: 0.2, height: 20),
            Form(
              key: _macroValueFormKey,
              child: Column(
                children: [
                  AbsorbPointer(
                    absorbing: macroChangeTextCheckBox["T"],
                    child: Opacity(
                      opacity: macroChangeTextCheckBox["T"] ? 0.2 : 1,
                      child: Row(
                        children: [
                          Expanded(
                              child: customTextFieldMacro(stat: Lists.getStatValue("f"))
                          ),
                          Column(
                            children: [
                              Checkbox(
                                  value: macroChangeTextCheckBox["f"],
                                  onChanged: (x) {
                                    setState(() {
                                      macroChangeTextCheckBox["f"] = !macroChangeTextCheckBox["f"];
                                    });
                                  }
                              ),
                              if(isLoadEngineState())
                              IconButton(
                                icon: Icon(!addSubLoop ? Icons.arrow_circle_down : Icons.arrow_circle_up, color: Colors.blue),
                                tooltip: !addSubLoop ? "Dodaj pętlę podrzędną" : "Usuń pętlę podrzędną",
                                onPressed: (){
                                  setState(() {
                                    addSubLoop=!addSubLoop;
                                  });
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  addSubLoop ? customTextFieldSubLoopMacro(stat: Lists.getStatValue("T")) : Container(),
                  if(isLoadEngineState())
                    AbsorbPointer(
                      absorbing: macroChangeTextCheckBox["f"],
                      child: Opacity(
                        opacity: macroChangeTextCheckBox["f"] ? 0.2 : 1,
                        child: Row(
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
                        ),
                      ),
                    )
                ],
              )
            ),
            Divider(color: Colors.black, thickness: 0.2, height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: Duration(milliseconds: _macroDuration?.tick ?? 0).toString().split('.')[0]),
                    readOnly: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Czas wykonywania makra"
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
                      Expanded(child: SelectableText(utf8.decode(lab.name.codeUnits), style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold)))
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
                                      lab.tasks == null || lab.tasks.isEmpty  ?  Container() :  Expanded(
                                        child: FlatButton(
                                          onPressed: (){},
                                          child: DropdownButton<Task>(
                                            value: chosenTask,
                                            underline: Container(),
                                            isExpanded: true,
                                            items: lab.tasks.map((e){
                                              return DropdownMenuItem(
                                                child: e.hasEnded ? Column(
                                                  children: [
                                                    Text(utf8.decode(e.name.codeUnits), style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold)),
                                                    Text("Zakończone", style: textTheme.caption.copyWith(fontStyle: FontStyle.italic, color: Colors.redAccent))
                                                  ],
                                                ) : Text(utf8.decode(e.name.codeUnits), style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold)),
                                                value: e,
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                if (!chosenTask.hasEnded) {
                                                        ToastUtils.showToast(
                                                            "Aby przełączyć zadanie należy zakończyć obecnie trawjące",
                                                            textColor: Colors.redAccent);
                                                      } else{
                                                  if (chosenTask==null || value.id != chosenTask.id) {
                                                    chosenTask = value;
                                                    ToastUtils.showToast("Wybrane ćwiczenie: ${utf8.decode(chosenTask.name.codeUnits)} ${chosenTask.hasEnded}");
                                                    setState(() {
                                                      //currentTaskEnded = false;
                                                    });
                                                  }
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                          margin: EdgeInsets.all(8),
                                          child: IconButton(
                                              icon: Icon(Icons.add_circle, color: Colors.green),
                                              onPressed: (){
                                                _showEndTaskDialog(addTaskAfter: !currentTaskEnded);
                                              },
                                              tooltip: "Dodaj nowe ćwiczenie")
                                      ),
                                      lab.tasks.length == 0 || chosenTask==null ||  currentTaskEnded ? Container() : Container(
                                          margin: EdgeInsets.all(8),
                                          child: IconButton(
                                              icon: Icon(Icons.cancel, color: Colors.redAccent),
                                              onPressed: (){
                                                _showEndTaskDialog();
                                              },
                                              tooltip: "Zakończ ćwiczenie")
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

  Widget historicalDataTableCard(){
    return CustomPaginatedTable(
      idleReadings: chosenTask.idleReadings.reversed.toList(),
      loadReadings: chosenTask.loadReadings.reversed.toList(),
      isIdleSelected: engineState == EngineState.idle,);
  }

  Widget latestDataCard(){
    return Column(
      children: [
        statValue(Lists.getStatValue("U"), (isIdleEngineState()
            ? chosenTask.idleReadings.isEmpty ? null : chosenTask?.idleReadings?.last?.voltage
            : chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.voltage)),
        statValue(Lists.getStatValue("f"), (isIdleEngineState()
            ? chosenTask.idleReadings.isEmpty ? null : chosenTask?.idleReadings?.last?.powerFrequency
            : chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.powerFrequency)),
        statValue(Lists.getStatValue("n"), (isIdleEngineState()
            ? chosenTask.idleReadings.isEmpty ? null : chosenTask?.idleReadings?.last?.rotationalSpeed
            : chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.rotationalSpeed)),
        statValue(Lists.getStatValue("P"), (isIdleEngineState()
            ? chosenTask.idleReadings.isEmpty ? null : chosenTask?.idleReadings?.last?.power
            : chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.power)),
        statValue(Lists.getStatValue("Is"), (isIdleEngineState()
            ? chosenTask.idleReadings.isEmpty ? null : chosenTask?.idleReadings?.last?.statorCurrent
            : chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.statorCurrent)),
        statValue(Lists.getStatValue("Iw"), (isIdleEngineState()
            ? chosenTask.idleReadings.isEmpty ? null : chosenTask?.idleReadings?.last?.rotorCurrent
            : chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.rotorCurrent)),
        if(isLoadEngineState())
          statValue(Lists.getStatValue("T"), chosenTask.loadReadings.isEmpty ? null : chosenTask?.loadReadings?.last?.ballastMoment)
      ],
    );
  }

  Widget selectYAxis(){
    return FlatButton(
      onPressed: (){},
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          items: isIdleEngineState()
              ? (Lists.statsList.where((x) => !x.loadEngineStateReading).map((e) {
            return DropdownMenuItem(
              value: e.symbol,
              child: Text(e.symbol),
            );
          }).toList())
              : Lists.statsList.map((e) {
            return DropdownMenuItem(
              value: e.symbol,
              child: Text(e.symbol, textAlign: TextAlign.center,),
            );
          }).toList(),
          value: selectedYAxis,
          onChanged: (value){
            setState(() {
              selectedYAxis=value;
              if(yAxisData.isNotEmpty) yAxisData.clear();
              switch(engineState){
                case EngineState.load:
                  chosenTask.loadReadings.forEach((x) {
                    if(selectedYAxis.toLowerCase()=="T".toLowerCase())
                      yAxisData.add(x.ballastMoment);
                    else{
                      yAxisData.add((x.toJson()["${Lists.statsList.firstWhere((e) => e.symbol==value).readingJsonKey}"]));
                    }
                  });
                  break;
                case EngineState.idle:
                  chosenTask.idleReadings.forEach((x) {
                    yAxisData.add((x.toJson()["${Lists.statsList.firstWhere((e) => e.symbol==value).readingJsonKey}"]));
                  });
                  break;
              }
            });
          },
        ),
      ),
    );
  }

  Widget chart(){
    int length = isIdleEngineState() ? chosenTask.idleReadings.length : chosenTask.loadReadings.length;
    return Container(
      width: (MediaQuery.of(context).size.width/2),
      height: MediaQuery.of(context).size.width*0.4,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: ChartJS(
          id: 'my-chart',
          config: ChartConfig(
              type: ChartType.line,
              options: ChartOptions(
                  responsive: true,
                  animationConfiguration: ChartAnimationConfiguration(
                    duration: Duration(milliseconds: 0)
                  ),
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
                  labels: (isIdleEngineState() ? chosenTask.idleReadings : chosenTask.loadReadings).map((e){
                    return ((isIdleEngineState() ? chosenTask.idleReadings : chosenTask.loadReadings).indexOf(e)+1).toString();
                  }).toList().getRange(length - _currentSliderValue <= 0 ? 0 : length - _currentSliderValue, length).toList(),
                  datasets: [
                    ChartDataset(
                      label: selectedYAxis,
                        data: (isIdleEngineState() ? chosenTask.idleReadings : chosenTask.loadReadings).map((dynamic x){
                          return selectedYAxis == "T" ? x.ballastMoment : x.toJson()["${Lists.statsList.firstWhere((e) => e.symbol==selectedYAxis).readingJsonKey}"];
                        }).toList().getRange(length - _currentSliderValue <= 0 ? 0 : length - _currentSliderValue, length).toList(),
                        backgroundColor: Colors.blue.withOpacity(0.4),
                    )
                  ]
              )
          )),
    );
  }

  Future<bool> _requestPop() {
    DialogUtils.showYesNoDialog(
      context,
      "Czy na pewno chcesz skończyć laboratorium?",
      yesFunction: () {
        Navigator.of(context).pop();
        if(!chosenTask.hasEnded){
          ApiClient().endTask().then((value) {
            ApiClient().endLab().then((value) {
              return new Future.value(true);
            });
          });
        }
        else {
          ApiClient().endLab().then((value) {
            return new Future.value(true);
          });
        }
      },
      noFunction: () {
        return new Future.value(false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;
    return WillPopScope(
      onWillPop: _requestPop,
      child: SilnikScaffold.get(
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
                    new SelectableText(MyDateUtils.formatDateTime(context, lab.date), style: textTheme.subtitle1.copyWith(color: Colors.white))
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
                          flex: 3,
                          child: Column(children: [
                            engineStateCard(),
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    child: new Container(
                                      height: 800,
                                      child: MaterialApp(
                                        debugShowCheckedModeBanner: false,
                                        builder: (context, child) {
                                          return DefaultTabController(
                                              length: 3,
                                              child: Column(
                                                children: [
                                                  new TabBar(
                                                    indicatorColor: Colors.blue,
                                                    indicatorWeight: 2,
                                                    tabs: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                            "Odczyty bieżące",
                                                            textAlign: TextAlign.center,
                                                            style: Theme.of(context).textTheme.headline6),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: new Text(
                                                            "Historia odczytów",
                                                            textAlign: TextAlign.center,
                                                            style: Theme.of(context).textTheme.headline6),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: new Text(
                                                            "Wykresy danych",
                                                            textAlign: TextAlign.center,
                                                            style: Theme.of(context).textTheme.headline6),
                                                      ),
                                                    ],
                                                  ),
                                                  Flexible(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .all(8.0),
                                                      child: TabBarView(
                                                        children: [
                                                          latestDataCard(),
                                                          historicalDataTableCard(),
                                                          Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(child: selectYAxis()),
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Slider(
                                                                      value: _currentSliderValue.toDouble(),
                                                                      min: 10,
                                                                      max: 250,
                                                                      divisions: 240 ~/ 10,
                                                                      label: _currentSliderValue.round().toString(),
                                                                      onChanged: (double value) {
                                                                        setState(() {
                                                                          _currentSliderValue = value.toInt();
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Text(
                                                                  "Pokazuj ostanie: $_currentSliderValue pomiarów na wykresie",
                                                                  style: textTheme.subtitle1),
                                                              chart(),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ));
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ])),
                            Expanded(
                              flex: 2,
                              child: Stack(
                                children: [
                                  AbsorbPointer(
                                    absorbing: chosenTask.hasEnded,
                                    child: Opacity(
                                      opacity: !chosenTask.hasEnded ? 1 : 0.1,
                                      child: Column(children: [
                                        algorithmChooseCard(),
                                        changeValuesCard(),
                                        changeValuesPeriodicallyCard(),
                                        fetchDataCard(),
                                      ]),
                                    ),
                                  ),
                                  !chosenTask.hasEnded ? Container() :
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.cancel, color: Colors.redAccent),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text("Zadanie zakończone\nNie można przeprowdzić dalszych odczytów w tym zadaniu",
                                                      textAlign: TextAlign.center, style: textTheme.subtitle2.copyWith(color: Colors.redAccent)),
                                                )
                                              ],
                                            )
                                          ]),
                                    ),
                                  )
                                ],
                              )
                            )
                          ],
                        ),
                ],
              ))),
    );
  }

  _showAddTaskDialog() async =>
      AddTaskDialog.showAddTaskDialog(context).then((value) {
        if (value != null && currentTaskEnded) {
          ApiClient().addTask(value, lab).then((task) {
            lab.tasks.add(task);
          });
          DialogUtils.showYesNoDialog(context, "Wczytać dodane ćwiczenie?",
              yesFunction: () {
            setState(() {
              currentTaskEnded = false;
            });
            chosenTask = lab.tasks.last;
            _stopMacro();
            _stopFetchingData();
            ToastUtils.showToast("Wybrane ćwiczenie: ${utf8.decode(chosenTask.name.codeUnits)}");
          }, noFunction: () {});
        }
      });

  // ignore: missing_return
  _showEndTaskDialog({bool addTaskAfter = false}) {
    if (lab.tasks.isEmpty || currentTaskEnded) {
      _showAddTaskDialog();
    }
    else {
      if (addTaskAfter) {
        _showAddTaskDialog();
      }
      else {
        DialogUtils.showYesNoDialog(context,
            "Czy chcesz zakończyć obecne zadanie?${addTaskAfter
                ? "\n(Aby przejść do nowego zadania wymagane jest zakończenie obecnego)"
                : ""}",
            yesFunction: () {
              ApiClient().endTask().then((task) {
                setState(() {
                  currentTaskEnded = task;
                  chosenTask.hasEnded = true;
                  try {
                    lab.tasks
                        .firstWhere((e) => e.id == chosenTask.id)
                        .hasEnded = true;
                    print("doooone");
                  } catch(e){
                    print("sissisisisisi");
                  }

                });
                _stopMacro();
                _stopFetchingData();
                ToastUtils.showToast(
                    "Zakończono ćwiczenie: ${chosenTask.name}");
                if (addTaskAfter && task) {
                  _showAddTaskDialog();
                }
              });
            });
      }
    }
  }
}

enum ChangeValueType {offset, fixed}
enum FetchDataType {manual, periodically}
enum EngineState {load, idle}