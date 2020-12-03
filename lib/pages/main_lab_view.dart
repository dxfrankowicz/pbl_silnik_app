import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silnik_app/api/models/lab.dart';
import 'package:silnik_app/pages/base_scaffold.dart';

import '../api/models/stat_value.dart';
import '../lists.dart';

class MainLabPage extends StatelessWidget{
  int id;

  MainLabPage(this.id);

  Widget getLabsPage(int id) {
    for (Lab lab in Lists.labs) {
      if (lab.id == id) {
        return MainLabView(lab);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return getLabsPage(id);
  }
}

class MainLabView extends StatefulWidget {

  Lab lab;
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

  Map<String, TextEditingController> macroChangeControllerValue = new Map();
  TextEditingController macroChangeControllerTime = TextEditingController();
  FetchDataType fetchDataType = FetchDataType.manual;

  final _changeValuesCardKey = GlobalKey<FormState>();
  final _macroTimeKey = GlobalKey<FormState>();
  final _macroValueFormKey = GlobalKey<FormState>();

  //fetch data type
  TextEditingController fetchDataIntervalController = TextEditingController(text: 1.toString());
  final _fetchDataIntervalFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    Lists.statsList.forEach((element) {
      statValueChangeTextController[element.symbol] = TextEditingController();
      statValueChangeTextController[element.symbol].text = element.value.toString();

      macroChangeControllerValue[element.symbol] = TextEditingController();
      macroChangeControllerValue[element.symbol].text = 0.toString();
    });
    macroChangeControllerTime.text = 10.toString();
    super.initState();
  }

  Timer _timer;
  int macrosDone = 0;
  int macrosTime = 0;

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
    macrosDone+=1;
    Lists.statsList.forEach((element) {
      if (macroChangeControllerValue[element.symbol].text != null &&
          macroChangeControllerValue[element.symbol].text != "")
        setState(() {
          element.value += double.parse(macroChangeControllerValue[element.symbol].text);
        });
    });
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
    Lists.statsList.forEach((element) {
        setState(() {
          element.value = Random().nextDouble();
        });
    });
  }


  Widget statValue(StatValue stat) {
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
                          controller: TextEditingController(text: stat.value==null
                              ? "-" : "${stat.value.toStringAsFixed(stat.precision)}"),
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
    bool biggerThantZeroValidation = false}) {

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
                              Expanded(child: Text("Pobieraj dane manualnie po przyciśnięciu przycisku"))
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
                                  Expanded(child: Text("Pobieraj dane automatycznie")),
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

  Widget customTextFieldMacro({StatValue stat, TextEditingController controller,
    bool enabled, String suffixText, String prefixText}) {

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
                        return 'Wartość musi być różna od 0';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        suffixText: suffixText ?? stat.unit,
                        prefixText: prefixText ?? "${stat.symbol}",
                        labelText: "${stat.desc} (+/-)",
                        border: OutlineInputBorder()
                    ),
                    controller: controller ?? statValueChangeTextController[stat.symbol],
                    enabled: enabled ?? !isMacroRunning,
                    onChanged: (s){
                      if (s != null && s != "" && double.tryParse(s) != null)
                        setState(() {});
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9-]')),],
                    controller: TextEditingController(
                        text: "${(stat.value + double.parse(macroChangeControllerValue[stat.symbol].value.text ?? 0)).toStringAsFixed(stat.precision)}"),
                    enabled: false,
                    decoration: InputDecoration(
                        labelText: "Następna wartość",
                        suffixText: stat.unit,
                        border: OutlineInputBorder()
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget changeValuesCard(StatValue stat) {
    return Row(
      children: [
        Expanded(
          child: Opacity(
            opacity: !isMacroRunning ? 1 : 0.2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Zmień wartość", style: textTheme.headline6),
                    Form(
                        key: _changeValuesCardKey,
                        child: customTextField(stat: stat, labelText: stat.desc)
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: FlatButton(
                              onPressed: isMacroRunning
                                  ? null
                                  : () {
                                if (_changeValuesCardKey.currentState.validate())
                                  setState(() {
                                    Lists.statsList.firstWhere((element) => element.symbol == stat.symbol).value =
                                        double.parse(statValueChangeTextController[stat.symbol].text);
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
          ),
        )
      ],
    );
  }

  Widget changeValuesPeriodicallyCard(StatValue stat) {
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
                  Text("Zmieniaj wartość cyklicznie (makro)", style: textTheme.headline6),
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
                    child: customTextFieldMacro(stat: stat, controller: macroChangeControllerValue[stat.symbol]),
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
                                if(_macroTimeKey.currentState.validate() && _macroValueFormKey.currentState.validate()) {
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
        appBar: SilnikScaffold.appBar(context, actions: [
          new Text(lab.name, style: textTheme.subtitle1.copyWith(color: Colors.white))
        ]),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  child: Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: Lists.statsList.map((e) => statValue(e)).toList(),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                    children: [
                      fetchDataCard(),
                      Column(
                        children: Lists.statsList
                            .where((x) => x.symbol == "f")
                            .map((e) => changeValuesCard(e))
                            .toList(),
                      ),
                      Column(
                        children: Lists.statsList
                            .where((x) => x.symbol == "f")
                            .map((e) => changeValuesPeriodicallyCard(e))
                            .toList(),
                      )
                    ]
                ),
              )
            ],
          ),
        )
    );
  }
}

enum ChangeValueType {offset, fixed}
enum FetchDataType {manual, periodically}