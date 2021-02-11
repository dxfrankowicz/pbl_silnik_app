import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:logging/logging.dart';
import '../middleware/HttpLoggerMiddleware.dart';

class HttpLogger {
  LogLevel logLevel;
  int maxBodySize;
  final Logger logger = new Logger("HttpLogger");
  static const nonLoggableBodies = ["storage"];
  static const maskedHeaders = ["Authorization"];

  HttpLogger({this.logLevel, this.maxBodySize = 1024});

  void logRequest({RequestData data}) {
    String method = data.method.toString().split(".")[1];

    int bodyInBytes =
        data.body != null ? (utf8.encode(data.body.toString()).length) : 0;

    if (logLevel == LogLevel.BASIC) {
      logger.info("--> ${method}common.dart ${data.url} ($bodyInBytes-byte Body)");
      return;
    }

    bool logBody = logLevel == LogLevel.BODY;
    bool logHeaders = logBody || logLevel == LogLevel.HEADERS;

    if (logHeaders) {
      logger.info("--> ${data.method.toString().split(".")[1]} ${data.url}");

      logger.info("HEADERS:");
      Map<String, String> headers = data.headers;
      if (headers == null || headers.length == 0) {
        logger.info("Request has no headers.");
      } else {
        StringBuffer headersBuffer = StringBuffer();
        headers.forEach((key, value) => maskedHeaders.contains(key)
            ? headersBuffer.write("$key: ${MaskUtils.mask(value)};")
            : headersBuffer.write("$key: $value;"));
        logger.info(headersBuffer.toString());
      }

      //Log the request body
      if (logBody) {
        logger.info("BODY:");
        if (data.body == null) {
          logger.info("Request has no body.");
        } else if(nonLoggableBodies.any((t) => data.url.contains(t))) {
          logger.info("Filtered body.");
        } else {
          _logBody(data.body);
        }
      }
    }

    logger.info("--> END $method\n");
  }

  void logResponse({ResponseData data}) {
    if (logLevel == LogLevel.NONE) {
      return;
    }

    if (logLevel == LogLevel.BASIC) {
      logger.info("<-- ${data.statusCode} (${data.contentLength}-byte Body)");
      return;
    }

    String method = data.method.toString().split(".")[1];

    logger.info("<-- $method ${data.statusCode}");

    bool logBody = logLevel == LogLevel.BODY;
    bool logHeaders = logBody || logLevel == LogLevel.HEADERS;

    if (logHeaders) {
      logger.info("URL: ${data.url}");
      logger.info("HEADERS:");
      Map<String, String> headers = data.headers;
      if (headers == null || headers.length == 0) {
        logger.info("Request has no headers.");
      } else {
        StringBuffer headersBuffer = StringBuffer();
        headers.forEach((key, value) => headersBuffer.write("$key: $value;"));
        logger.info(headersBuffer.toString());
      }

      //Log the request body
      if (logBody) {
        logger.info("BODY:");
        if (data.body == null || data.body.length == 0) {
          logger.info("Request has no body.");
        } else if(nonLoggableBodies.any((t) => data.url.contains(t))) {
          logger.info("Filtered body.");
        } else {
          _logBody(data.body);
        }
      }
    }

    logger.info("<-- END HTTP");
  }

  void _logBody(dynamic body) {
    if (body is String) {
      var formattedBody;
      try {
        formattedBody = new JsonEncoder.withIndent('  ').convert(json.decode(body));
      }
      catch(e){
        formattedBody = "Response body could not be converted to JSON: $e}";
        formattedBody += "\nRAW BODY: $body";
      }
      if (maxBodySize != -1 && formattedBody.length > maxBodySize) {
        formattedBody = formattedBody.substring(0, maxBodySize);
      }

      formattedBody.split("\n").forEach((s) {
        logger.info(s);
      });
    } else if (body is Map) {
      var formattedBody =
      new JsonEncoder.withIndent('  ').convert(json.decode(json.encode(body)));
      if (maxBodySize != -1 && formattedBody.length > maxBodySize) {
        formattedBody = formattedBody.substring(0, maxBodySize);
      }

      formattedBody.split("\n").forEach((s) {
        logger.info(s);
      });
    }
  }
}

enum LogLevel {
  NONE,
  BASIC,
  HEADERS,
  BODY,
}
