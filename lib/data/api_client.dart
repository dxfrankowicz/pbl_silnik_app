import 'dart:math';

import 'package:silnik_app/api/models/idle_reading.dart';
import 'package:silnik_app/api/models/lab.dart';
import 'package:silnik_app/api/models/load_reading.dart';
import 'package:silnik_app/api/models/reading.dart';
import 'package:silnik_app/api/models/task.dart';
import 'package:silnik_app/pages/new_lab_view/new_lab_view.dart';
import 'package:silnik_app/utils/toast_utils.dart';

import '../lists.dart';

class ApiClient {
  //singleton

  static List<Lab> _labs = [];

  static final ApiClient _singleton = ApiClient._internal();
  factory ApiClient() {
    if (_labs.isEmpty)
      Lists.labs.forEach((element) {
        _labs.add(element);
      });
    return _singleton;
  }
  ApiClient._internal();

  Future<Task> fetchData({EngineState engineState, Task chosenTask}) async {
    Random r = new Random();
    if (engineState == EngineState.idle) {
      chosenTask.idleReadings.add(IdleReading(Reading(
          id: chosenTask.idleReadings.length + 1,
          voltage: r.nextDouble(),
          power: r.nextDouble(),
          statorCurrent: r.nextDouble(),
          rotorCurrent: r.nextDouble(),
          rotationalSpeed: r.nextDouble(),
          powerFrequency: r.nextDouble(),
          timeStamp: DateTime.now(),
          task: chosenTask)));
    } else {
      chosenTask.loadReadings.add(LoadReading(
          r.nextDouble(),
          Reading(
              id: chosenTask.idleReadings.length + 1,
              voltage: r.nextDouble(),
              power: r.nextDouble(),
              statorCurrent: r.nextDouble(),
              rotorCurrent: r.nextDouble(),
              rotationalSpeed: r.nextDouble(),
              powerFrequency: r.nextDouble(),
              timeStamp: DateTime.now(),
              task: chosenTask)));
    }

    print("Pobrano dane ${chosenTask.toJson()}");
    return chosenTask;
  }

  Future<Task> setValue({EngineState engineState, Task chosenTask, Map<String, double> value}) async {
    Task _chosenTask = chosenTask;
    Random r = new Random();
    if (engineState == EngineState.idle) {
      _chosenTask.idleReadings.add(IdleReading(Reading(
          id: _chosenTask.idleReadings.length + 1,
          voltage: r.nextDouble(),
          power: r.nextDouble(),
          statorCurrent: r.nextDouble(),
          rotorCurrent: r.nextDouble(),
          rotationalSpeed: r.nextDouble(),
          powerFrequency: value["f"] ?? r.nextDouble(),
          timeStamp: DateTime.now(),
          task: _chosenTask)));
    } else {
      _chosenTask.loadReadings.add(LoadReading(
          value["T"] ?? r.nextDouble(),
          Reading(
              id: _chosenTask.idleReadings.length + 1,
              voltage: r.nextDouble(),
              power: r.nextDouble(),
              statorCurrent: r.nextDouble(),
              rotorCurrent: r.nextDouble(),
              rotationalSpeed: r.nextDouble(),
              powerFrequency: value["f"] ?? r.nextDouble(),
              timeStamp: DateTime.now(),
              task: _chosenTask)));
    }
    print("Ustawaiono dane ${value.toString()}");
    return _chosenTask;
  }

  Future<bool> endLab() async {
    ToastUtils.showToast("Laboratorium zostało zakończone");
    return true;
  }

  Future<List<Lab>> getLabsList() async {
    return _labs;
  }

  Future<void> addLab(Lab lab) async {
    return _labs.add(lab);
  }

  Future<Task> addTask(Task task) async {
    _labs.firstWhere((x) => x.id == task.lab.id).tasks.add(task);
    return task;
  }

  Future<Lab> updateLab(Lab lab) async {
    int index = _labs.indexOf(_labs.firstWhere((x) => x.id == lab.id));
    _labs[index] = lab;
    return lab;
  }

  Future<Lab> getLab(int labId) async {
    Lab lab = _labs.firstWhere((x) => x.id == labId);
     print("Asddasdasda ${lab.toJson()}");
     if(lab!=null && labId<=3){
        Random r = new Random();
     lab.tasks.forEach((e) {
        List<LoadReading> loads = List.generate(100, (index) => LoadReading((index + r.nextDouble()),
            Reading(
                id: index,
                voltage: r.nextDouble(),
                power: (pow(index,2)).toDouble(),
                statorCurrent: (index+2).toDouble(),
                rotorCurrent: (index+3).toDouble(),
                rotationalSpeed: (index+4).toDouble(),
                powerFrequency: index.toDouble(),
                timeStamp: DateTime.now(),
                task: e)));
        e.loadReadings.addAll(loads);
        List<IdleReading> idles = List.generate(100, (index) => IdleReading(
            Reading(
                id: index,
                voltage: r.nextDouble(),
                power: 1,
                statorCurrent: r.nextDouble(),
                rotorCurrent: r.nextDouble(),
                rotationalSpeed: r.nextDouble(),
                powerFrequency: index.toDouble(),
                timeStamp: DateTime.now(),
                task: e)));
        e.idleReadings.addAll(idles);
      });
     }

    return lab;
  }


  Future<Task> deleteReading({int id, Task chosenTask, EngineState engineState}) async {
    if (engineState == EngineState.idle) {
      chosenTask.idleReadings.removeWhere((x) => x.reading.id == id);
    } else {
      chosenTask.loadReadings.removeWhere((x) => x.reading.id == id);
    }
    return chosenTask;
  }
}
