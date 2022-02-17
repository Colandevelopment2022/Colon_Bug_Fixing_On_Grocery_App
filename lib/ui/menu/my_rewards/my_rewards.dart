import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:thought_factory/core/model/user_reward_response.dart';
import 'package:thought_factory/core/notifier/user_rewards_notifier.dart';
import 'package:thought_factory/utils/app_colors.dart';
import 'package:thought_factory/utils/app_font.dart';
import 'package:thought_factory/utils/app_text_style.dart';

class MyRewards extends StatefulWidget {
  const MyRewards({Key key}) : super(key: key);

  @override
  _MyRewardsState createState() => _MyRewardsState();
}

class _MyRewardsState extends State<MyRewards> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserRewardsNotifier>(
      create: (context) => UserRewardsNotifier(context),
      child: Consumer<UserRewardsNotifier>(
        builder: (context, notifier, _) {
          debugPrint('loader status --- ${notifier.isLoading}');
          debugPrint('data status --- ${notifier.credit}');

          return ModalProgressHUD(
              inAsyncCall: notifier.isLoading,
              child: (notifier.credit != null &&
                      notifier.credit.data != null &&
                      notifier.credit.data.rewards != null &&
                      notifier.credit.data.rewards.length > 0)
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          rewardsHeader(),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: notifier.credit.data.rewards.length,
                              itemBuilder: (_, index) {
                                return buildRewardsWidget(index, notifier);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : (notifier.isLoading)
                      ? Container()
                      : Container(
                          child: Center(
                            child: Text('No data found'),
                          ),
                        ));
        },
      ),
    );
  }

  Widget rewardsHeader() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              'Description',
              textAlign: TextAlign.start,
              style: getStyleBody2(context).copyWith(fontWeight: AppFont.fontWeightSemiBold),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              'debited',
              textAlign: TextAlign.start,
              style: getStyleBody2(context).copyWith(fontWeight: AppFont.fontWeightSemiBold),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              'credit',
              textAlign: TextAlign.start,
              style: getStyleBody2(context).copyWith(fontWeight: AppFont.fontWeightSemiBold),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              'status',
              textAlign: TextAlign.start,
              style: getStyleBody2(context).copyWith(fontWeight: AppFont.fontWeightSemiBold),
            ),
          ),
        )
      ],
    );
  }

  Widget buildRewardsWidget(int index, UserRewardsNotifier notifer) {
    Data data = notifer.credit.data.rewards.elementAt(index);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  data.transactionNote,
                  textAlign: TextAlign.center,
                  style: getStyleBody1(context).copyWith(color: colorBlack),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  data.action != 'credit' ? data.rewardPoint : '-',
                  textAlign: TextAlign.start,
                  style: getStyleBody1(context).copyWith(color: colorBlack),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  data.action == 'credit' ? data.rewardPoint : '-',
                  textAlign: TextAlign.start,
                  style: getStyleBody1(context).copyWith(color: colorBlack),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  data.status == '1' ? 'Approved' : 'Pending',
                  textAlign: TextAlign.start,
                  style: getStyleBody1(context).copyWith(color: colorBlack),
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                child: Container(
                  height: 2,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
