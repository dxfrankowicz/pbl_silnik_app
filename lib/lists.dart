import 'api/models/lab.dart';
import 'api/models/stat_value.dart';

class Lists{

  static List<StatValue> statsList = [
    StatValue(symbol: "U", desc: "Napięcie", value: 1.35, unit: "V"),
    StatValue(symbol: "f", desc: "Częstotliwość", value: 50, unit: "Hz"),
    StatValue(symbol: "P", desc: "Moc", value: 10, unit: "W"),
    StatValue(symbol: "n", desc: "Prędkość obrotowa", value: 1000, unit: "rpm", precision: 0),
    StatValue(symbol: "Is", symbolSubscriptIndex: 1, desc: "Prąd w uzwojeniu stojana", value: 2, unit: "A"),
    StatValue(symbol: "Iw", symbolSubscriptIndex: 1, desc: "Prąd w uzwojeniu wirnika", value: 2, unit: "A"),
    StatValue(symbol: "T", desc: "Moment obciążenia", value: 15, unit: "Nm"),
  ];

  static List<Lab> labs = [
    Lab(1, "Laboratorium ip", DateTime.now(), null),
    Lab(2, "Laboratorium testowe", DateTime.now().add(Duration(days: 1)), null),
    Lab(3, "Laboratorium zip", DateTime.now().subtract(Duration(days: 7)), null),
  ];
}