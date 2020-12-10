// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reading _$ReadingFromJson(Map<String, dynamic> json) {
  return Reading(
    id: json['id'] as int,
    voltage: (json['voltage'] as num)?.toDouble(),
    power: (json['power'] as num)?.toDouble(),
    statorCurrent: (json['statorCurrent'] as num)?.toDouble(),
    rotorCurrent: (json['rotorCurrent'] as num)?.toDouble(),
    rotationalSpeed: (json['rotationalSpeed'] as num)?.toDouble(),
    powerFrequency: (json['powerFrequency'] as num)?.toDouble(),
    timeStamp: json['timeStamp'] == null
        ? null
        : DateTime.parse(json['timeStamp'] as String),
    task: json['task'] == null
        ? null
        : Task.fromJson(json['task'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ReadingToJson(Reading instance) => <String, dynamic>{
      'id': instance.id,
      'voltage': instance.voltage,
      'power': instance.power,
      'statorCurrent': instance.statorCurrent,
      'rotorCurrent': instance.rotorCurrent,
      'rotationalSpeed': instance.rotationalSpeed,
      'powerFrequency': instance.powerFrequency,
      'timeStamp': instance.timeStamp?.toIso8601String(),
      'task': instance.task,
    };
