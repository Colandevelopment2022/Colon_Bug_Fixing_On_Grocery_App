import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thought_factory/core/data/remote/network/app_url.dart';
import 'package:thought_factory/core/data/remote/request_response/user/user_detail_response.dart';
import 'package:thought_factory/utils/environment_varriables.dart';

Uri invoiceurl = Uri.parse(
    "https://${EnvVarriables.env == 'dev' ? AppUrl.debugHost : AppUrl.baseHost}${EnvVarriables.env == 'dev' ? "/dev" : ''}/rest/V1/invoicedownload");
var data;
var urldata;

class DownloadInvoice {
  static var orderid;
}

Future<bool> GetInvoice() async {
  Map body = {
    "data": {
      "increment_id": "${DownloadInvoice.orderid}",
      "customer_id": "${receivedcustomerid}",
    }
  };
  print(jsonEncode(body));
  http.Response response = await http.post(
    invoiceurl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode(body),
  );
  print(response.body);
  urldata = jsonDecode(response.body);
  data = response.body;
  print("Get Invoice Done");
  print(data);
  if (data != "[]" || response.body != "[]") {
    return true;
  } else {
    return false;
  }
}
