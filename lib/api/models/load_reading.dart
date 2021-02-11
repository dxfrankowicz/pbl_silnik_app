import 'package:json_annotation/json_annotation.dart';
import 'package:silnik_app/api/models/reading.dart';
import 'package:silnik_app/api/models/task.dart';
part 'load_reading.g.dart';

@JsonSerializable()
class LoadReading extends Reading{
  double ballastMoment;
  bool selected = false;

  LoadReading(this.ballastMoment);

  LoadReading.empty();

  factory LoadReading.fromJson(Map<String, dynamic> json) => _$LoadReadingFromJson(json);
  Map<String, dynamic> toJson() => _$LoadReadingToJson(this);
}