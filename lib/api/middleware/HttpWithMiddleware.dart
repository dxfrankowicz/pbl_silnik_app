import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

///Class to be used by the user as a replacement for 'http' with middleware supported.
///call the `build()` constructor passing in the list of middlewares.
///Example:
///```dart
/// HttpWithMiddleware http = HttpWithMiddleware.build(middlewares: [
///     Logger(),
/// ]);
///```
///Then call the functions you want to, on the created `http` object.
///```dart
/// http.get(...);
/// http.post(...);
/// http.put(...);
/// http.delete(...);
/// http.head(...);
/// http.patch(...);
/// http.read(...);
/// http.readBytes(...);
///```
class HttpWithMiddleware {
  List<InterceptorContract> middlewares;
  Duration requestTimeout;

  HttpWithMiddleware._internal({
    this.middlewares,
    this.requestTimeout,
  });

  factory HttpWithMiddleware.build({
    List<InterceptorContract> middlewares,
    Duration requestTimeout,
  }) {
    //Remove any value that is null.
    middlewares?.removeWhere((middleware) => middleware == null);
    return new HttpWithMiddleware._internal(
        middlewares: middlewares, requestTimeout: requestTimeout);
  }

  Future<Response> head(url, {Map<String, String> headers}) {
    _sendInterception(method: Method.HEAD, headers: headers, url: url);
    return _withClient((client) => client.head(url, headers: headers));
  }

  Future<Response> get(url, {Map<String, String> headers, body}) {
    RequestData data =
    _sendInterception(method: Method.GET, headers: headers, url: url);
    return _withClient((client) => client.get(data.url, headers: data.headers));
  }

  Future<Response> post(url,
      {Map<String, String> headers, body, Encoding encoding}) {
    RequestData data = _sendInterception(
        method: Method.POST,
        headers: headers,
        url: url,
        body: body,
        encoding: encoding);
    return _withClient((client) => client.post(data.url,
        headers: data.headers, body: data.body, encoding: data.encoding));
  }

  Future<Response> put(url,
      {Map<String, String> headers, body, Encoding encoding}) {
    RequestData data = _sendInterception(
        method: Method.PUT,
        headers: headers,
        url: url,
        body: body,
        encoding: encoding);
    return _withClient((client) => client.put(data.url,
        headers: data.headers, body: data.body, encoding: data.encoding));
  }

  Future<Response> patch(url,
      {Map<String, String> headers, body, Encoding encoding}) {
    RequestData data = _sendInterception(
        method: Method.PATCH,
        headers: headers,
        url: url,
        body: body,
        encoding: encoding);
    return _withClient((client) => client.patch(data.url,
        headers: data.headers, body: data.body, encoding: data.encoding));
  }

  Future<Response> delete(url, {Map<String, String> headers}) {
    RequestData data =
    _sendInterception(method: Method.DELETE, headers: headers, url: url);
    return _withClient(
            (client) => client.delete(data.url, headers: data.headers));
  }

  Future<String> read(url, {Map<String, String> headers}) {
    return _withClient((client) => client.read(url, headers: headers));
  }

  Future<Uint8List> readBytes(url, {Map<String, String> headers}) =>
      _withClient((client) => client.readBytes(url, headers: headers));

  Future<Response> multipart(url,
      {Map<String, String> headers, body, Encoding encoding, MultipartFile multipartFile}) {
    RequestData data = _sendInterception(
        method: Method.POST,
        headers: headers,
        url: url,
        body: body,
        encoding: encoding);
    MultipartRequest multipartRequest = new MultipartRequest("POST", Uri.parse(url));
    multipartRequest.files.add(multipartFile);
    data.headers.forEach((k,v)=>multipartRequest.headers.putIfAbsent(k, ()=>v));
    data.body.forEach((k,v)=>multipartRequest.fields.putIfAbsent(k, ()=>v));

    return _withMultipartClient(multipartRequest);
  }

  RequestData _sendInterception(
      {Method method,
        Encoding encoding,
        dynamic body,
        String url,
        Map<String, String> headers}) {
    RequestData data = RequestData(
        method: method,
        encoding: encoding,
        body: body,
        baseUrl: url,
        headers: headers ?? <String, String>{});
    middlewares
        ?.forEach((middleware) => middleware.interceptRequest(data: data));
    return data;
  }

  Future<T> _withClient<T>(Future<T> fn(Client client)) async {
    var client = new Client();
    try {
      T response = requestTimeout == null
          ? await fn(client)
          : await fn(client).timeout(requestTimeout);
      if (response is Response) {
        var responseData = ResponseData.fromHttpResponse(response);
        middlewares?.forEach(
                (middleware) => middleware.interceptResponse(data: responseData));

        Response resultResponse = Response(
          responseData.body,
          responseData.statusCode,
          headers: responseData.headers,
          persistentConnection: responseData.persistentConnection,
          isRedirect: responseData.isRedirect,
          request: Request(
            responseData.method.toString().substring(7),
            Uri.parse(responseData.url),
          ),
        );

        return resultResponse as T;
      }
      return response;
    } finally {
      client.close();
    }
  }

  // ignore: missing_return
  Future<Response> _withMultipartClient<T>(MultipartRequest client) async {
    StreamedResponse streamedResponse = await client.send();
    try {
      var response = await Response.fromStream(streamedResponse);
      if (response is Response) {
        var responseData = ResponseData.fromHttpResponse(response);
        middlewares?.forEach(
                (middleware) => middleware.interceptResponse(data: responseData));

        Response resultResponse = Response(
          responseData.body,
          responseData.statusCode,
          headers: responseData.headers,
          persistentConnection: responseData.persistentConnection,
          isRedirect: responseData.isRedirect,
          request: MultipartRequest(
            responseData.method.toString().substring(7),
            Uri.parse(responseData.url),
          ),
        );

        return resultResponse;
      }
    }
    catch(e){
      Response resultResponse = Response(
        e.toString(),
        422
      );
      return resultResponse;
    }
  }
}
