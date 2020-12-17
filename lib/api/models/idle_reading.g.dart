// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idle_reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IdleReading _$IdleReadingFromJson(Map<String, dynamic> json) {
  return IdleReading(
    json['reading'] == null
        ? null
        : Reading.fromJson(json['reading'] as Map<String, dynamic>),
  )..selected = json['selected'] as bool;
}

Map<String, dynamic> _$IdleReadingToJson(IdleReading instance) =>
    <String, dynamic>{
      'reading': instance.reading,
      'selected': instance.selected,
    };
