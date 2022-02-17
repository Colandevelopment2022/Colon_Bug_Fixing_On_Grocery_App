import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thought_factory/core/data/remote/repository/order_confirmation_repository.dart';
import 'package:thought_factory/core/data/remote/request_response/cart/get_order_by_id/CreateOrderByIdResponse.dart';
import 'package:thought_factory/core/notifier/base/base_notifier.dart';
import 'package:thought_factory/utils/app_log_helper.dart';
import 'package:thought_factory/core/notifier/payment_card_notifier1.dart';

class OrderConfirmationNotifier extends BaseNotifier {
  final log = getLogger('OrderConfirmationNotifier');

  GetOrderByIdResponse _getOrderByIdResponse = GetOrderByIdResponse();

  static const platform = const MethodChannel('com.etisalat');

  //constructor
  OrderConfirmationNotifier(context, String cartResponseId, String transactionId) {
    super.context = context;
    log.i("cartResponseid ---------------> $cartResponseId");
    if(transactionId!=null) {
      paymentFinalisationApi(cartResponseId, transactionId);
    }
    callApiGetOrderById(cartResponseId);
  }

  OrderConfirmationRepository _orderConfirmationRepository = OrderConfirmationRepository();

  GetOrderByIdResponse get getOrderByIdResponse => _getOrderByIdResponse;

  set getOrderByIdResponse(GetOrderByIdResponse value) {
    _getOrderByIdResponse = value;
    notifyListeners();
  }

  void paymentFinalisationApi(
      String cartResponseId, String transactionId) async {
    print("Came in to finalization api");
    Map<String, dynamic> data = {};
    data['TransactionID'] = transactionId;
    data['Customer'] = 'THOUGHT FACTORY';
    data['UserName'] = "TF_sukaina";
    data['Password'] = "[xq{k2mcaH8tSg";
    try {
      var result = await platform.invokeMethod('finalization', data);
      Map<dynamic, dynamic> response;
      if (result != null) {
        if (result is List) {
          debugPrint('ios response --- ${result}');
          List<dynamic> res = result as List;
          response = res.elementAt(0);
        } else
          response = result as Map;
        if (response.containsKey(1) &&
            response[1] != null &&
            response[1] == "Success") {
          callApiGetOrderById(cartResponseId);
        }
      }
      return result;
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
      return null;
    }
  }

  //api: get order by id
  void callApiGetOrderById(String id) async {
    log.i('api ::: callApiGetOrderById called');
    super.isLoading = true;
    try {
      GetOrderByIdResponse response =
      await _orderConfirmationRepository.apiGetOrderByIdResponse(id);
      onNewGetOrderResponse(response);
      super.isLoading = false;
    } catch (e) {
      log.e("Error :" + e.toString());

      super.isLoading = false;
    }
  }

  //api: cart quote id
  Future<String> callApiCartQuoteId() async {
    log.i('api ::: callApiCartQuoteId called');
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

  void onNewGetOrderResponse(GetOrderByIdResponse response) {
    if (response != null) {
      getOrderByIdResponse = response;
    }
  }
}
