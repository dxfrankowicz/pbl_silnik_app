import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'middleware/HttpLoggerMiddleware.dart';
import 'middleware/HttpMemoryLoggerMiddleware.dart';
import 'middleware/HttpValidatorMiddleware.dart';
import 'middleware/HttpWithMiddleware.dart';
import 'utils/http_logger.dart';


class BaseApiClient {
  final Logger logger = new Logger("BaseApiClient");
  static String baseUrl = "http://localhost:8081/pbl";

  HttpMemoryLoggerMiddleware _httpMemoryLogger = HttpMemoryLoggerMiddleware();
  HttpLoggerMiddleware _httpLoggerMiddleware = HttpLoggerMiddleware(
      logLevel: LogLevel.BODY,
      maxBodySize: 1024);
  HttpValidatorMiddleware _httpValidatorMiddleware = HttpValidatorMiddleware();
  HttpWithMiddleware _inner;

  bool _clientFullyInitialized = false;

  BaseApiClient() {
    logger.info("Creating new ApiClient");

    _inner = HttpWithMiddleware.build(middlewares: [
      _httpLoggerMiddleware,
      _httpMemoryLogger,
      _httpValidatorMiddleware
    ]);
  }

  Future<String> getBaseUrl() async {
    await reloadApiUrl();
    return baseUrl;
  }

  Future<Null> _init() async {
    if (_clientFullyInitialized) return;
    await reloadApiUrl();

    logger.info("Fully initialized ApiClient");
    _clientFullyInitialized = true;
  }

  Future<Null> reloadApiUrl() async {
    BaseApiClient.baseUrl = baseUrl;
    logger.info("Initializing api client with url=${BaseApiClient.baseUrl}");
  }

  Future<void> _loadAll(String url) async {
    await _init();
  }

  Future<Response> get(String url,
      {Map<String, String> headers = const {"Content-Type": "application/json"}, body, Encoding encoding}) async {
    await _loadAll(url);
    return _inner.get(baseUrl + url, headers: headers, body: body);
  }

  Future<Response> download(String url) async {
    await _loadAll(url);
    return _inner.get(url);
  }

  Future<Response> post(String url,
      {Map<String, String> headers = const {"Content-Type": "application/json"}, body, Encoding encoding}) async {
    await _loadAll(url);
    return _inner.post(baseUrl + url,
        headers: headers, body: body, encoding: encoding);
  }

  Future<Response> put(String url,
      {Map<String, String> headers = const {"Content-Type": "application/json"}, body, Encoding encoding}) async {
    await _loadAll(url);
    return _inner.put(baseUrl + url,
        headers: headers, body: body, encoding: encoding);
  }

  Future<Response> delete(String url, {Map<String, String> headers = const {"Content-Type": "application/json"}}) async {
    await _loadAll(url);
    return _inner.delete(baseUrl + url, headers: headers);
  }

  Future<Response> multipart(String url,
      {Map<String, String> headers = const {"Content-Type": "application/json"}, body, Encoding encoding, MultipartFile multipartFile}) async {
    await _loadAll(url);
    return _inner.multipart(baseUrl + url,
        headers: headers, body: body, encoding: encoding, multipartFile: multipartFile);
  }

  List<Map<String, String>> get log => _httpMemoryLogger.log;

}