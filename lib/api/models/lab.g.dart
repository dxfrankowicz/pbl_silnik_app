// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lab _$LabFromJson(Map<String, dynamic> json) {
  return Lab(
    json['id'] as int,
    json['name'] as String,
    json['date'] == null ? null : DateTime.parse(json['date'] as String),
    (json['tasks'] as List)
        ?.map(
            (e) => e == null ? null : Task.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$LabToJson(Lab instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'date': instance.date?.toIso8601String(),
      'tasks': instance.tasks,
    };
