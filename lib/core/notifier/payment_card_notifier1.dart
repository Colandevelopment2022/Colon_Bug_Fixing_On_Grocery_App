import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thought_factory/core/data/local/app_shared_preference.dart';
import 'package:thought_factory/core/data/remote/repository/common_repository.dart';
import 'package:thought_factory/core/data/remote/repository/manage_payment_repository.dart';
import 'package:thought_factory/core/data/remote/repository/order_confirmation_repository.dart';
import 'package:thought_factory/core/data/remote/repository/product_repository.dart';
import 'package:thought_factory/core/data/remote/request_response/cart/create_order/CreateOrderRequest.dart';
import 'package:thought_factory/core/data/remote/request_response/cart/create_order/create_order_response.dart';
import 'package:thought_factory/core/data/remote/request_response/cart/get_order_by_id/CreateOrderByIdResponse.dart';
import 'package:thought_factory/core/data/remote/request_response/manage_payment/add_new_card_request.dart';
import 'package:thought_factory/core/data/remote/request_response/manage_payment/manage_payment_response.dart';
import 'package:thought_factory/core/data/remote/request_response/product/card/PaymentCardRequest.dart';
import 'package:thought_factory/core/data/remote/request_response/product/card/PaymentCardResponse.dart';
import 'package:thought_factory/core/model/payment_api_response_model.dart';
import 'package:thought_factory/core/model/payment_request.dart';
import 'package:thought_factory/core/notifier/common_notifier.dart';
import 'package:thought_factory/ui/order/order_confirmation_screen.dart';
import 'package:thought_factory/ui/web_view/etisalat_web_view.dart';
import 'package:thought_factory/utils/app_constants.dart';
import 'package:thought_factory/utils/app_log_helper.dart';
import 'package:thought_factory/utils/widgetHelper/alert_overlay.dart';

import 'base/base_notifier.dart';
var storedOrderId;
var storedAmount;
class PaymentCardNotifier1 extends BaseNotifier {
  final log = getLogger('PaymentCardNotifier');
  final _productRepository = ProductRepository();

  final _commonRepository = CommonRepository();
  final _paymentCardsRepository = ManagePaymentRepository();
  final OrderConfirmationRepository _orderConfirmationRepository =
      OrderConfirmationRepository();

  static const platform = const MethodChannel('com.etisalat');

  int selectedCardIndex = 1;
  String _cartResponseId = "", grandTotalAmt = "", orderId = "", orderName = "";
  String textCardNumber = "", textExpMonth = "", textExpYear = "", textCvv = "";

  String get cartResponseId => _cartResponseId;

  GetOrderByIdResponse _getOrderByIdResponse = GetOrderByIdResponse();

  List<NewCard> _paymentCardsList = List();

  List<NewCard> get paymentCardsList => _paymentCardsList;

  Map<String, dynamic> cartData;

  set paymentCardsList(List<NewCard> value) {
    _paymentCardsList = value;
    notifyListeners();
  }

  //constructor
  PaymentCardNotifier1(context, Map<String, dynamic> cartResponseId) {
    super.context = context;
    // this._cartResponseId = cartResponseId;
    debugPrint('cart id --- $cartResponseId');
    // callApiGetOrderById(cartResponseId);
    this.cartData = cartResponseId;
    setDataForListCards();
  }

  GetOrderByIdResponse get getOrderByIdResponse => _getOrderByIdResponse;

  set getOrderByIdResponse(GetOrderByIdResponse value) {
    _getOrderByIdResponse = value;
    notifyListeners();
  }

  void getOrderId() {
    callApiPayment(cartData['payment_method'], cartData['shipping_code'],
            cartData['carrier_code'])
        .then((value) {
      log.i("cartResponseId Value : -------------> $value");

      if (value != null) {
        if (value.cartResponseId != null && value.cartResponseId.isNotEmpty) {
          _cartResponseId = value.cartResponseId;
          paymentGateWayCall();
        } else {
          // showSnackBarMessageWithContext(value.message);
          paymentGateWayCall();
        }
      } else {
        showSnackBarMessageWithContext(AppConstants.ERROR);
      }
    });
  }

  void paymentGateWayCall() {
    PaymentCardRequest paymentCardRequest = new PaymentCardRequest();
    paymentCardRequest.authorization = new Authorization();

    paymentCardRequest.authorization.cardNumber =
        textCardNumber.replaceAll(new RegExp(r"\s+"), "");
    paymentCardRequest.authorization.expiryMonth = textExpMonth;
    paymentCardRequest.authorization.expiryYear = textExpYear;
    paymentCardRequest.authorization.verifyCode = textCvv;
    paymentCardRequest.authorization.orderName = "paybill";
        // orderName.length > 20 ? orderName.substring(0, 20) : orderName;
    paymentCardRequest.authorization.orderID = storedOrderId;
    print("came in paymentgateway");
    print(paymentCardRequest.authorization.orderID);
    paymentCardRequest.authorization.amount = storedAmount;
    print(paymentCardRequest.authorization.amount);
    //Manual data
    paymentCardRequest.authorization.customer = "THOUGHT FACTORY";
    paymentCardRequest.authorization.language = "en";
    paymentCardRequest.authorization.transactionHint = "CPT:Y;VCC:Y;";
    paymentCardRequest.authorization.channel = "Web";
    paymentCardRequest.authorization.currency = "AED";
    paymentCardRequest.authorization.userName = "TF_sukaina";
    paymentCardRequest.authorization.password = "[xq{k2mcaH8tSg";

    if (validateCardDetails()) {
      debugPrint('order id storedOrderID -----> ${storedOrderId}');
      debugPrint('order id ----   ${orderId}');
      if (paymentCardRequest.authorization != null &&
          paymentCardRequest.authorization.orderID != null &&
          paymentCardRequest.authorization.orderID.isNotEmpty) {
        _onPressedButtonPayNow(this);
      } else {
        callApiGetOrderById(cartResponseId);
        return;
      }
    } else {
      showToast("Please choose a "
          "card to Pay");
    }
  }

  void _onPressedButtonPayNow(notifier) async {
    PaymentCardRequest paymentCardRequest = new PaymentCardRequest();
    paymentCardRequest.authorization = new Authorization();

    //Entered value
    paymentCardRequest.authorization.cardNumber =
        notifier.textCardNumber.replaceAll(new RegExp(r"\s+"), "");
    paymentCardRequest.authorization.expiryMonth = notifier.textExpMonth;
    paymentCardRequest.authorization.expiryYear = notifier.textExpYear;
    paymentCardRequest.authorization.verifyCode = notifier.textCvv;
    paymentCardRequest.authorization.orderName = "paybill";
    // notifier.orderName.length > 20 ? notifier.orderName.substring(0, 20) : notifier.orderName;
    paymentCardRequest.authorization.orderID = orderId;
    paymentCardRequest.authorization.amount = notifier.grandTotalAmt;
    storedAmount = notifier.grandTotalAmt;
    //Manual data
    paymentCardRequest.authorization.customer = 'THOUGHT FACTORY';
    paymentCardRequest.authorization.language = "en";
    paymentCardRequest.authorization.transactionHint = "CPT:Y;VCC:Y;";
    paymentCardRequest.authorization.channel = "Web";
    paymentCardRequest.authorization.currency = "AED";
    paymentCardRequest.authorization.userName = "TF_sukaina";
    paymentCardRequest.authorization.password = "[xq{k2mcaH8tSg";
    notifier.isLoading = true;
    await paymentRegistration(context,
            customer: paymentCardRequest.authorization.customer,
            orderName: paymentCardRequest.authorization.orderName,
            orderID: paymentCardRequest.authorization.orderID,
            currency: paymentCardRequest.authorization.currency,
            language: paymentCardRequest.authorization.language,
            channel: paymentCardRequest.authorization.channel,
            amount: paymentCardRequest.authorization.amount,
            transactionHint: paymentCardRequest.authorization.transactionHint,
            cardNumber: paymentCardRequest.authorization.cardNumber,
            expiryMonth: paymentCardRequest.authorization.expiryMonth,
            expiryYear: paymentCardRequest.authorization.expiryYear,
            verifyCode: paymentCardRequest.authorization.verifyCode,
            userName: paymentCardRequest.authorization.userName,
            password: paymentCardRequest.authorization.password,
            paymentCardNotifier: notifier)
        .then((returnResponse) {
      if (Platform.isAndroid) {
        print("android screen");
        // if (returnResponse.length == 3 &&
        //     returnResponse.values.elementAt(0) == "Success") {
        print("check 1");
        // print(returnResponse.values.elementAt(0));
        var paymentDetails = {};
        paymentDetails['order_id'] = notifier.cartResponseId;
        storedOrderId = notifier.cartResponseId;
         print(storedOrderId);
        debugPrint("notifier cartResponseId-----> ${storedOrderId}");
        String status = returnResponse[1] as String;
        if (status == "Success") {
          Map<String, dynamic> paymentDetails = {};
          paymentDetails['transaction_id'] = returnResponse[4] as String;
          paymentDetails['web_portal_url'] = returnResponse[2] as String;
          Navigator.pushNamed(context, EtisalatWebView.routeName,
              arguments: paymentDetails);
        } else
          showToast("Something went wrong");
      } else if (Platform.isIOS) {
        print("ios screen");
        if (returnResponse != null) {
          if (returnResponse[0][1] == "Success") {
            List<dynamic> ret = returnResponse;
            var paymentDetails = {};
            paymentDetails['order_id'] = "1645";
            paymentDetails['transaction_id'] = ret.elementAt(0)[3];
            Navigator.pushNamed(context, OrderConfirmationScreen.routeName,
                arguments: paymentDetails);
          } else if (returnResponse[0][1] == "Error") {
            showDialog(
              context: context,
              builder: (_) => AlertOverlay(
                  AppConstants.ALERT, returnResponse[0][1], AppConstants.OKAY),
            );
          }
        }
      }
    });
  }

  Future<String> _getCustomerName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.KEY_CUSTOMER_NAME) ?? '';
  }

  Future<dynamic> _startActivity(
      {String customer,
      String language,
      String currency,
      String orderName,
      String orderID,
      String channel,
      String amount,
      String transactionHint,
      String cardNumber,
      String expiryMonth,
      String expiryYear,
      String verifyCode,
      String userName,
      String password,
      PaymentCardNotifier1 paymentCardNotifier}) async {
    var sendHashMap = <String, dynamic>{
      'Customer': customer,
      'Language': language,
      'Currency': currency,
      'OrderName': orderName,
      'OrderID': orderID,
      'Channel': channel,
      'Amount': amount,
      'TransactionHint': transactionHint,
      'CardNumber': cardNumber,
      'ExpiryMonth': expiryMonth,
      'ExpiryYear': expiryYear,
      'VerifyCode': verifyCode,
      'UserName': userName,
      'Password': password
    };
    try {
      var result =
          await platform.invokeMethod('StartSecondActivity', sendHashMap);
      if (result != null) {
        if (result is Map<int, String>) {
          Map<int, String> response = result;
          if (response.length == 2) {
            for (int i = 0; i < response.length; i++) {
              print(">>> " + response.values.elementAt(i));
            }
          }
        }
      }
      paymentCardNotifier.isLoading = false;
      debugPrint('Result: $result ');
      return result;
    } on PlatformException catch (e) {
      paymentCardNotifier.isLoading = false;
      debugPrint("Error: '${e.message}'.");
      return null;
    }
  }

  Future<dynamic> paymentRegistration(BuildContext context,
      {String customer,
      String language,
      String currency,
      String orderName,
      String orderID,
      String channel,
      String amount,
      String transactionHint,
      String cardNumber,
      String expiryMonth,
      String expiryYear,
      String verifyCode,
      String userName,
      String password,
      PaymentCardNotifier1 paymentCardNotifier}) async {

    var sendHashMap = <String, dynamic>{
      'Currency': "AED",
      'ReturnPath': "https://localhost/callbackURL",
      'TransactionHint': "CPT:Y;VCC:Y;",
      'OrderID': storedOrderId,
      "Store": "MobileAPP",
      "Terminal": "MobileAPP",
      "Channel": "Web",
      'Amount': storedAmount,
      'Customer': 'THOUGHT FACTORY',
      'OrderName': "Paybill",
      'UserName': 'TF_sukaina',
      'Password': '[xq{k2mcaH8tSg'
    };
    print(jsonEncode(sendHashMap));
    try {
      var res = await platform.invokeMethod('registration', sendHashMap);
      Map<dynamic, dynamic> result = res as Map;
      paymentCardNotifier.isLoading = false;
      debugPrint('Result: $result ');
      return result;
    } on PlatformException catch (e) {
      paymentCardNotifier.isLoading = false;
      debugPrint("Error: '${e.message}'.");
      return null;
    }
  }

  //get: payment Information
  Future<CreateOrderResponse> callApiPayment(
      String paymentMethod, String shippingCode, String carrierCode) async {
    super.isLoading = true;
    CreateOrderResponse response =
        await _commonRepository.apiPaymentInformation(
            buildCreateOrderRequest(paymentMethod, shippingCode, carrierCode));
    super.isLoading = false;
    if (response != null) {
      return response;
    } else {
      return null;
    }
  }

  // build create order request
  CreateOrderRequest buildCreateOrderRequest(
      paymentMethod, shippingCode, carrierCode) {
    return CreateOrderRequest(
      cartId: CommonNotifier().quoteId,
      paymentMethod: PaymentMethod(method: paymentMethod),
    );
  }

  //api: get order by id
  Future<void> callApiGetOrderById(String id) async {
    super.isLoading = true;
    try {
      GetOrderByIdResponse response =
          await _orderConfirmationRepository.apiGetOrderByIdResponse(id);
      onNewGetOrderResponse(response);
      // super.isLoading = false;
      return;
    } catch (e) {
      log.e("Error :" + e.toString());
      super.isLoading = false;
    }
  }

  Future setDataForListCards() async {
    super.isLoading = true;
    String customerID = await AppSharedPreference().getCustomerId();
    PaymentCardsListRequest paymentCardRequest = PaymentCardsListRequest(
        paymentcard: PaymentCard(
      customer_id: customerID,
      //   phoneNumber: textEditConPhoneNumber.text,
    ));
    await _paymentCardsRepository
        .apiPaymentCardsListDetail(
            paymentCardRequest, CommonNotifier().userToken)
        .then((value) {
      if (value != null) {
        _onNewPaymentCardsDetailResponse(value);
      }
    });
    super.isLoading = false;
  }

  void _onNewPaymentCardsDetailResponse(ManagePaymentListResponse value) {
    paymentCardsList.clear();
    if (value.status == 1 && value.data.length > 0) {
      paymentCardsList = value.data;
    }
  }

  void onNewGetOrderResponse(GetOrderByIdResponse response) {
    if (response != null) {
      getOrderByIdResponse = response;
      //fill required data orderName, orderID & grandTotalAmt
      if (response.extensionAttributes != null &&
          response.extensionAttributes.shippingAssignments != null &&
          response.extensionAttributes.shippingAssignments[0].items[0] != null)
        orderName =
            response.extensionAttributes.shippingAssignments[0].items[0].name ??
                "";
      orderId = response.incrementId ?? "";
      if (response.baseTotalDue != null) {
        grandTotalAmt = convertToDecimal(response.baseTotalDue.toString(), 2);
      }

      _onPressedButtonPayNow(this);
    }
  }

// get sub category list
  Future<PaymentCardResponse> callApiCardPayment(
      PaymentCardRequest paymentCardRequest) async {
    log.i('api ::: GetSubCategoryList called');
    //super.isLoading = true;
    PaymentCardResponse paymentCardResponse =
        await _commonRepository.cardPayment(paymentCardRequest);
    //super.isLoading = false;
    return paymentCardResponse;
  }

  //api: cart quote id
  Future<String> callApiCartQuoteId() async {
    super.isLoading = true;
    String response = await _orderConfirmationRepository
        .apiCartQuoteIdResponse()
        .whenComplete(() {
      super.isLoading = false;
    });
    if (response != null) {
      return response;
    } else {
      return null;
    }
  }

  bool validateCardDetails() {
    return (textCardNumber.isNotEmpty &&
        textExpMonth.isNotEmpty &&
        textExpYear.isNotEmpty &&
        textCvv.isNotEmpty);
  }

  void updateSelectedCard(NewCard item) {
    textCardNumber = item.card_no;
    textExpMonth = item.exp_month;
    textExpYear = item.exp_year;
    textCvv = item.cvv;
  }

  void resetSelectedCard() {
    selectedCardIndex = -1;
    textCardNumber = "";
    textExpMonth = "";
    textExpYear = "";
    textCvv = "";
  }

  //payment notifier

  Future<PaymentResponse> paymentApi(
      String Customer,
      String Language,
      String Currency,
      String OrderName,
      String OrderID,
      String Channel,
      String Amount,
      String TransactionHint,
      String CardNumber,
      String ExpiryMonth,
      String ExpiryYear,
      String VerifyCode,
      String UserName,
      String Password) async {
    log.i('api ::: apiCreateGroup called');
    isLoading = true;
    PaymentResponse response = PaymentResponse();
    try {
      response = await _productRepository.apiPaymentgateway(PaymentRequest(
        customer: Customer,
        language: Language,
        currency: Currency,
        orderName: OrderName,
        orderID: OrderID,
        channel: Channel,
        amount: Amount,
        transactionHint: TransactionHint,
        cardNumber: CardNumber,
        expiryMonth: ExpiryMonth,
        expiryYear: ExpiryYear,
        verifyCode: VerifyCode,
        userName: UserName,
        password: Password,
      ));

      log.i('respose : ${response.toString()}');
      isLoading = false;
    } catch (e) {
      log.e(e.toString());
      isLoading = false;
    }
    return response;
  }
}
