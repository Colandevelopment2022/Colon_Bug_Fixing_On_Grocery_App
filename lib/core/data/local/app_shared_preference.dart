import 'package:shared_preferences/shared_preferences.dart';
import 'package:thought_factory/utils/app_constants.dart';
import 'package:thought_factory/utils/app_log_helper.dart';

class AppSharedPreference {
  final log = getLogger('App SP');

  // singleton boilerplate
  AppSharedPreference._internal();

  static final AppSharedPreference _singleInstance = AppSharedPreference._internal();

  factory AppSharedPreference() => _singleInstance;
  SharedPreferences sharedPreference;

  //save: token of user after successful login
  Future<bool> saveUserToken(String token) async {
    return await sharedPreference.setString(AppConstants.KEY_TOKEN_USER, token);
  }

  //get: token of user
  String getUserToken(){
    return sharedPreference.getString(AppConstants.KEY_TOKEN_USER);
  }

  //save: token of Admin after successful Trigger
  Future<bool> saveAdminToken(String token) async {
    return sharedPreference.setString(AppConstants.KEY_TOKEN_ADMIN, token);
  }

  //get: token of Admin
  Future<String> getAdminToken() async {
    return sharedPreference.getString(AppConstants.KEY_TOKEN_ADMIN);
  }

  //save: cart quote id
  Future<bool> saveCartQuoteId(String cartQuoteId) async {
    return sharedPreference.setString(AppConstants.KEY_QUOTE_ID, cartQuoteId);
  }

  //save
  Future<bool> save(String key, String value) async {
    return  sharedPreference.setString(key, value);
  }


  //get: cart quote Id
  Future<String> getCartQuoteId() async {
    return sharedPreference.getString(AppConstants.KEY_QUOTE_ID);
  }

  //save: customer id
  Future<bool> saveCustomerId(String customerId) async {
    return sharedPreference.setString(AppConstants.KEY_CUSTOMER_ID, customerId);
  }

  //get: cart quote Id
  Future<String> getCustomerId() async {
    return sharedPreference.getString(AppConstants.KEY_CUSTOMER_ID);
  }

  Future<bool> setPreferenceData(String key,String value) async {
    return sharedPreference.setString(key,value);
  }

  Future<String> getPreferenceData(String key) async {
    return sharedPreference.getString(key);
  }

  Future saveStringValue(String keyName, String value) async {

    sharedPreference.setString(keyName, value);
  }

  Future<String> getStringValue(String keyName) async {
    return sharedPreference.getString(keyName);
  }

  Future saveBooleanValue(String keyName, bool value) async {
    sharedPreference.setBool(keyName, value);
  }

  Future<bool> getBoolValue(String keyName) async {
    return sharedPreference.getBool(keyName);
  }

  Future removeTokenDetails() async {
    log.i("removed user token");
    return sharedPreference.remove(AppConstants.KEY_TOKEN_USER);
  }

}
