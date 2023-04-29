import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VehicleLocationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<MarkerId, Marker> _vehicleMarkers = {};

  Map<MarkerId, Marker> get vehicleMarkers => _vehicleMarkers;

  StreamSubscription? _locationSubscription;

  VehicleLocationProvider() {
    _initVehicleMarkers();
  }

  void _initVehicleMarkers() {
    _firestore.collectionGroup('Vehicles').snapshots().listen((snapshots) {
      for (var snapshot in snapshots.docs) {
        _updateMarker(snapshot);
      }
    });
  }

  void _updateMarker(DocumentSnapshot snapshot) {
    MarkerId markerId = MarkerId(snapshot.id);
    if (snapshot.exists && snapshot['Status'] == 'Active') {
      GeoPoint location = snapshot['Location'];
      String jeepRoute = snapshot['Route Number'];
      String capacitystatus = snapshot['Capacity'];
      LatLng position = LatLng(location.latitude, location.longitude);
      Marker marker = Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(title: ' Jeep: $jeepRoute is $capacitystatus'),
      );
      _vehicleMarkers[markerId] = marker;
      notifyListeners();
    } else if (_vehicleMarkers.containsKey(markerId)) {
      _vehicleMarkers.remove(markerId);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
