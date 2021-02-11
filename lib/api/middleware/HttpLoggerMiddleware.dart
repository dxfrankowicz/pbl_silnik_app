import 'package:http_interceptor/http_interceptor.dart';
import '../utils/http_logger.dart';

class HttpLoggerMiddleware implements InterceptorContract {
  HttpLogger logger;

  HttpLoggerMiddleware({LogLevel logLevel, maxBodySize}) {
    logger = HttpLogger(logLevel: logLevel, maxBodySize: maxBodySize);
  }

  @override
  Future<RequestData> interceptRequest({RequestData data}) async{
    logger.logRequest(data: data);
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async{
    logger.logResponse(data: data);
    return data;
  }

  void setLogLevel(LogLevel value) {
    logger.logLevel = value;
  }
}

class MaskUtils {
  static String mask(String value, {int prefixLeft = 10, int maxMaskedChars = 3, String mask = "*"}) {
    if (value == null || value.length == 0) return "";

    String maskedValue = "";
    if (value.length > prefixLeft) {
      maskedValue = value.substring(0, prefixLeft);
    } else {
      maskedValue = value;
    }

    var maskedLeft = value.length - maskedValue.length;
    if (maxMaskedChars != -1 && maskedLeft > maxMaskedChars) {
      maskedLeft = maskedValue.length + maxMaskedChars;
    }
    return maskedValue.padRight(maskedLeft, mask);
  }
}