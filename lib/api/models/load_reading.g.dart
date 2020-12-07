// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoadReading _$LoadReadingFromJson(Map<String, dynamic> json) {
  return LoadReading(
    (json['torque'] as num)?.toDouble(),
    json['reading'] == null
        ? null
        : Reading.fromJson(json['reading'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LoadReadingToJson(LoadReading instance) =>
    <String, dynamic>{
      'torque': instance.torque,
      'reading': instance.reading,
    };
