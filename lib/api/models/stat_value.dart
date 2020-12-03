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

  StatValue(
      {this.symbol,
        this.symbolSubscriptIndex,
        this.symbolSuperscript,
        this.desc,
        this.value,
        this.precision = 3,
        this.unit});

  factory StatValue.fromJson(Map<String, dynamic> json) => _$StatValueFromJson(json);
  Map<String, dynamic> toJson() => _$StatValueToJson(this);
}


