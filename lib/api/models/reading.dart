import 'package:json_annotation/json_annotation.dart';
import 'package:silnik_app/api/models/task.dart';
part 'reading.g.dart';

@JsonSerializable()
class Reading {
  int id;
  double voltage;
  double power;
  double statorCurrent;
  double rotorCurrent;
  double rotationalSpeed;
  double powerFrequency;
  DateTime timeStamp;
  Task task;

  Reading(
      {this.id,
      this.voltage,
      this.power,
      this.statorCurrent,
      this.rotorCurrent,
      this.rotationalSpeed,
      this.powerFrequency,
      this.timeStamp,
      this.task});

  factory Reading.fromJson(Map<String, dynamic> json) => _$ReadingFromJson(json);
  Map<String, dynamic> toJson() => _$ReadingToJson(this);
}



