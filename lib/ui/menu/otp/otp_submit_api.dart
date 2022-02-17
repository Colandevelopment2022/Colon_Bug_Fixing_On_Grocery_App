import 'dart:convert';

import 'package:http/http.dart' as http;

Uri sendotp = Uri.parse("https://ebazaar.ae/rest/V1/customereditwithotp");

Future<String> otpSubmitApi(Map<String, dynamic> body) async {
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
}
