import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thought_factory/core/data/local/app_shared_preference.dart';
import 'package:thought_factory/core/model/category_model.dart';
import 'package:thought_factory/core/model/helper/info_home_tap.dart';
import 'package:thought_factory/state/state_drawer.dart';
import 'package:thought_factory/ui/login_screen.dart';
import 'package:thought_factory/ui/main/main_screen.dart';
import 'package:thought_factory/utils/app_colors.dart';
import 'package:thought_factory/utils/app_constants.dart';
import 'package:thought_factory/utils/app_custom_icon.dart';
import 'package:thought_factory/utils/app_font.dart';
import 'package:thought_factory/utils/app_text_style.dart';

import 'item.dart';
import 'item_content.dart';
import 'item_divider.dart';
import 'item_header.dart';

class MyDrawer extends StatelessWidget {
  final GlobalKey _key;
  StateDrawer _stateDrawer;
  List<Item> drawerData;

  MyDrawer(this._key, StateDrawer stateDrawer) {
    _stateDrawer = stateDrawer;
    if (_stateDrawer.lstCategory != null) {
      //print("lssss ------------> length ${_stateDrawer.lstCategory.length}");
      getListDrawerItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    //final mainModel = Provider.of<StateDrawer>(context);

    return Drawer(
      key: _key,
      child: Container(
        color: colorWhite,
        child: SafeArea(
          top: false,
          bottom: false,
          child: ListView(
            key: PageStorageKey(0),
            children: drawerData.map((item) {
              switch (item.getViewType()) {
                case AppConstants.APP_DRAWER_TYPE_HEADER:
                  return Container();
                case AppConstants.APP_DRAWER_TYPE_ITEM:
                  return _buildItemDrawer(context, item);
                case AppConstants.APP_DRAWER_TYPE_EXPANSION:
                  return _expansionWidget(context, item);
                case AppConstants.APP_DRAWER_ACCOUNT:
                  return _accountExpansionWidget(context, item);
                case AppConstants.APP_DRAWER_TYPE_DIVIDER:
                  return _buildItemDivider();

                default:
                  return _buildItemDivider();
              }
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _expansionWidget(BuildContext context, ItemContent item) {
    return ExpansionTile(
      key: PageStorageKey<ItemContent>(item),
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 16.0),
            child: Icon(
              item.iconData,
              size: 18,
            ),
          ),
          Text(
            item.name,
            style: getStyleSubHeading(context)
                .copyWith(color: null, fontWeight: AppFont.fontWeightRegular),
          ),
        ],
      ),
      children: categorItem(context),
    );
  }

  Widget _accountExpansionWidget(BuildContext context, ItemContent item) {
    return ExpansionTile(
      key: PageStorageKey<ItemContent>(item),
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 16.0),
            child: Icon(
              item.iconData,
              size: 18,
            ),
          ),
          Text(
            item.name,
            style: getStyleSubHeading(context)
                .copyWith(color: null, fontWeight: AppFont.fontWeightRegular),
          ),
        ],
      ),
      children: accountItem(context),
    );
  }

  List<Widget> accountItem(BuildContext buildContext) {
    List<Widget> accountItem = [];
    List<ItemContent> accountContent = [
      ItemContent(
          iconData: AppCustomIcon.drawer_my_order,
          name: AppConstants.DRAWER_ITEM_MY_ORDER),
      ItemContent(
          iconData: AppCustomIcon.drawer_shopping_bag_cart,
          name: AppConstants.DRAWER_ITEM_MY_CART),
      ItemContent(
          iconData: AppCustomIcon.drawer_like_heart,
          name: AppConstants.DRAWER_ITEM_MY_WISH_LIST),
      ItemContent(
          iconData: AppCustomIcon.monetization_on,
          name: AppConstants.DRAWER_ITEM_MY_REWARDS),
      ItemContent(
          iconData: AppCustomIcon.drawer_profile_user,
          name: AppConstants.DRAWER_ITEM_MY_PROFILE),
    ];
    for (ItemContent c in accountContent) {
      accountItem.add(Consumer<StateDrawer>(builder: (context, state, _) {
        return InkWell(
          onTap: () {
            state.selectedDrawerItem = c.name;
            state.selectedId = c.id;
            state.itemContent = c;
//              Future.delayed(Duration(milliseconds: 500),
//                  () => {Navigator.of(context).pop()});
            Future.delayed(Duration(milliseconds: 500), () {
              if (Navigator.canPop(buildContext)) {
                Navigator.of(buildContext).pop();
              } else {
                print("Error : No Page At back");
              }
            });
          },
          child: Container(
            padding:
                EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0, bottom: 12.0),
            decoration: state.selectedDrawerItem == c.name
                ? BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 3.0, color: colorPrimary),
                    ),
                    gradient: LinearGradient(
                      colors: [colorAccentMild, colorWhite],
                      begin: Alignment.centerLeft,
                      end: Alignment(1.0, 0.0),
                    ),
                  )
                : null,
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.only(left: 14.0, right: 16.0),
                child: Icon(
                  c.iconData,
                  size: 18,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: getStyleSubHeading(context).copyWith(
                          color: state.selectedDrawerItem == c.name
                              ? colorPrimary
                              : null,
                          fontWeight: state.selectedDrawerItem == c.name
                              ? AppFont.fontWeightSemiBold
                              : AppFont.fontWeightRegular),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        );
        return Row(
          children: [],
        );
      }));
    }
    // accountItem.add(_buildItemDrawer())
    return accountItem;
  }

  List<Widget> categorItem(BuildContext context) {
    List<Widget> category = [];
    if (_stateDrawer.lstCategory != null) {
      for (CategoryModel c in _stateDrawer.lstCategory) {
        if (c.name != null && c.name.isNotEmpty && c.name != 'null')
          category.add(Consumer<StateDrawer>(builder: (context, state, _) {
            return InkWell(
              onTap: () {
                InfoHomeTap infoHomeTap1 =
                    InfoHomeTap(id: c.id, toolBarName: c.name);
                Future.delayed(Duration(milliseconds: 500), () {
                  //Navigator.of(context).pop();
                  //if(state.selectedDrawerItem == AppConstants.DRAWER_ITEM_HOME) {

                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  } else {
                    print("Error : No Page At back");
                  }
                  state.onValueChange.value = infoHomeTap1;
                });
              },
              child: Container(
                padding: EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 12.0, bottom: 12.0),
                decoration: state.selectedDrawerItem == c.name
                    ? BoxDecoration(
                        border: Border(
                          left: BorderSide(width: 3.0, color: colorPrimary),
                        ),
                        gradient: LinearGradient(
                          colors: [colorAccentMild, colorWhite],
                          begin: Alignment.centerLeft,
                          end: Alignment(1.0, 0.0),
                        ),
                      )
                    : null,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0, right: 16.0),
                    child: c.imageIconUrl != null &&
                            c.imageIconUrl.isNotEmpty &&
                            c.imageIconUrl != 'null'
                        ? Image.network(
                            c.imageIconUrl,
                            height: 18.0,
                            width: 18.0,
                          )
                        : Container(
                            height: 18.0,
                            width: 18.0,
                          ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: getStyleSubHeading(context).copyWith(
                              color: state.selectedDrawerItem == c.name
                                  ? colorPrimary
                                  : null,
                              fontWeight: state.selectedDrawerItem == c.name
                                  ? AppFont.fontWeightSemiBold
                                  : AppFont.fontWeightRegular),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            );
            return Row(
              children: [],
            );
          }));
      }
    }
    return category;
  }

  Widget _buildItemDrawerHeader(BuildContext context) {
    return Container(
      height: 150,
      color: colorWhite,
      child: DrawerHeader(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [colorPrimary, colorWhite],
                begin: Alignment.topCenter,
                stops: [0.7, 0.4],
                end: Alignment.bottomCenter)),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: CachedNetworkImage(
                  alignment: Alignment(0.0, 0.60),
                  imageUrl: _stateDrawer.imageUrl != null &&
                          _stateDrawer.imageUrl.isNotEmpty
                      ? _stateDrawer.imageUrl
                      : "",
                  imageBuilder: (context, imageProvider) => Container(
                        padding: EdgeInsets.only(top: 28.0),
                        child: SizedBox(
                          width: 80.0,
                          height: 80.0,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorWhite,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: colorLightGrey,
                                      spreadRadius: 0.5,
                                      blurRadius: 2.0)
                                ]),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      alignment: Alignment.center,
                                      image: imageProvider,
                                      fit: BoxFit.scaleDown),
                                  //borderRadius: BorderRadius.all(Radius.circular(50.0)),
//                                        border: Border.all(
//                                          color: Colors.transparent,
//                                          width: 1.0,
//                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  placeholder: (context, url) => Icon(
                        AppCustomIcon.icon_white_logo_ebazaar,
                        color: colorWhite,
                        size: 48,
                      ),
                  errorWidget: (context, url, error) => Icon(
                        AppCustomIcon.icon_white_logo_ebazaar,
                        color: colorWhite,
                        size: 48,
                      )),
            ),
            Align(
                alignment: Alignment(0.0, -0.90),
                child: Text(
                  'Menu',
                  style: getStyleTitle(context).copyWith(
                      color: colorWhite, fontWeight: AppFont.fontWeightBold),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDrawer(BuildContext context, ItemContent item) {
    debugPrint('drawer item --- ${item}');
    return Consumer<StateDrawer>(
      builder: (context, state, _) => Material(
        color: colorWhite,
        child: InkWell(
          splashColor: colorPrimary,
          onTap: () {
            //close navigation drawer
            if (item.name == "Logout") {
              _clearUserCredential().whenComplete(() {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    LoginScreen.routeName,
                    ModalRoute.withName(MainScreen.routeName));
              });
            } else if (!AppConstants.DRAWER_STABLE_ITEMS_COLLECTIONS
                .contains(item.name)) {
              InfoHomeTap infoHomeTap1 =
                  InfoHomeTap(id: int.parse(item.id), toolBarName: item.name);
              Future.delayed(Duration(milliseconds: 500), () {
                //Navigator.of(context).pop();
                //if(state.selectedDrawerItem == AppConstants.DRAWER_ITEM_HOME) {

                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  print("Error : No Page At back");
                }
                state.onValueChange.value = infoHomeTap1;
              });
            } else {
              state.selectedDrawerItem = item.name;
              state.selectedId = item.id;
              state.itemContent = item;
//              Future.delayed(Duration(milliseconds: 500),
//                  () => {Navigator.of(context).pop()});
              Future.delayed(Duration(milliseconds: 500), () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  print("Error : No Page At back");
                }
              });
            }
          },
          child: Container(
            decoration: state.selectedDrawerItem == item.name
                ? BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 3.0, color: colorPrimary),
                    ),
                    gradient: LinearGradient(
                      colors: [colorAccentMild, colorWhite],
                      begin: Alignment.centerLeft,
                      end: Alignment(1.0, 0.0),
                    ),
                  )
                : null,
            child: Row(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                    child: (item.imageIconPath == null
                        ? Icon(
                            item.iconData,
                            color: state.selectedDrawerItem == item.name
                                ? colorPrimary
                                : null,
                            size: 18,
                          )
                        : item.imageIconPath != 'null'
                            ? Image.network(
                                item.imageIconPath,
                                height: 18.0,
                                width: 18.0,
                              )
                            : Container())),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.8,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      item.name,
                      style: getStyleSubHeading(context).copyWith(
                          color: state.selectedDrawerItem == item.name
                              ? colorPrimary
                              : null,
                          fontWeight: state.selectedDrawerItem == item.name
                              ? AppFont.fontWeightSemiBold
                              : AppFont.fontWeightRegular),
                    ),
                  ),
                ),
              ],
            ),
            padding:
                EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0, bottom: 12.0),
          ),
        ),
      ),
    );
  }

  Widget _buildItemDivider() {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      color: colorWhite,
      child: Divider(
        color: Colors.grey,
      ),
    );
  }

  List<Item> getListDrawerItem() {
    //_listDrawerItem.insert(index, element)
    drawerData = [
      ItemHeader(),
      ItemContent(
        iconData: AppCustomIcon.drawer_home_outline,
        name: AppConstants.DRAWER_ITEM_HOME,
      ),
      ItemContent(
          iconData: AppCustomIcon.icon_default_camera,
          name: AppConstants.DRAWER_ITEM_CATEGORY,
          id: '3'),
      ItemContent(
          iconData: AppCustomIcon.drawer_flow_tree,
          name: AppConstants.DRAWER_ITEM_DISTRIBUTORS),
      ItemDivider(),
      ItemContent(
          iconData: AppCustomIcon.drawer_profile_user,
          name: AppConstants.DRAWER_ITEM_MY_ACCOUNT,
          id: '4'),
      ItemContent(
          iconData: AppCustomIcon.drawer_review_star,
          name: AppConstants.DRAWER_ITEM_PRODUCT_REVIEW),
      ItemContent(
          iconData: AppCustomIcon.locate_me,
          name: AppConstants.DRAWER_ITEM_LOCATE_ME),
      ItemDivider(),
      ItemContent(
          iconData: AppCustomIcon.drawer_phone_ring,
          name: AppConstants.DRAWER_ITEM_CONTACT_US),
      ItemContent(
          iconData: AppCustomIcon.drawer_terms_condition,
          name: AppConstants.DRAWER_ITEM_TERMS_AND_CONDITION),
      ItemContent(
          iconData: AppCustomIcon.drawer_privacy_policy,
          name: AppConstants.DRAWER_ITEM_PRIVACY_POLICY),
      ItemContent(
          iconData: AppCustomIcon.drawer_log_out,
          name: AppConstants.DRAWER_ITEM_LOGOUT),
    ];
    return drawerData;
  }

  Future _clearUserCredential() async {
    await AppSharedPreference().saveUserToken("");
    await AppSharedPreference()
        .saveStringValue(AppConstants.KEY_USER_EMAIL_ID, "");
    await AppSharedPreference()
        .saveStringValue(AppConstants.KEY_USER_PASSWORD, "");
    AppSharedPreference().removeTokenDetails();
  }
}
