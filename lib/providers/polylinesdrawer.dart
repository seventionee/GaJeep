import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import '../providers/route_details.dart';

// Modify the function to accept routeNumber
Future<int> getActiveVehiclesForRoute(String routeNumber) async {
  CollectionReference collection =
      FirebaseFirestore.instance.collection('Routes');
  DocumentSnapshot routeDoc = await collection.doc(routeNumber).get();

  QuerySnapshot vehicleSnapshot = await routeDoc.reference
      .collection('Vehicles')
      .where('Status', isEqualTo: 'Active')
      .get();

  return vehicleSnapshot.docs.length;
}

Future<List<Polyline>> getPolylinesFromFirestore(BuildContext context) async {
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
    String routeDescription = (doc['Route Description']);
    List<LatLng> latLngPoints = geoPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    debugPrint('Polyline fetch for $routeNumber: $latLngPoints');

    //polyline color auto adjustable from rgb
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

    // Call the modified function and print the active vehicles for the specific route
    int activeVehiclesForRoute = await getActiveVehiclesForRoute(routeNumber);
    debugPrint('Active vehicles for $routeNumber: $activeVehiclesForRoute');

    Polyline polyline = Polyline(
        polylineId: PolylineId(polylineIdCounter.toString()),
        points: latLngPoints,
        color: polylineColor,
        width: 5,
        consumeTapEvents: true,
        onTap: () {
          debugPrint('Polyline is TAPPED!');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return RouteDetailsModal(
                routeName: routeNumber,
                routeDescription: routeDescription,
              );
            },
          );
        });

    polylines.add(polyline);
    polylineIdCounter++;
  }
  return polylines;
}
