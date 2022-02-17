import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:thought_factory/core/notifier/locate_me_notifier.dart';
import 'package:thought_factory/ui/menu/locate_me/map_user_badge.dart';
import 'package:thought_factory/utils/app_colors.dart';
import 'package:thought_factory/utils/app_text_style.dart';

class LocateMeView extends StatefulWidget {
  static const routeName = '/locate_me';

  const LocateMeView({Key key}) : super(key: key);

  @override
  _LocateMeViewState createState() => _LocateMeViewState();
}

class _LocateMeViewState extends State<LocateMeView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    print("getLocation111:$latLng");

    return ChangeNotifierProvider<LocateMeNotifier>(
      create: (context) => LocateMeNotifier(context),
      child: Consumer<LocateMeNotifier>(
        builder: (context, _c, _) => Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: _c.latLng == null
                    ? Container(
                        child: Center(
                          child: Text(
                            'loading map..',
                            style: TextStyle(
                                fontFamily: 'Avenir-Medium',
                                color: Colors.grey[400]),
                          ),
                        ),
                      )
                    : GoogleMap(
                        markers: _c.markers,
                        myLocationButtonEnabled: true,
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target:
                              LatLng(_c.latLng.latitude, _c.latLng.longitude),
                          zoom: 14.4746,
                        ),
                        onCameraMove: _c.onCameraMove,
                        onMapCreated: (GoogleMapController controller) {
                          _c.controller.complete(controller);
                        },
                      ),
              ),
              Positioned(
                top: 40,
                left: 0,
                right: 1,
                child: InkWell(
                  onTap: () {
                    debugPrint('on click of location');
                    _c.init();
                  },
                  child: MapUserBadge(
                    isSelected: true,
                    address: _c.address,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 20,
                child: _c.buttonStatus == LocateMeButton.none
                    ? Container()
                    : Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: RaisedButton(
                              onPressed: () {
                                _c.updateLatLng();
                              },
                              child: Text(
                                'Update',
                                style: getStyleButtonText(context),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0))),
                              color: colorPrimary,
                              padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
