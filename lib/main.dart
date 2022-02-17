import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:thought_factory/router.dart';
import 'package:thought_factory/state/state_drawer.dart';
import 'package:thought_factory/ui/login_screen.dart';
import 'package:thought_factory/utils/app_colors.dart';
import 'package:thought_factory/utils/app_font.dart';
import 'package:thought_factory/utils/environment_varriables.dart';
import 'core/data/local/app_shared_preference.dart';
import 'core/notifier/common_notifier.dart';
import 'core/notifier/login_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Logger.level = Level.debug;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  EnvVarriables.env;
  AppSharedPreference().sharedPreference = prefs;
  var savedtokenotp = AppSharedPreference().getUserToken();
  print("Saved Token from OTP-------->${savedtokenotp}");
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: colorBlack, // navigation bar color
    statusBarColor: colorPrimary, // status bar color
  ));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => CommonNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => StateDrawer(),
      ),
      ChangeNotifierProvider(
        create: (context) => LoginNotifier(),
      )
    ],
    child: MaterialApp(
      theme: ThemeData(
        fontFamily: AppFont.fontFamilyName,
        textTheme: TextTheme(
          button: TextStyle(fontWeight: AppFont.fontWeightRegular),
          caption: TextStyle(fontWeight: AppFont.fontWeightRegular),
          bodyText2: TextStyle(fontWeight: AppFont.fontWeightRegular),
          bodyText1: TextStyle(fontWeight: AppFont.fontWeightRegular),
          subtitle1: TextStyle(fontWeight: AppFont.fontWeightRegular),
          headline6: TextStyle(fontWeight: AppFont.fontWeightRegular),
          headline5: TextStyle(fontWeight: AppFont.fontWeightRegular),
          headline4: TextStyle(fontWeight: AppFont.fontWeightRegular),
          headline3: TextStyle(fontWeight: AppFont.fontWeightRegular),
        ),
        primaryColor: colorPrimary,
        primarySwatch: kPrimaryColor,
        secondaryHeaderColor:colorAccent ,
        buttonTheme: const ButtonThemeData(
            buttonColor: colorPrimary, textTheme: ButtonTextTheme.primary),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: savedtokenotp!=null?'/main_screen':LoginScreen.routeName,
      onGenerateRoute: MyRouter.generateRoute,
    ),
  ));
}
