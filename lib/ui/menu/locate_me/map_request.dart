import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

const apiKey = "AIzaSyDiI5EXleWEpxCkjSjJrFzYs38KK6sYcaw";

class GoogleMapsServices {
  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apiKey";
    http.Response response = await http.get(Uri.parse(url));
    Map values = jsonDecode(response.body);
    print("====================>>>>>>>>${values}");
    if (response.statusCode != 200) {
      return '';
    } else
      return values["routes"][0]["overview_polyline"]["points"];
  }
}
