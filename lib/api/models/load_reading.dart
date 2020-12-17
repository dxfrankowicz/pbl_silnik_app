import 'package:json_annotation/json_annotation.dart';
import 'package:silnik_app/api/models/reading.dart';
part 'load_reading.g.dart';

@JsonSerializable()
class LoadReading {
  double torque;
  bool selected = false;
  Reading reading;

  LoadReading(this.torque, this.reading);

  LoadReading.empty();

  factory LoadReading.fromJson(Map<String, dynamic> json) => _$LoadReadingFromJson(json);
  Map<String, dynamic> toJson() => _$LoadReadingToJson(this);
}