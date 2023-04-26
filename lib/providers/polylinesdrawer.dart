import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

Future<List<Polyline>> getPolylinesFromFirestore() async {
  List<Polyline> polylines = [];
  int polylineIdCounter = 1;

  CollectionReference collection =
      FirebaseFirestore.instance.collection('Routes');
  QuerySnapshot querySnapshot = await collection.get();

  int numPolylines = querySnapshot.docs.length;
  double hueStep = 360 / numPolylines;

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    List<GeoPoint> geoPoints = List.from(doc['Route Points']);
    String routeNumber = (doc['Route Number']);
    List<LatLng> latLngPoints = geoPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    debugPrint('Polyline fetch for $routeNumber: $latLngPoints');

    //polyline color auto adjustible from rgb
    ui.Color polylineColor = ui.Color.fromARGB(
      255,
      HSVColor.fromAHSV(1.0, hueStep * (polylineIdCounter - 1), 1.0, 1.0)
          .toColor()
          .red,
      HSVColor.fromAHSV(1.0, hueStep * (polylineIdCounter - 1), 1.0, 1.0)
          .toColor()
          .green,
      HSVColor.fromAHSV(1.0, hueStep * (polylineIdCounter - 1), 1.0, 1.0)
          .toColor()
          .blue,
    );

    Polyline polyline = Polyline(
        polylineId: PolylineId(polylineIdCounter.toString()),
        points: latLngPoints,
        color: polylineColor,
        width: 5,
        onTap: () {});

    polylines.add(polyline);
    polylineIdCounter++;
  }
  return polylines;
}
