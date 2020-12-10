import 'package:json_annotation/json_annotation.dart';
part 'stat_value.g.dart';

@JsonSerializable()
class StatValue {
  String symbol;
  int symbolSubscriptIndex;
  String symbolSuperscript;
  String desc;
  double value;
  String unit;
  int precision;
  bool loadEngineStateReading;
  String readingJsonKey;

  StatValue(
      {this.symbol,
        this.symbolSubscriptIndex,
        this.symbolSuperscript,
        this.desc,
        this.value,
        this.precision = 3,
        this.loadEngineStateReading = false,
        this.readingJsonKey,
        this.unit});

  factory StatValue.fromJson(Map<String, dynamic> json) => _$StatValueFromJson(json);
  Map<String, dynamic> toJson() => _$StatValueToJson(this);
}



