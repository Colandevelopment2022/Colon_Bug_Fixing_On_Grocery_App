import 'package:thought_factory/core/data/local/app_shared_preference.dart';
import 'package:thought_factory/core/data/remote/repository/user_rewards_respository.dart';
import 'package:thought_factory/core/model/user_reward_response.dart';
import 'package:thought_factory/utils/app_constants.dart';
import 'package:thought_factory/utils/app_network_check.dart';

import 'base/base_notifier.dart';

class UserRewardsNotifier extends BaseNotifier {
  UserRewardsNotifier(context) {
    super.context = context;
    userCreditsApiCall();
  }

  final _repository = UserRewardRespository();
  UserRewardResponse _userCreditResponse;

  UserRewardResponse get credit => _userCreditResponse;
  String adminToken = '';
  String userToken = '';

  Future<void> userCreditsApiCall() async {
    bool isNetworkAvail = await NetworkCheck().check();
    if (isNetworkAvail) {
      isLoading = true;
      String customerID = await AppSharedPreference().getCustomerId();
      Map<String, dynamic> data = {};
      data['customerId'] = customerID;
      UserRewardResponse response =
          await _repository.getUserRewards(data, adminToken);
      if (response.status == 1) {
        onRewardsResponse(response);
      }
      isLoading = false;
      notifyListeners();
    } else {
      //show error toast
      showSnackBarMessageWithContext(AppConstants.ERROR_INTERNET_CONNECTION);
    }
  }

  void onRewardsResponse(UserRewardResponse response) {
    if (response != null) {
      _userCreditResponse = response;
    }
  }
}
