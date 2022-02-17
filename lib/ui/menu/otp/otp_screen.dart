import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';
import 'package:thought_factory/ui/menu/otp/otp_presenter.dart';
import 'package:thought_factory/ui/menu/otp/send_otp_api.dart';
import 'package:thought_factory/utils/app_colors.dart';
import 'package:thought_factory/utils/app_constants.dart';
import 'package:thought_factory/utils/app_text_style.dart';

class OtpScreen extends StatefulWidget {
  static const routeName = '/otpScreen';

  const OtpScreen({Key key}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        body: ChangeNotifierProvider<OtpPresenter>(
      create: (context) => OtpPresenter(context, data),
      child: Consumer<OtpPresenter>(
        builder: (BuildContext context, presenter, _) => ModalProgressHUD(
          inAsyncCall: presenter.isLoading,
          child: Scaffold(
            backgroundColor: colorGrey,
            body: _buildPageContent(context, presenter),
            bottomNavigationBar: buildBottom(presenter),
            appBar: _buildAppbar(),
          ),
        ),
      ),
    ));
  }

  Widget _buildPageContent(
    BuildContext context,
    OtpPresenter presenter,
  ) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              "OTP has been sent to ${presenter.data['mobile_number']}",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        TextFieldPin(
          filled: true,
          filledColor: Colors.grey[100],
          codeLength: 4,
          boxSize: 40,
          onOtpCallback: (code, isAutofill) =>
              _onOtpCallBack(code, isAutofill, presenter),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: presenter.start != 0
              ? Text('Resend OTP in ${presenter.start} sec')
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't Received OTP ? "),
                    GestureDetector(
                        onTap: () {
                          presenter.updateTime();
                          SendOtp(presenter.data['mobile_number']);
                        },
                        child: Text(
                          "Request OTP",
                          style: getSmallTextNavigationStyle(context),
                        ))
                  ],
                ),
        ),
      ],
    );
  }

  Widget buildBottom(OtpPresenter presenter) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      height: 80,
      color: Colors.transparent,
      alignment: Alignment.topCenter,
      child: Center(
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              flex: 1,
              child: Builder(
                builder: (BuildContext context) => RaisedButton(
                  onPressed: () {
                    presenter.otpSubmitApiCall(data);
                  },
                  child: Text(
                    AppConstants.SUBMIT,
                    style: getStyleButtonText(context),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  color: colorPrimary,
                  padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onOtpCallBack(String otpCode, bool isAutofill, OtpPresenter otpPresenter) {
    debugPrint('on otp call back --- ${otpCode}');
    debugPrint('on otp auto fill--- ${isAutofill}');
    otpPresenter.otp.text = otpCode;
    if (otpCode.length == 4) {
      otpPresenter.otpSubmitApiCall(data);

    }
  }

  Widget _buildAppbar() {
    return AppBar(
        elevation: 3.0,
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_ios,
              size: 20.0,
            )),
        title: Text(
          AppConstants.OTP,
          style: getAppBarTitleTextStyle(context),
        ));
  }
}
