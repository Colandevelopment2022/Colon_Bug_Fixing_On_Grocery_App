import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:thought_factory/core/data/local/app_shared_preference.dart';
import 'package:thought_factory/core/data/remote/request_response/product/detail/product_detail_response.dart';
import 'package:thought_factory/core/model/profile/profile_info.dart';
import 'package:thought_factory/core/notifier/base/base_notifier.dart';
import 'package:thought_factory/core/notifier/common_notifier.dart';
import 'package:thought_factory/ui/login_screen.dart';
import 'package:thought_factory/ui/main/main_screen.dart';
import 'package:thought_factory/ui/menu/otp/otp_submit_api.dart';
import 'package:thought_factory/utils/app_constants.dart';

class OtpPresenter extends BaseNotifier {
  CommonNotifier commonNotifier = CommonNotifier();

  TextEditingController otp = TextEditingController();

  Timer _timer;
  int start = 30;
  Map<String, dynamic> data;

  Scaffold scaffold = Scaffold();

  OtpPresenter(context, this.data) {
    super.context = context;
    startTimer();
  }

  void startTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    } else {
      _timer = new Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) {
          if (start < 1) {
            timer.cancel();
          } else {
            start = start - 1;
          }
          notifyListeners();
        },
      );
    }
  }

  void updateTime() {
    _timer = null;
    start = 60;
    startTimer();
  }

  void otpSubmitApiCall(Map<String, dynamic> data) {
    if (otp.text.trim().isEmpty) return;
    if (otp.text.trim().isNotEmpty && otp.text.length != 4) return;
    Map<String, dynamic> b = {};
    debugPrint('data ---- ${data}');
    super.isLoading = true;
    ProfileInfo profileInfo = data['profile_data'] as ProfileInfo;
    b['id'] = profileInfo.id;
    b['email'] = profileInfo.mailID;
    b['firstname'] = profileInfo.firstName;
    b['lastname'] = profileInfo.lastName;
    b['gender'] = 0;
    b['store_id'] = profileInfo.storeId;
    b['website_id'] = profileInfo.websSiteid;
    b['firstname'] = profileInfo.mailID;
    debugPrint('body ---- ${b}');
    List<CustomAttributes> custAtri = [];
    for (final CustomAttributes customAttributes
        in profileInfo.customAttributes) {
      if (customAttributes.attributeCode == 'trn_no') {
        custAtri.add(CustomAttributes(
            attributeCode: 'trn_no', value: customAttributes.value));
      } else if (customAttributes.attributeCode == 'company_name') {
        custAtri.add(CustomAttributes(
            attributeCode: 'company_name', value: customAttributes.value));
      } else if (customAttributes.attributeCode == 'customer_mobile') {
        custAtri.add(CustomAttributes(
            attributeCode: 'customer_mobile', value: data['mobile_number']));
      }
    }
    b['custom_attributes'] = custAtri;
    Map<String, dynamic> body = {};
    body['customer'] = b;
    body['mobile'] = data['mobile_number'];
    body['otp'] = otp.text.toString();
    body['websiteId'] = profileInfo.websSiteid;
    debugPrint('final data --- ${body}');
    otpSubmitApi(body).then((value) {
      super.isLoading = false;
      Map<String, dynamic> response = jsonDecode(value) as Map<String, dynamic>;
      if (response.containsKey('message') && response['message'] != '') {
        debugPrint('otp response --- ${value}');
        commonNotifier.showSnackBarContextDuration(
            context, response['message'] as String, 1);
      } else {
        profileInfo.mobileNumber = data['mobile_number'];
        Navigator.of(context).pop();
      }
    });
  }

  void logout() {
    _clearUserCredential().whenComplete(() {
      Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.routeName, ModalRoute.withName(MainScreen.routeName));
    });
  }

  Future _clearUserCredential() async {
    await AppSharedPreference().saveUserToken("");
    await AppSharedPreference()
        .saveStringValue(AppConstants.KEY_USER_EMAIL_ID, "");
    await AppSharedPreference()
        .saveStringValue(AppConstants.KEY_USER_PASSWORD, "");
    AppSharedPreference().removeTokenDetails();
  }
}
