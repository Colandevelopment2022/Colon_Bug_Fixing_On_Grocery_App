import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:thought_factory/core/data/remote/request_response/cart/add_cart_item_product/add_cart_response.dart';
import 'package:thought_factory/core/notifier/cart_notifier.dart';
import 'package:thought_factory/core/notifier/common_notifier.dart';
import 'package:thought_factory/core/notifier/payment_card_notifier1.dart';
import 'package:thought_factory/ui/order/order_confirmation_screen.dart';
import 'package:thought_factory/utils/app_text_style.dart';

import '../../router.dart';

class EtisalatWebView extends StatelessWidget {
  static const routeName = '/etistalatwebview';

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> data = ModalRoute.of(context).settings.arguments;
    return WillPopScope(
      onWillPop: (){
         Navigator.pop(context,true);
         return Future<bool>.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 3.0,
          centerTitle: true,
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                size: 20.0,
              )),
          title: Text(
            'Payment ',
            style: getAppBarTitleTextStyle(context),
          ),
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(
              url: Uri.parse(
                data["web_portal_url"],
              ),
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
              body: Uint8List.fromList(utf8.encode("TransactionID=${data['transaction_id']}")),
              method: "POST"),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url;
            debugPrint('navigation url --- ${uri.path}');
            return NavigationActionPolicy.CANCEL;
          },
          onWebViewCreated: (InAppWebViewController controller) {},
          onLoadStart: (InAppWebViewController controller, Uri url) {
            if (url.path == "/callbackURL") {
              Map<String, dynamic> transactionData = {};
              transactionData['order_id'] = data['order_id'] as String;
              transactionData['transaction_id'] = data['transaction_id'] as String;
              Navigator.pushNamed(context, OrderConfirmationScreen.routeName,
                  arguments: transactionData);
            }
          },
          onLoadStop: (InAppWebViewController controller, Uri url) async {
            debugPrint('on Load Stop --- ${url.path}');
          },
          onProgressChanged: (InAppWebViewController controller, int progress) {},
        ),
      ),
    );
  }
}





