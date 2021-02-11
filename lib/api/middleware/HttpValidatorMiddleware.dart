import 'package:http_interceptor/http_interceptor.dart';

class HttpValidatorMiddleware implements InterceptorContract {
  static const Map<String, String> errorWhitelist = {
    "contribution": "Nothing to pay",
    "matches": "This action is unauthorized",
    "training": "This action is unauthorized",
    "diary": "errors"
  };

  @override
  Future<RequestData> interceptRequest({RequestData data}) async{
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async{
    bool isErrorWhiteListed = false;
    if (data != null && (data.statusCode < 200 || data.statusCode > 300)) {
      errorWhitelist.forEach((url, rsp) {
        if (data.url.contains(url) && data.body.toLowerCase().contains(rsp.toLowerCase())) {
          isErrorWhiteListed = true;
          return;
        }
      });
      if(!isErrorWhiteListed)
        throw data.body;
    }
    return data;
  }
}
