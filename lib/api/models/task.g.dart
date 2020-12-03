// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) {
  return Task(
    json['id'] as int,
    json['name'] as String,
    (json['idleReadings'] as List)
        ?.map((e) =>
            e == null ? null : StatValue.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['loadReadings'] as List)
        ?.map((e) =>
            e == null ? null : StatValue.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['lab'] == null
        ? null
        : Lab.fromJson(json['lab'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'idleReadings': instance.idleReadings,
      'loadReadings': instance.loadReadings,
      'lab': instance.lab,
    };
