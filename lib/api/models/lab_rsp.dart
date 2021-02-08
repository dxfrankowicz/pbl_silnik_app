import 'lab.dart';

class LabRsp {
  // ignore: conflicting_dart_import
  List<Lab> labs;

  LabRsp(this.labs);

  factory LabRsp.fromJson(json) {
    if (json == null) {
      return null;
    } else {
      List<Lab> l = new List();
      for (var value in json) {
        l.add(new Lab.fromJson(value));
      }
      return new LabRsp(l);
    }
  }
}