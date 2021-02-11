import 'package:http_interceptor/http_interceptor.dart';

class HttpMemoryLoggerMiddleware implements InterceptorContract {
  final List<Map<String, String>> log = [];
  static const nonLoggableBodies = ["storage"];
  static const int MAX_LOG_HISTORY = 50;
  bool shouldLog = false;

  HttpMemoryLoggerMiddleware();

  @override
  Future<RequestData> interceptRequest({RequestData data}) async{
    _log(Type.REQ, data.method.toString(), data.url, data.body);
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async{
    _log(Type.RSP, data.method.toString(), data.url, data.body);
    return data;
  }

  void _log(Type type, String method, String url, dynamic body) {
    if (!shouldLog)
      return;

    log.add({
      "date": new DateTime.now().toIso8601String(),
      "type": type.toString(),
      "method": method,
      "url": url,
      "body": nonLoggableBodies.any((t) => url.contains(t)) ? "FILTERED" : body?.toString()
    });

    if (log.length >= MAX_LOG_HISTORY) {
      log.removeAt(0);
    }
  }
}

enum Type { REQ, RSP }
