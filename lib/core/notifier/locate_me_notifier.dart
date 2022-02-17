import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:thought_factory/core/model/locate_me_response.dart';
import 'package:thought_factory/core/notifier/base/base_notifier.dart';
import 'package:thought_factory/core/notifier/common_notifier.dart';
import 'package:thought_factory/ui/menu/locate_me/map_request.dart';

enum LocateMeButton { update, save, none }

class LocateMeNotifier extends BaseNotifier {
  bool loading = true;

  final Set<Marker> markers = {};

  GoogleMapsServices googleMapsServices = GoogleMapsServices();

  Completer<GoogleMapController> controller = Completer();
  LatLng latLng;
  LocationData currentLocation;
  String address;
  var location = new Location();
  LatLng currentLatLng;
  LocateMeButton buttonStatus = LocateMeButton.none;

  LocateMeNotifier(BuildContext context) {
    super.context = context;
    Future.delayed(Duration(milliseconds: 10), () {
      init();
    });
  }

  void init() {
    if (CommonNotifier().latLog.isEmpty) {
      CommonNotifier().apiGetLocateMe().then((LocateMeResponse value) {
        if (value != null) {
          List<String> latLng = value.value.split(' ');
          getLocation(LatLng(double.parse(latLng.elementAt(0)),
              double.parse(latLng.elementAt(1))));
          CommonNotifier().latLog = value.value;
          buttonStatus = LocateMeButton.none;
        } else {
          Geolocator.getCurrentPosition().then((Position value) {
            getLocation(LatLng(value.latitude, value.longitude));
            CommonNotifier().latLog = '${value.latitude} ${value.longitude}';
            buttonStatus = LocateMeButton.save;
          });
        }
      });
    } else {
      List<String> latLng = CommonNotifier().latLog.split(' ');
      getLocation(LatLng(double.parse(latLng.elementAt(0)),
          double.parse(latLng.elementAt(1))));
      CommonNotifier().latLog = CommonNotifier().latLog;
      buttonStatus = LocateMeButton.none;
    }
  }

  getLocation(LatLng latLng) async {
    this.latLng = latLng;
    final coordinates = Coordinates(latLng.latitude, latLng.longitude);
    latLng = LatLng(latLng.latitude, latLng.longitude);
    if (loading) {
      addressDetails(coordinates);
      _onAddMarkerButtonPressed();
      loading = false;
    }
  }

  void addressDetails(Coordinates coordinates) async {
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    address = first.addressLine;
    print('${first.addressLine}');
    notifyListeners();
  }

  void _onAddMarkerButtonPressed() {
    markers.add(Marker(
        draggable: true,
        infoWindow: InfoWindow(title: 'move the pin to adjust'),
        markerId: MarkerId("111"),
        position: latLng,
        icon: BitmapDescriptor.defaultMarker,
        onDragEnd: ((newPosition) {

          if (latLng != newPosition) {
            latLng = LatLng(newPosition.latitude, newPosition.longitude);
            addressDetails(
                Coordinates(newPosition.latitude, newPosition.longitude));
            buttonStatus = LocateMeButton.update;
          }
        })));
    notifyListeners();
  }

  void onCameraMove(CameraPosition position) {
    latLng = position.target;
  }

  void updateLatLng() {
    String latLng = '${this.latLng.latitude} ${this.latLng.longitude}';
    CommonNotifier().updateLatLng(latLng).then((dynamic value) {
      debugPrint('update lat lng status --- ${value}');
      buttonStatus = LocateMeButton.none;
      CommonNotifier().latLog =
          '${this.latLng.latitude} ${this.latLng.longitude}';
      notifyListeners();
    });
  }
}
