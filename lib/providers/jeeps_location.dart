import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VehicleInfo {
  final String jeepRoute;
  final String capacityStatus;

  VehicleInfo({required this.jeepRoute, required this.capacityStatus});
}

class VehicleLocationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  //to lock view on selected marker
  MarkerId? _lockedMarkerId;

  //check if marker still exists
  bool isSelectedMarkerValid() {
    return _selectedMarkerId != null &&
        _vehicleMarkers.containsKey(_selectedMarkerId);
  }

  Future<bool> isMarkerVisible(MarkerId? markerId) async {
    if (markerId == null) return false;
    // Introduce a delay to account for the brief moment the marker vanishes
    await Future.delayed(const Duration(milliseconds: 100));
    return _vehicleMarkers.containsKey(markerId);
  }

  void updateMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void _updateCameraPosition(
      GoogleMapController? controller, LatLng newPosition) {
    if (_lockedMarkerId != null &&
        _selectedMarkerId == _lockedMarkerId &&
        controller != null) {
      controller.animateCamera(
        CameraUpdate.newLatLng(newPosition),
      );
    }
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void deselectMarker() {
    _selectedMarkerId = null;
    _selectedJeepRoute = null;
    _selectedCapacityStatus = null;
    notifyListeners();
  }

  final Map<MarkerId, Marker> _vehicleMarkers = {};
  final Map<MarkerId, String> _previousCapacityStatus = {};

  Map<MarkerId, Marker> get vehicleMarkers => _vehicleMarkers;

  StreamSubscription? _locationSubscription;

  String? _selectedJeepRoute;
  String? _selectedCapacityStatus;

  MarkerId? _selectedMarkerId;

  MarkerId? get selectedMarkerId => _selectedMarkerId;
  String? get selectedJeepRoute => _selectedJeepRoute;
  String? get selectedCapacityStatus => _selectedCapacityStatus;

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
      String capacityStatus = snapshot['Capacity'];
      LatLng position = LatLng(location.latitude, location.longitude);
      Marker marker = Marker(
        markerId: markerId,
        position: position,
        onTap: () {
          _selectedMarkerId = markerId;
          _selectedJeepRoute = jeepRoute;
          _selectedCapacityStatus = capacityStatus;
          _lockedMarkerId = markerId; // Lock the marker when tapped
          notifyListeners();
        },
      );

      // Update camera position if locked marker position changed
      if (_lockedMarkerId == markerId) {
        _updateCameraPosition(_mapController, position);
      }

      // Check if capacityStatus has changed for the selected marker
      bool capacityStatusChanged = _selectedMarkerId == markerId &&
          _previousCapacityStatus[markerId] != capacityStatus;

      if (capacityStatusChanged) {
        _selectedCapacityStatus = capacityStatus;
        notifyListeners();
      }

      _previousCapacityStatus[markerId] = capacityStatus;
      _vehicleMarkers[markerId] = marker;
      notifyListeners();
    } else if (_vehicleMarkers.containsKey(markerId)) {
      _vehicleMarkers.remove(markerId);
      _previousCapacityStatus.remove(markerId);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
