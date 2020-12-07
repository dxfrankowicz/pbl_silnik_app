import 'package:silnik_app/api/models/idle_reading.dart';

import 'api/models/lab.dart';
import 'api/models/stat_value.dart';
import 'api/models/task.dart';

class Lists{

  static List<StatValue> statsList = [
    StatValue(symbol: "U", desc: "Napięcie", unit: "V"),
    StatValue(symbol: "f", desc: "Częstotliwość",unit: "Hz"),
    StatValue(symbol: "P", desc: "Moc", unit: "W"),
    StatValue(symbol: "n", desc: "Prędkość obrotowa", unit: "rpm", precision: 0),
    StatValue(symbol: "Is", desc: "Prąd w uzwojeniu stojana", unit: "A"),
    StatValue(symbol: "Iw", desc: "Prąd w uzwojeniu wirnika", unit: "A"),
    StatValue(symbol: "T", desc: "Moment obciążenia", unit: "Nm", loadEngineStateReading: true),
  ];

  static StatValue getStatValue(String symbol){
    return statsList.firstWhere((x) => x.symbol.toLowerCase()==symbol.toLowerCase(), orElse: ()=>null);
  }

  static List<Lab> labs = [
    Lab(1, "Laboratorium ip", DateTime.now(), null),
    Lab(2, "Laboratorium testowe", DateTime.now().add(Duration(days: 1)), null),
    Lab(3, "Laboratorium zip", DateTime.now().subtract(Duration(days: 7)), null),
  ];

  static List<Task> tasksLab1 = [
    Task(1, "Ćwiczenie numer 1", null, null, labs[0]),
    Task(2, "Ćwiczenie numer 2", null, null, labs[0]),
  ];

  static List<IdleReading> idleReadings = [];
  static List<IdleReading> loadReadings = [];
}