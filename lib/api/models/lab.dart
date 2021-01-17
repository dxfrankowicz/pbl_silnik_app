import 'package:json_annotation/json_annotation.dart';
import 'package:silnik_app/api/models/task.dart';
part 'lab.g.dart';

@JsonSerializable()
class Lab {
  int id;
  String name;
  DateTime date;
  List<Task> tasks;

  Lab.empty();

  Lab(this.id, this.name, this.date, this.tasks);

  factory Lab.fromJson(Map<String, dynamic> json) => _$LabFromJson(json);
  Map<String, dynamic> toJson() => _$LabToJson(this);

  @override
  String toString() {
    return 'Lab{id: $id, name: $name, date: $date, tasks: $tasks}';
  }
}



