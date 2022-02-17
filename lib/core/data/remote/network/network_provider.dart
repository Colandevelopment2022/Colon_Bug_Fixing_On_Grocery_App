import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show Client;
import 'package:http/http.dart';
import 'package:thought_factory/utils/app_log_helper.dart';
import 'package:thought_factory/utils/environment_varriables.dart';

import 'app_url.dart';
import 'method.dart';

class NetworkProvider {
  final log = getLogger('NetworkProvider HTTP');

  // singleton boilerplate
  NetworkProvider._internal();

  static final NetworkProvider _singleInstance = NetworkProvider._internal();

  factory NetworkProvider() => _singleInstance;

  Client client = Client();

  Duration timeout = Duration(minutes: 2);

  final String _tagRequest = '::::: Request :::::';
  final String _tagResponse = '----- Response -----';

  Future call(
      {@required String pathUrl,
      var queryParam,
      headers,
      Encoding encoding,
      @required Method method,
      Map<String, dynamic> body}) async {
    var responseData;

    var url;
    print('print1  : $queryParam');
    String path = pathUrl;
    if (EnvVarriables.env == 'dev') path = "/dev" + path;
    if (queryParam == null) {
      url = Uri.parse(AppUrl.baseUrl + path);
      print('print2:$url');
    } else {
      url = Uri.https(
          AppUrl.baseUrl.replaceAll('https://', ''), path, queryParam);
    }
    log.i('$headers \n $url');
    log.i('$_tagRequest \n $url');
    // log.i('Request header ::: ${json.encode(headers).toString()}');
    //log.i('Request encoding ::: ${json.encode(encoding).toString()}');
    log.i('Request body ::: ${json.encode(body).toString()}');
    switch (method) {
      case Method.GET:
        try {
          responseData =
              await client.get(url, headers: headers).timeout(timeout);
        } on Exception catch (e) {
          if (e is TimeoutException) {
            log.i('TimeOut responseData ::: $e');
            log.i('TimeOut responseData ::: ${responseData}');
            log.i('TimeOut responseData String::: ${responseData.toString()}');
            return '{message:Request time out}';
          } else
            return '{message:Server error}';
        }
        break;
      case Method.POST:
        try {
          responseData = await client
              .post(url, body: json.encode(body), headers: headers)
              .timeout(timeout);
        } on Exception catch (e) {
          if (e is TimeoutException) {
            log.i('TimeOut responseData ::: $e');
            log.i('TimeOut responseData ::: ${responseData}');
            log.i('TimeOut responseData String::: ${responseData.toString()}');
            return '{"message":"Request time out"}';
          } else
            return '{"message":"Server error"}';
        }
        break;
      case Method.PUT:
        try {
          responseData = await client
              .put(url, body: json.encode(body), headers: headers)
              .timeout(timeout);
        } on Exception catch (e) {
          if (e is TimeoutException) {
            log.i('TimeOut responseData ::: $e');
            log.i('TimeOut responseData ::: ${responseData}');
            log.i('TimeOut responseData String::: ${responseData.toString()}');
            //return '{"message":"Request time out"}';
            return '{"message":"Request time out"}';
          } else
            return '{"message":"Server error"}';
        }
        break;
      case Method.DELETE:
        try {
          responseData =
              await client.delete(url, headers: headers).timeout(timeout);
        } on Exception catch (e) {
          if (e is TimeoutException) {
            log.i('TimeOut responseData ::: $e');
            log.i('TimeOut responseData ::: ${responseData}');
            log.i('TimeOut responseData String::: ${responseData.toString()}');
            return '{"message":"Request time out"}';
          } else
            return '{"message":"Server error"}';
        }
        break;
    }
    // log.i('$_tagResponse \n ${responseData.body}');

    return responseData;
  }

  Future callPayment(
      {@required String pathUrl,
      var queryParam,
      headers,
      Encoding encoding,
      @required Method method,
      Map<String, dynamic> body}) async {
    var responseData;

    var url;
    if (queryParam == null) {
      url = Uri.parse(AppUrl.paymentBaseUrl);
      // url = Uri.https(AppUrl.paymentBaseUrl,"");
    } else {
      url = Uri.https(pathUrl, queryParam);
    }
    log.i('$_tagRequest \n $url');
    log.i('Request header ::: ${json.encode(headers).toString()}');
    //log.i('Request encoding ::: ${json.encode(encoding).toString()}');
    log.i('Request body ::: ${json.encode(body).toString()}');
    switch (method) {
      case Method.GET:
        try {
          responseData =
              await client.get(url, headers: headers).timeout(timeout);
        } on Exception catch (e) {
          if (e is TimeoutException) {
            log.i('TimeOut responseData ::: $e');
            log.i('TimeOut responseData ::: ${responseData}');
            log.i('TimeOut responseData String::: ${responseData.toString()}');
            return '{message:Request time out}';
          } else
            return '{message:Server error}';
        }
        break;
      case Method.POST:
        try {
          Future.sync(() {
            responseData = client
                .post(url, body: json.encode(body), headers: headers)
                .timeout(timeout)
                .catchError((onErr) {
              log.d('OnError Called : ' + onErr.toString());
            });
          });
        } on Exception catch (e) {
          log.i('Exception responseData ::: $e');
          if (e is TimeoutException) {
            log.i('TimeOut responseData ::: $e');
            log.i('TimeOut responseData ::: ${responseData}');
            log.i('TimeOut responseData String::: ${responseData.toString()}');
            return '{"message":"Request time out"}';
          } else
            return '{"message":"Server error"}';
        }
        break;
      case Method.PUT:
        try {
          responseData = await client
              .put(url, body: json.encode(body), headers: headers)
              .timeout(timeout);
        } on Exception catch (e) {
          log.i('Exception responseData ::: $e');
          if (e is TimeoutException) {
            log.i('TimeOut responseData ::: $e');
            log.i('TimeOut responseData ::: ${responseData}');
            log.i('TimeOut responseData String::: ${responseData.toString()}');
            //return '{"message":"Request time out"}';
            return '{"message":"Request time out"}';
          } else
            return '{"message":"Server error"}';
        }
        break;
      case Method.DELETE:
        try {
          responseData =
              await client.delete(url, headers: headers).timeout(timeout);
        } on Exception catch (e) {
          if (e is TimeoutException) {
            log.i('TimeOut responseData ::: $e');
            log.i('TimeOut responseData ::: ${responseData}');
            log.i('TimeOut responseData String::: ${responseData.toString()}');
            return '{"message":"Request time out"}';
          } else
            return '{"message":"Server error"}';
        }
        break;
    }
    log.i('$_tagResponse \n ${responseData.body}');

    return responseData;
  }
}
