import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const platform = const MethodChannel('com.etisalat');

class EtisalatPayment {
  Future<dynamic> paymentRegistration({String orderId, String amount}) async {
    var sendHashMap = <String, dynamic>{
      'Currency': "AED",
      'ReturnPath': "https://localhost/callbackURL",
      'TransactionHint': "CPT:Y;VCC:Y;",
      'OrderID': orderId,
      "Store": "MobileAPP",
      "Terminal": "MobileAPP",
      "Channel": "Web",
      'Amount': amount,
      'Customer': 'THOUGHT FACTORY',
      'OrderName': "Paybill",
      'UserName': 'TF_sukaina',
      'Password': '[xq{k2mcaH8tSg'
    };
    print(jsonEncode(sendHashMap));
    try {
      var res = await platform.invokeMethod('registration', sendHashMap);
      return res;
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
      return null;
    }
  }
}
