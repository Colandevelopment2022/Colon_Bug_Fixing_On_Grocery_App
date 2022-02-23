import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:thought_factory/core/notifier/common_notifier.dart';
import 'package:thought_factory/core/notifier/termsandcondition_notifier.dart';
import 'package:thought_factory/utils/app_text_style.dart';

class TermsAndConditionScreen extends StatefulWidget {
  @override
  TermsAndConditionScreenContent createState() =>
      TermsAndConditionScreenContent();
}

class TermsAndConditionScreenContent extends State<TermsAndConditionScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TermsAndConditionNotifier>(
      create: (context) => TermsAndConditionNotifier(
          context, CommonNotifier().termsandCondition),
      child: Consumer<TermsAndConditionNotifier>(
        builder: (context, termsAndConditionNotifier, _) => ModalProgressHUD(
            inAsyncCall: termsAndConditionNotifier.isLoading,
            child:
                (termsAndConditionNotifier.termsAndConditionResponse != null &&
                        termsAndConditionNotifier
                                .termsAndConditionResponse.content !=
                            null)
                    ? SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Html(
                              data: termsAndConditionNotifier
                                  .termsAndConditionResponse.content,
                            ),
                            Text(
                              '@2020 ebazaar. All Rights Reserved',
                              style: getFormNormalTextStyle(context),
                            )
                          ],
                        ))
                    : (termsAndConditionNotifier.isLoading)
                        ? Container()
                        : Container(
                            child: Column(
                              children: [
                                Center(
                                  child: Text(termsAndConditionNotifier
                                      .termsAndConditionResponse.message),
                                ),
                                Text(
                                  '@2020 ebazaar. All Rights Reserved',
                                  style: getFormNormalTextStyle(context),
                                )
                              ],
                            ),
                          )),
      ),
    );
  }
}
