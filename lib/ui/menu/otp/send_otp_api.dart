import 'dart:convert';

import 'package:http/http.dart' as http;

Uri sendotp = Uri.parse("https://ebazaar.ae/rest//V1/sendotp");

Future<String > SendOtp(String mobileNumber) async {
  Map body = {
    "resend": 1,
    "storeId": 1,
    "mobile": '$mobileNumber',
    "eventType": 'customer_account_edit_otp'
  };
  print(jsonEncode(body));
  http.Response response = await http.post(
    sendotp,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode(body),
  );
  return response.body;
  print(response.body);
}
