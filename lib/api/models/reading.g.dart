// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reading _$ReadingFromJson(Map<String, dynamic> json) {
  return Reading(
    json['id'] as int,
    (json['voltage'] as num)?.toDouble(),
    (json['power'] as num)?.toDouble(),
    (json['statorCurrent'] as num)?.toDouble(),
    (json['rotorCurrent'] as num)?.toDouble(),
    (json['rotationalSpeed'] as num)?.toDouble(),
    json['timeStamp'] == null
        ? null
        : DateTime.parse(json['timeStamp'] as String),
    json['task'] == null
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
      'timeStamp': instance.timeStamp?.toIso8601String(),
      'task': instance.task,
    };
