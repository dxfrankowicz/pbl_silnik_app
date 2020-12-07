// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stat_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatValue _$StatValueFromJson(Map<String, dynamic> json) {
  return StatValue(
    symbol: json['symbol'] as String,
    symbolSubscriptIndex: json['symbolSubscriptIndex'] as int,
    symbolSuperscript: json['symbolSuperscript'] as String,
    desc: json['desc'] as String,
    value: (json['value'] as num)?.toDouble(),
    precision: json['precision'] as int,
    loadEngineStateReading: json['loadEngineStateReading'] as bool,
    unit: json['unit'] as String,
  );
}

Map<String, dynamic> _$StatValueToJson(StatValue instance) => <String, dynamic>{
      'symbol': instance.symbol,
      'symbolSubscriptIndex': instance.symbolSubscriptIndex,
      'symbolSuperscript': instance.symbolSuperscript,
      'desc': instance.desc,
      'value': instance.value,
      'unit': instance.unit,
      'precision': instance.precision,
      'loadEngineStateReading': instance.loadEngineStateReading,
    };
