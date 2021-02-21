// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoadReading _$LoadReadingFromJson(Map<String, dynamic> json) {
  return LoadReading(
    (json['ballastMoment'] as num)?.toDouble(),
  )
    ..id = json['id'] as int
    ..voltage = (json['voltage'] as num)?.toDouble()
    ..power = (json['power'] as num)?.toDouble()
    ..statorCurrent = (json['statorCurrent'] as num)?.toDouble()
    ..rotorCurrent = (json['rotorCurrent'] as num)?.toDouble()
    ..rotationalSpeed = (json['rotationalSpeed'] as num)?.toDouble()
    ..powerFrequency = (json['powerFrequency'] as num)?.toDouble()
    ..activePower = (json['activePower'] as num)?.toDouble()
    ..apparentPower = (json['apparentPower'] as num)?.toDouble()
    ..timeStamp = json['timeStamp'] == null
        ? null
        : DateTime.parse(json['timeStamp'] as String)
    ..task = json['task'] == null
        ? null
        : Task.fromJson(json['task'] as Map<String, dynamic>)
    ..selected = json['selected'] as bool;
}

Map<String, dynamic> _$LoadReadingToJson(LoadReading instance) =>
    <String, dynamic>{
      'id': instance.id,
      'voltage': instance.voltage,
      'power': instance.power,
      'statorCurrent': instance.statorCurrent,
      'rotorCurrent': instance.rotorCurrent,
      'rotationalSpeed': instance.rotationalSpeed,
      'powerFrequency': instance.powerFrequency,
      'activePower': instance.activePower,
      'apparentPower': instance.apparentPower,
      'timeStamp': instance.timeStamp?.toIso8601String(),
      'task': instance.task,
      'ballastMoment': instance.ballastMoment,
      'selected': instance.selected,
    };
