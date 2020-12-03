import 'package:json_annotation/json_annotation.dart';
import 'package:silnik_app/api/models/stat_value.dart';
import 'lab.dart';
part 'task.g.dart';

@JsonSerializable()
class Task {
  int id;
  String name;
  List<StatValue> idleReadings;
  List<StatValue> loadReadings;
  Lab lab;

  Task(this.id, this.name, this.idleReadings, this.loadReadings, this.lab);

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}



