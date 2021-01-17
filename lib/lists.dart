import 'package:silnik_app/api/models/load_reading.dart';
import 'api/models/idle_reading.dart';
import 'api/models/lab.dart';
import 'api/models/stat_value.dart';
import 'api/models/task.dart';

class Lists{

  static List<StatValue> statsList = [
    StatValue(symbol: "U", desc: "Napięcie", unit: "V", readingJsonKey: "voltage"),
    StatValue(symbol: "f", desc: "Częstotliwość",unit: "Hz", readingJsonKey: "powerFrequency"),
    StatValue(symbol: "P", desc: "Moc", unit: "W", readingJsonKey: "power"),
    StatValue(symbol: "n", desc: "Prędkość obrotowa", unit: "rpm", precision: 0, readingJsonKey: "rotationalSpeed"),
    StatValue(symbol: "Is", desc: "Prąd w uzwojeniu stojana", unit: "A", readingJsonKey: "statorCurrent"),
    StatValue(symbol: "Iw", desc: "Prąd w uzwojeniu wirnika", unit: "A", readingJsonKey: "rotorCurrent"),
    StatValue(symbol: "T", desc: "Moment obciążenia", unit: "Nm", loadEngineStateReading: true, readingJsonKey: "torque"),
  ];

  static StatValue getStatValue(String symbol){
    return statsList.firstWhere((x) => x.symbol.toLowerCase()==symbol.toLowerCase(), orElse: ()=>null);
  }

  // ignore: deprecated_member_use
  static List<Lab> labs = [
    Lab(1, "Laboratorium ip", DateTime.now(), [

      Task(1, "Ćwiczenie numer 1", List<IdleReading>(), List<LoadReading>(), null),
      Task(2, "Ćwiczenie numer 2", List<IdleReading>(), List<LoadReading>(), null),
    ]),
    Lab(2, "Laboratorium testowe", DateTime.now().add(Duration(days: 1)), [
      Task(1, "Ćwiczenie 2 numer 1", List<IdleReading>(), List<LoadReading>(), null),
      Task(2, "Ćwiczenie 2 numer 2", List<IdleReading>(), List<LoadReading>(), null),
    ]),
    Lab(3, "Laboratorium zip", DateTime.now().subtract(Duration(days: 7)), [
      Task(1, "Ćwiczenie 3 numer 1", List<IdleReading>(), List<LoadReading>(), null),
      Task(2, "Ćwiczenie 3 numer 2", List<IdleReading>(), List<LoadReading>(), null),
    ]),
  ];

  static List<Task> tasksLab1 = [
    Task(1, "Ćwiczenie numer 1", List<IdleReading>(), List<LoadReading>(), labs[0]),
    Task(2, "Ćwiczenie numer 2",  List<IdleReading>(), List<LoadReading>(), labs[0]),
  ];

  static List<IdleReading> idleReadings = [];
  static List<LoadReading> loadReadings = [];
}