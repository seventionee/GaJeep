import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../providers/route_details.dart';

Stream<int> getActiveVehiclesForRoute(String routeNumber) async* {
  CollectionReference collection =
      FirebaseFirestore.instance.collection('Routes');
  DocumentSnapshot routeDoc = await collection.doc(routeNumber).get();

  yield* routeDoc.reference
      .collection('Vehicles')
      .where('Status', isEqualTo: 'Active')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}

Stream<List<Map<String, dynamic>>> getActiveVehiclesListForRoute(
    String routeNumber) async* {
  CollectionReference collection =
      FirebaseFirestore.instance.collection('Routes');
  DocumentSnapshot routeDoc = await collection.doc(routeNumber).get();

  yield* routeDoc.reference
      .collection('Vehicles')
      .where('Status', isEqualTo: 'Active')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              'plateNumber': doc['Plate Number'],
              'capacityStatus': doc['Capacity'],
              'Location': doc['Location']
            };
          }).toList());
}

Future<List<Polyline>> getPolylinesFromFirestore(BuildContext context) async {
  List<Polyline> polylines = [];
  int polylineIdCounter = 1;

  CollectionReference collection =
      FirebaseFirestore.instance.collection('Routes');
  QuerySnapshot querySnapshot = await collection.get();

  int numPolylines = querySnapshot.docs.length;
  double hueStep = 360 / numPolylines;

  //for ROUTE POINTS 1
  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    String routeNumber = (doc['Route Number']);
    debugPrint('Show polyline $routeNumber');
    List<GeoPoint> geoPoints = List.from(doc['Route Points 1']);
    String routeDescription = (doc['Direction Description 1']);
    String routeOrientation = (doc['Direction Orientation 1']);
    List<LatLng> latLngPoints = geoPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    debugPrint('Polyline fetch for $routeNumber: $latLngPoints');

    //polyline color auto adjustable from rgb
    ui.Color polylineColor = ui.Color.fromARGB(
      255,
      HSVColor.fromAHSV(
              1.0, (hueStep * (polylineIdCounter - 1)) % 360, 1.0, 1.0)
          .toColor()
          .red,
      HSVColor.fromAHSV(
              1.0, (hueStep * (polylineIdCounter - 1)) % 360, 1.0, 1.0)
          .toColor()
          .green,
      HSVColor.fromAHSV(
              1.0, (hueStep * (polylineIdCounter - 1)) % 360, 1.0, 1.0)
          .toColor()
          .blue,
    );

    Polyline polyline = Polyline(
        polylineId: PolylineId(polylineIdCounter.toString()),
        points: latLngPoints,
        color: polylineColor,
        width: 3,
        consumeTapEvents: true,
        onTap: () {
          debugPrint('Polyline is TAPPED!');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return RouteDetailsModal(
                routeName: routeNumber,
                directionDescription: routeDescription,
                directionOrientation: routeOrientation,
              );
            },
          );
        });

    polylines.add(polyline);
    polylineIdCounter++;
  }

  //for ROUTE POINTS 2
  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    String routeNumber = (doc['Route Number']);
    debugPrint('Show polyline $routeNumber');
    List<GeoPoint> geoPoints = List.from(doc['Route Points 2']);
    String routeDescription = (doc['Direction Description 2']);
    String routeOrientation = (doc['Direction Orientation 2']);
    List<LatLng> latLngPoints = geoPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    debugPrint('Polyline fetch for $routeNumber: $latLngPoints');

    //polyline color auto adjustable from rgb
    ui.Color polylineColor = ui.Color.fromARGB(
      255,
      HSVColor.fromAHSV(
              1.0, (hueStep * (polylineIdCounter - 1)) % 360, 1.0, 1.0)
          .toColor()
          .red,
      HSVColor.fromAHSV(
              1.0, (hueStep * (polylineIdCounter - 1)) % 360, 1.0, 1.0)
          .toColor()
          .green,
      HSVColor.fromAHSV(
              1.0, (hueStep * (polylineIdCounter - 1)) % 360, 1.0, 1.0)
          .toColor()
          .blue,
    );

    Polyline polyline = Polyline(
        polylineId: PolylineId(polylineIdCounter.toString()),
        points: latLngPoints,
        color: polylineColor,
        width: 3,
        consumeTapEvents: true,
        onTap: () {
          debugPrint('Polyline is TAPPED!');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return RouteDetailsModal(
                routeName: routeNumber,
                directionDescription: routeDescription,
                directionOrientation: routeOrientation,
              );
            },
          );
        });

    polylines.add(polyline);
    polylineIdCounter++;
  }
  return polylines;
}

Future<List<Marker>> getDirectionMarkersforAll(BuildContext context) async {
  List<Marker> markers = [];
  int markerIdCounter = 1;
  Future<BitmapDescriptor> directionMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'asset/icons/arrow_up.png',
    );
  }

  CollectionReference collection =
      FirebaseFirestore.instance.collection('Routes');
  QuerySnapshot querySnapshot = await collection.get();

  //for ROUTE POINTS 1
  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    String routeNumber = (doc['Route Number']);
    debugPrint('Show polyline $routeNumber');
    List<GeoPoint> geoPoints = List.from(doc['Route Points 1']);

    List<LatLng> latLngPoints = geoPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    debugPrint('Polyline fetch for $routeNumber: $latLngPoints');
    debugPrint('Polyline fetch for $routeNumber: $latLngPoints');
    final directionIcon = await directionMarker();
    for (int i = 10; i < latLngPoints.length; i += 50) {
      // Change 10 to whatever interval you want

      Marker marker = Marker(
        markerId: MarkerId((markerIdCounter++).toString()),
        flat: true,
        position: latLngPoints[i],
        icon: directionIcon,
        rotation: i < latLngPoints.length - 1
            ? getBearing(latLngPoints[i], latLngPoints[i + 1])
            : 0,
      );
      debugPrint('Marker has been added for ALL $marker');
      markers.add(marker);
    }
  }

  //for ROUTE POINTS 2
  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    String routeNumber = (doc['Route Number']);
    debugPrint('Show polyline $routeNumber');

    List<GeoPoint> geoPoints = List.from(doc['Route Points 2']);
    List<LatLng> latLngPoints = geoPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    debugPrint('Polyline fetch for $routeNumber: $latLngPoints');
    final directionIcon = await directionMarker();
    for (int i = 10; i < latLngPoints.length; i += 50) {
      // Change 10 to whatever interval you want

      Marker marker = Marker(
        markerId: MarkerId((markerIdCounter++).toString()),
        flat: true,
        position: latLngPoints[i],
        icon: directionIcon,
        rotation: i < latLngPoints.length - 1
            ? getBearing(latLngPoints[i], latLngPoints[i + 1])
            : 0,
      );
      debugPrint('Marker has been added for ALL $marker');
      markers.add(marker);
    }
  }
  return markers;
}

Future<List<Polyline>> getPolylineForSpecificRoute(BuildContext context,
    {String? selectedRoute, required bool useRoutePoints1}) async {
  List<Polyline> polylines = [];
  int polylineIdCounter = 1;

  CollectionReference collection =
      FirebaseFirestore.instance.collection('Routes');
  QuerySnapshot querySnapshot = await collection.get();

  int numPolylines = querySnapshot.docs.length;
  double hueStep = 360 / numPolylines;

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    if ((doc['Route Number']) == selectedRoute) {
      List<GeoPoint> geoPoints = useRoutePoints1
          ? List.from(doc['Route Points 2'])
          : List.from(doc['Route Points 1']);
      String routeNumber = (doc['Route Number']);
      String routeDescription = useRoutePoints1
          ? (doc['Direction Description 2'])
          : (doc['Direction Description 1']);
      String routeOrientation = useRoutePoints1
          ? (doc['Direction Orientation 2'])
          : (doc['Direction Orientation 1']);
      debugPrint('Polyline for route number $routeNumber');
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

      Polyline polyline = Polyline(
          polylineId: PolylineId(polylineIdCounter.toString()),
          points: latLngPoints,
          color: polylineColor,
          width: 3,
          consumeTapEvents: true,
          onTap: () {
            debugPrint('Polyline is TAPPED!');
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return RouteDetailsModal(
                  routeName: routeNumber,
                  directionDescription: routeDescription,
                  directionOrientation: routeOrientation,
                );
              },
            );
          });

      polylines.add(polyline);
      polylineIdCounter++;
    }
  }
  return polylines;
}

Future<List<Polyline>> getPolylineforCalculator(BuildContext context,
    {String? selectedRoute, required bool useRoutePoints1}) async {
  List<Polyline> polylines = [];
  int polylineIdCounter = 1;

  CollectionReference collection =
      FirebaseFirestore.instance.collection('Routes');
  QuerySnapshot querySnapshot = await collection.get();

  int numPolylines = querySnapshot.docs.length;
  double hueStep = 360 / numPolylines;

  // Ensure you have an arrow image in your assets

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    if ((doc['Route Number']) == selectedRoute) {
      List<GeoPoint> geoPoints = useRoutePoints1
          ? List.from(doc['Route Points 2'])
          : List.from(doc['Route Points 1']);
      String routeNumber = (doc['Route Number']);
      debugPrint('Polyline for route number $routeNumber');
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

      Polyline polyline = Polyline(
        polylineId: PolylineId(polylineIdCounter.toString()),
        points: latLngPoints,
        color: polylineColor,
        width: 3,
        consumeTapEvents: false,
      );

      polylines.add(polyline);

      polylineIdCounter++;
    }
  }
  return polylines;
}

Future<List<Marker>> getDirectionMarkers(BuildContext context,
    {String? selectedRoute, required bool useRoutePoints1}) async {
  List<Marker> markers = [];
  int markerIdCounter = 1;

  CollectionReference collection =
      FirebaseFirestore.instance.collection('Routes');
  QuerySnapshot querySnapshot = await collection.get();

  Future<BitmapDescriptor> directionMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'asset/icons/arrow_up.png',
    );
  } // Ensure you have an arrow image in your assets

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    if ((doc['Route Number']) == selectedRoute) {
      List<GeoPoint> geoPoints = useRoutePoints1
          ? List.from(doc['Route Points 2'])
          : List.from(doc['Route Points 1']);
      List<LatLng> latLngPoints = geoPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      final directionIcon = await directionMarker();
      // Add markers for direction indication
      for (int i = 10; i < latLngPoints.length; i += 60) {
        // Change 10 to whatever interval you want

        Marker marker = Marker(
          markerId: MarkerId((markerIdCounter++).toString()),
          flat: true,
          anchor: const Offset(0, 0.25),
          position: latLngPoints[i],
          icon: directionIcon,
          rotation: i < latLngPoints.length - 1
              ? getBearing(latLngPoints[i], latLngPoints[i + 1])
              : 0,
        );
        debugPrint('Marker has been added for main map $marker');
        markers.add(marker);
      }
    }
  }
  return markers;
}

Future<List<Marker>> getDirectionMarkersforCalculator(BuildContext context,
    {String? selectedRoute,
    required bool useRoutePoints1,
    required Function(LatLng) handleTap}) async {
  List<Marker> markers = [];
  int markerIdCounter = 1;

  CollectionReference collection =
      FirebaseFirestore.instance.collection('Routes');
  QuerySnapshot querySnapshot = await collection.get();

  Future<BitmapDescriptor> directionMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'asset/icons/arrow_up.png',
    );
  } // Ensure you have an arrow image in your assets

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    if ((doc['Route Number']) == selectedRoute) {
      List<GeoPoint> geoPoints = useRoutePoints1
          ? List.from(doc['Route Points 2'])
          : List.from(doc['Route Points 1']);
      List<LatLng> latLngPoints = geoPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      final directionIcon = await directionMarker();
      // Add markers for direction indication
      for (int i = 10; i < latLngPoints.length; i += 60) {
        // Change 10 to whatever interval you want

        LatLng currentPoint = latLngPoints[i];

        onTap() {
          handleTap(currentPoint);
        }

        Marker marker = Marker(
          markerId: MarkerId((markerIdCounter++).toString()),
          flat: true,
          anchor: const Offset(0, 0.25),
          position: currentPoint,
          icon: directionIcon,
          consumeTapEvents: true,
          onTap: onTap,
          rotation: i < latLngPoints.length - 1
              ? getBearing(latLngPoints[i], latLngPoints[i + 1])
              : 0,
        );
        debugPrint('Marker has been added for main map $marker');
        markers.add(marker);
      }
    }
  }
  return markers;
}

//getting bearing for markers
double getBearing(LatLng from, LatLng to) {
  double deltaLong = to.longitude - from.longitude;
  double lat1 = toRadians(from.latitude);
  double lat2 = toRadians(to.latitude);
  double longDelta = toRadians(deltaLong);

  double y = sin(longDelta) * cos(lat2);
  double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(longDelta);

  return ((toDegrees(atan2(y, x)) + 360) % 360);
}

double toRadians(double degree) {
  return degree * pi / 180;
}

double toDegrees(double radian) {
  return radian * 180 / pi;
}

Future<String> getDirectionDescription(
    String? selectedRoute, bool useRoutePoints1) async {
  CollectionReference collection =
      FirebaseFirestore.instance.collection('Routes');
  QuerySnapshot querySnapshot = await collection.get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    if (doc['Route Number'] == selectedRoute) {
      if (useRoutePoints1) {
        return doc['Direction Description 2'];
      } else {
        return doc['Direction Description 1'];
      }
    }
  }

  return '';
}

Future<String> getDirectionOrientation(
    String? selectedRoute, bool useRoutePoints1) async {
  CollectionReference collection =
      FirebaseFirestore.instance.collection('Routes');
  QuerySnapshot querySnapshot = await collection.get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    if (doc['Route Number'] == selectedRoute) {
      if (useRoutePoints1) {
        return doc['Direction Orientation 2'];
      } else {
        return doc['Direction Orientation 1'];
      }
    }
  }

  return '';
}
