import 'package:json_annotation/json_annotation.dart';
import 'package:silnik_app/api/models/reading.dart';
import 'package:silnik_app/api/models/task.dart';
part 'idle_reading.g.dart';

@JsonSerializable()
class IdleReading extends Reading {
  bool selected = false;

  IdleReading();
  IdleReading.empty();

  factory IdleReading.fromJson(Map<String, dynamic> json) => _$IdleReadingFromJson(json);
  Map<String, dynamic> toJson() => _$IdleReadingToJson(this);

  @override
  String toString() {
    return 'IdleReading{${super.toString()}';
  }
}