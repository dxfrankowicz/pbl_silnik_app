import 'package:json_annotation/json_annotation.dart';
import 'package:silnik_app/api/models/idle_reading.dart';
import 'package:silnik_app/api/models/load_reading.dart';
import 'lab.dart';
part 'task.g.dart';

@JsonSerializable()
class Task {
  int id;
  String name;
  List<IdleReading> idleReadings;
  List<LoadReading> loadReadings;
  Lab lab;

  Task(this.id, this.name, this.idleReadings, this.loadReadings, this.lab);


  @override
  String toString() {
    return 'Task{id: $id, name: $name, idleReadings: $idleReadings, loadReadings: $loadReadings, lab: $lab}';
  }

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}



