import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:thought_factory/core/data/remote/network/app_url.dart';
import 'package:thought_factory/core/data/remote/network/method.dart';
import 'package:thought_factory/core/data/remote/repository/base/base_repository.dart';
import 'package:thought_factory/core/model/user_reward_response.dart';
import 'package:thought_factory/utils/app_constants.dart';
import 'package:thought_factory/utils/app_network_check.dart';

class UserRewardRespository extends BaseRepository {
  Future<UserRewardResponse> getUserRewards(
      Map<String, dynamic> requestData, String userToken,
      {String mockFile}) async {
    bool isNetworkAvail = await NetworkCheck().check();
    if (isNetworkAvail) {
      final response = await networkProvider.call(
          method: Method.POST,
          pathUrl: AppUrl.userRewards,
          body: requestData,
          headers: buildDefaultHeaderWithToken(userToken));
      if (response.statusCode == HttpStatus.ok) {
        if (mockFile != null) {
          Map<String, dynamic> res = jsonDecode(await rootBundle.loadString(
            mockFile,
          ));
          return UserRewardResponse(
              status: 1, message: '', data: Rewards.fromJson(res['data']));
        } else {
          Rewards r;
          if (response.body != null && json.decode(response.body) is List<dynamic>) {
            List<dynamic> rewardResponse = json.decode(response.body);
            List<Data> rewards = [];
            if (rewardResponse[0] != null) {
               r = Rewards.fromJson(rewardResponse[0]);
              if (rewardResponse[1] != null &&
                  rewardResponse[1] is List<dynamic>) {
                List<dynamic> d = rewardResponse[1] as List<dynamic>;
                for (dynamic reward in d) {
                  rewards.add(Data.fromJson(reward as Map<String, dynamic>));
                }
              }
              r.rewards = rewards;
            }
            return UserRewardResponse(status: 1, data: r, message: '');
          } else {
            return UserRewardResponse(
                status: 0,
                data: null,
                message: 'something went wrong try after sometime');
          }
        }
      } else if (response.statusCode == HttpStatus.unauthorized) {
        UserRewardResponse(status: 0, message: AppConstants.ERROR);
      } else if (response.statusCode == HttpStatus.notFound) {
        UserRewardResponse(status: 0, message: AppConstants.ERROR);
      } else {
        return null;
      }
    } else {
      return UserRewardResponse(
          message: AppConstants.ERROR_INTERNET_CONNECTION, status: 0);
    }
  }
}
