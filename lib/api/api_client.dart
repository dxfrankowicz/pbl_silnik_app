import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:silnik_app/api/models/idle_reading.dart';
import 'package:silnik_app/api/models/lab.dart';
import 'package:silnik_app/api/models/lab_rsp.dart';
import 'package:silnik_app/api/models/load_reading.dart';
import 'package:silnik_app/api/models/reading.dart';
import 'package:silnik_app/api/models/task.dart';
import 'package:silnik_app/pages/new_lab_view/new_lab_view.dart';
import 'package:silnik_app/utils/toast_utils.dart';
import 'base_api_client.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  //singleton

  final Logger logger = new Logger("ApiClient");
  final Client client = new Client();
  BaseApiClient baseApiClient;

  static ApiClient _singleton = new ApiClient._internal();
  bool seasonsNotAvailable = true;

  factory ApiClient() {
    return _singleton;
  }

  List<Map<String, String>> get log => baseApiClient.log;

  ApiClient._internal() {
    logger.info("Initializing API CLIENT");
    this.baseApiClient = new BaseApiClient();
  }

  void reloadApiUrl() {
    this.baseApiClient.reloadApiUrl();
  }

  static List<Lab> _labs = [];

  // static final ApiClient _singleton = ApiClient._internal();
  // factory ApiClient() {
  //   if (_labs.isEmpty)
  //     Lists.labs.forEach((element) {
  //       _labs.add(element);
  //     });
  //   return _singleton;
  // }
  // ApiClient._internal();

  String prepareJsonToSend(Map<String,dynamic> body){
    body.removeWhere((k, v) {
      return v == null;
    });
    body = body.map((k, v) {
      return new MapEntry(k, v?.toString());
    });
    var jsonToSend = json.encode(body).toString();
    return jsonToSend;
  }

  convertToJson(Response rsp) =>
      rsp.body != null ? json.decode(rsp.body) : null;

  Map<String, dynamic> prepareForUpdate(Map<String, dynamic> body) {
    body.removeWhere((k, v) {
      return v == null;
    });
    body = body.map((k, v) {
      return new MapEntry(
          k,
          v?.toString());
    });
    return body;
  }

  Future<Reading> fetchData({EngineState engineState, Task chosenTask}) async {
    var body = describeEnum(engineState).toLowerCase();
    // ignore: missing_return
    return baseApiClient.get("/measurement/$body").then((rsp) {
      var json = convertToJson(rsp);
      switch (engineState) {
        case EngineState.load:
          LoadReading loadReading = LoadReading.fromJson(json);
          loadReading.task = chosenTask;
          return loadReading;
          break;
        case EngineState.idle:
          IdleReading idleReading = IdleReading.fromJson(json);
          idleReading.task = chosenTask;
          return idleReading;
          break;
      }
    });
  }

  Future<bool> setValue({EngineState engineState, Task chosenTask, Map<String, double> value}) async {
    Task _chosenTask = chosenTask;
    Random r = new Random();
    switch (engineState) {
      case EngineState.load:
        return baseApiClient.post("/measurement/loadParams/${value["f"]}/${value["T"]}").then((rsp) {
          return true;
        }).catchError((e){
          return false;
        });
        break;
      case EngineState.idle:
        return baseApiClient.post("/measurement/idleParams/${value["f"]}").then((rsp) {
          return true;
        }).catchError((e){
          return false;
        });
        break;
    }
    print("Ustawaiono dane ${value.toString()}");
  }

  Future<bool> endLab() async {
    return baseApiClient.post("/lab/endLab").then((rsp) {
      return true;
    }).catchError((e){
      return false;
    });
  }

  Future<bool> endTask() async {
    return baseApiClient.post("/task/endTask").then((rsp) {
      return true;
    }).catchError((e){
      return false;
    });
  }

  Future<LabRsp> getLabsList() async {
    return baseApiClient.get("/lab").then((rsp){
      var json = convertToJson(rsp);
      return LabRsp.fromJson(json);
    });
  }

  Future<Lab> addLab(Lab lab) async {
    var body = lab.name;
    return baseApiClient.post("/lab", body: body).then((rsp) {
      var json = convertToJson(rsp);
      return Lab.fromJson(json);
    });
  }

  Future<Task> addTask(String taskName, Lab lab) async {
    var body = taskName;
    return baseApiClient.post("/task", body: body).then((rsp) {
      var json = convertToJson(rsp);
      Task task = Task.fromJson(json);
      task.lab = lab;
      task.loadReadings = [];
      task.idleReadings = [];
      task.hasEnded = false;
      print("TASK ${task}");
      return task;
    });
  }

  Future<Lab> updateLab(Lab lab) async {
    int index = _labs.indexOf(_labs.firstWhere((x) => x.id == lab.id));
    _labs[index] = lab;
    return lab;
  }

  Future<Lab> getLab(int labId) async {
    return baseApiClient.get("/lab/$labId").then((rsp){
      var json = convertToJson(rsp);
      return Lab.fromJson(json);
    });
  }

  Future<Task> deleteReading({int id, Task chosenTask, EngineState engineState}) async {
    if (engineState == EngineState.idle) {
      chosenTask.idleReadings.removeWhere((x) => x.id == id);
    } else {
      chosenTask.loadReadings.removeWhere((x) => x.id == id);
    }
    return chosenTask;
  }
}
