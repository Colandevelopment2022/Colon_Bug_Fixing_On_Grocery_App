import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thought_factory/core/data/local/app_shared_preference.dart';
import 'package:thought_factory/core/data/remote/request_response/manage_payment/add_new_card_request.dart';
import 'package:thought_factory/core/notifier/common_notifier.dart';
import 'package:thought_factory/core/notifier/payment_card_notifier1.dart';
import 'package:thought_factory/state/state_drawer.dart';
import 'package:thought_factory/ui/main/main_screen.dart';
import 'package:thought_factory/ui/menu/manage_payment/add_new_card_screen.dart';
import 'package:thought_factory/utils/app_colors.dart';
import 'package:thought_factory/utils/app_constants.dart';
import 'package:thought_factory/utils/app_font.dart';
import 'package:thought_factory/utils/app_text_style.dart';

class PaymentCardScreen1 extends StatefulWidget {
  static const routeName = '/payment_card_screen';

  @override
  PaymentCardScreen1State createState() => PaymentCardScreen1State();
}

class PaymentCardScreen1State extends State<PaymentCardScreen1> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String customerName;
  @override
  void initState() {
    super.initState();
    _getCustomerName(); //method
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> cartResponseId =
        ModalRoute.of(context).settings.arguments;

    return ChangeNotifierProvider<PaymentCardNotifier1>(
        create: (context) => PaymentCardNotifier1(context, cartResponseId),
        child: Consumer<PaymentCardNotifier1>(
            builder: (BuildContext context, notifier, _) => Scaffold(
                  key: _scaffoldKey,
                  appBar: _buildAppBar(context, notifier),
                  body: ModalProgressHUD(
                    inAsyncCall: notifier.isLoading,
                    child: WillPopScope(
                        child: _buildScreenContent(context, notifier),
                        onWillPop: () async => false),
                  ),
                )));
  }

  Widget _buildAppBar(context, notifier) {
    return AppBar(
      elevation: 3.0,
      centerTitle: true,
      leading: GestureDetector(
          onTap: () {
            /// payment on back button pressed (cart is getting cleared and order is generated)
            // callApiCartQuoteId(notifier, context);
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            size: 20.0,
          )),
      title: Text(
        AppConstants.CARD_PAYMENT,
        style: getAppBarTitleTextStyle(context),
      ),
    );
  }

  void callApiCartQuoteId(PaymentCardNotifier1 notifier, context) {
    StateDrawer stateDrawer = Provider.of<StateDrawer>(context);
    notifier.callApiCartQuoteId().then((value) {
      if (value != null) {
        CommonNotifier().quoteId = value;
        AppSharedPreference().saveCartQuoteId(value);
        Navigator.pushNamedAndRemoveUntil(
            context, MainScreen.routeName, (e) => false);
        stateDrawer.selectedDrawerItem = AppConstants.DRAWER_ITEM_HOME;
      }
    });
  }

  Widget _buildScreenContent(
      BuildContext context, PaymentCardNotifier1 notifier) {
    return Column(
      children: [
        _buildLabelChooseCard(),
        _buildListOrNot(context, notifier),
        _buildButtonBottom(context, notifier),
      ],
    );
  }

  Widget _buildLabelChooseCard() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 16.0, bottom: 8.0),
      alignment: Alignment.centerLeft,
      child: Text(
        'Choose a card to pay',
        style: getStyleSubHeading(context)
            .copyWith(fontWeight: AppFont.fontWeightSemiBold),
        textAlign: TextAlign.start,
      ),
    );
  }

  _buildListOrNot(context, notifier) {
    return (isListNotEmpty(notifier))
        ? buildListPaymentCards(notifier)
        : (notifier.isLoading)
            ? Container()
            : _buildEmptyScreen(notifier);
  }

  Widget _buildEmptyScreen(PaymentCardNotifier1 notifier) {
    return Expanded(
      child: Container(
        padding:
            EdgeInsets.only(top: 8.0, bottom: 16.0, right: 16.0, left: 16.0),
        child: Center(
          child: Text(
            "No Cards found!!\n\n Please choose a card by adding new, to "
            "complete your "
            "payment",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  bool isListNotEmpty(PaymentCardNotifier1 notifier) {
    return (notifier.paymentCardsList != null &&
        notifier.paymentCardsList.length > 0);
  }

  //build list: cards list
  Widget buildListPaymentCards(PaymentCardNotifier1 notifier) {
    return Expanded(
      child: ListView.builder(
          padding: EdgeInsets.only(bottom: 20.0),
          itemCount: notifier.paymentCardsList.length,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return buildItemCardForList(context, colorCard1,
                    notifier.paymentCardsList[index], index, notifier);
              case 1:
                return buildItemCardForList(context, colorCard2,
                    notifier.paymentCardsList[index], index, notifier);
              case 2:
                return buildItemCardForList(context, colorCard3,
                    notifier.paymentCardsList[index], index, notifier);
              default:
                return buildItemCardForList(context, colorFbBlue,
                    notifier.paymentCardsList[index], index, notifier);
            }
          }),
    );
  }

  //build item: card item
  Widget buildItemCardForList(context, colorRandom, NewCard item, int index,
      PaymentCardNotifier1 notifier) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Radio(
            groupValue: notifier.selectedCardIndex,
            value: index,
            onChanged: (val) {
              notifier.updateSelectedCard(item);
              setState(() {
                notifier.selectedCardIndex = val;
              });
            }),
        Expanded(
          child: Container(
              margin: EdgeInsets.only(right: 16, top: 8.0, bottom: 4.0),
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 16.0 / 7.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      colors: [colorRandom.withAlpha(120), colorRandom],
                      begin: Alignment(-.5, -2.5),
                      end: Alignment.bottomRight,
                      stops: [0.1, 0.6],
                    )),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.beach_access,
                                  color: Colors.red,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Citrus',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: getStyleSubHeading(context).copyWith(
                                        fontWeight: AppFont.fontWeightBold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(customerName,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                      style: getStyleButton(context)
                                          .copyWith(color: colorWhite)),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Text(item.card_no.substring(0, 4),
                                        style: getStyleTitle(context).copyWith(
                                            color: colorWhite,
                                            fontWeight:
                                                AppFont.fontWeightMedium))),
                                Expanded(
                                    child: Text(
                                  item.card_no.substring(4, 8),
                                  style: getStyleTitle(context).copyWith(
                                      color: colorWhite,
                                      fontWeight: AppFont.fontWeightMedium),
                                )),
                                Expanded(
                                    child: Text(item.card_no.substring(8, 12),
                                        style: getStyleTitle(context).copyWith(
                                            color: colorWhite,
                                            fontWeight:
                                                AppFont.fontWeightMedium))),
                                Expanded(
                                    child: Text(item.card_no.substring(12),
                                        style: getStyleTitle(context).copyWith(
                                            color: colorWhite,
                                            fontWeight:
                                                AppFont.fontWeightMedium))),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Text(
                                        'Exp' "  " +
                                            item.exp_month +
                                            " / " +
                                            item.exp_year,
                                        style: getStyleButton(context).copyWith(
                                            color: colorWhite,
                                            fontWeight:
                                                AppFont.fontWeightMedium))),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )),
        ),
      ],
    );
  }

  //build button: add new card & paynow
  Widget _buildButtonBottom(BuildContext context, PaymentCardNotifier1 notifier) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 8, top: 16.0, bottom: 16),
            width: double.infinity,
            child: RaisedButton(
              color: colorAccent,
              textColor: Colors.white,
              elevation: 5.0,
              padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Text(
                AppConstants.ADD_NEW_CARD,
                style: getStyleSubHeading(context).copyWith(
                    fontWeight: AppFont.fontWeightMedium, color: colorWhite),
              ),
              onPressed: () {
                _openScreenAddNewCard(context, notifier);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0)),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 8, right: 16, top: 16.0, bottom: 16),
            width: double.infinity,
            child: RaisedButton(
              color: colorAccent,
              textColor: Colors.white,
              elevation: 5.0,
              padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Text(
                AppConstants.PAY_NOW,
                style: getStyleSubHeading(context).copyWith(
                    fontWeight: AppFont.fontWeightMedium, color: colorWhite),
              ),
              onPressed: () {
                if (notifier.validateCardDetails()) {
                  notifier.getOrderId();

                } else {
                  notifier.showToast("Please choose a "
                      "card to Pay");
                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0)),
            ),
          ),
        )
      ],
    );
  }

  void _getCustomerName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customerName = (prefs.getString(AppConstants.KEY_CUSTOMER_NAME) ?? '');
    });
  }

  //open screen: AddNewCardScreen
  void _openScreenAddNewCard(context, PaymentCardNotifier1 notifier) {
    Navigator.pushNamed(context, AddNewCardScreen.routeName)
        .then((isCardAddedSuccessfully) {
      if (null != isCardAddedSuccessfully && isCardAddedSuccessfully) {
        notifier.resetSelectedCard();
        setState(() {});
        notifier.setDataForListCards();
        notifier.showToast("New card saved successfully");
      }
    });
  }
}

