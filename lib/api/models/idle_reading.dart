import 'package:json_annotation/json_annotation.dart';
import 'package:silnik_app/api/models/reading.dart';
part 'idle_reading.g.dart';

@JsonSerializable()
class IdleReading {
  Reading reading;

  IdleReading(this.reading);

  IdleReading.empty();

  factory IdleReading.fromJson(Map<String, dynamic> json) => _$IdleReadingFromJson(json);
  Map<String, dynamic> toJson() => _$IdleReadingToJson(this);
}