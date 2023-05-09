import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class VehicleInfo {
  final String jeepRoute;
  final String capacityStatus;

  VehicleInfo({required this.jeepRoute, required this.capacityStatus});
}

class VehicleLocationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  String? _selectedRoute;
  MarkerId? _lockedMarkerId;
  String? _routeFilter;
  late Set<Polyline> _mappolylines;

  // Store the previous locations of each vehicle
  final Map<MarkerId, LatLng> _previousLocations = {};

  void setSelectedRoute(String? route) {
    _selectedRoute = route;
    notifyListeners();
  }

  Future<BitmapDescriptor> jeepMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'asset/icons/jeep_up.png',
    );
  }

  void deselectMarker() {
    _selectedMarkerId = null;
    _selectedJeepRoute = null;
    _selectedCapacityStatus = null;
    _selectedPlateNumber = null;
    notifyListeners();
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

  final bool _updatingWidget = false;

  bool get isUpdatingWidget => _updatingWidget;

  void updateMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  final Map<MarkerId, Marker> _vehicleMarkers = {};
  final Map<MarkerId, String> _previousCapacityStatus = {};

  Map<MarkerId, Marker> get vehicleMarkers => _vehicleMarkers;

  StreamSubscription? _locationSubscription;

  String? _selectedJeepRoute;
  String? _selectedCapacityStatus;
  String? _selectedPlateNumber;
  String? _selectedPicture;

  MarkerId? _selectedMarkerId;

  MarkerId? get selectedMarkerId => _selectedMarkerId;
  String? get selectedJeepRoute => _selectedJeepRoute;
  String? get selectedCapacityStatus => _selectedCapacityStatus;
  String? get selectedPlateNumber => _selectedPlateNumber;
  String? get selectedPicture => _selectedPicture;

  VehicleLocationProvider(
      {String? routeFilter, required Set<Polyline> mappolylines}) {
    _routeFilter = routeFilter;
    _mappolylines = mappolylines;
    _initVehicleMarkers();
  }

  void _initVehicleMarkers() {
    _firestore.collectionGroup('Vehicles').snapshots().listen((snapshots) {
      for (var snapshot in snapshots.docs) {
        _updateMarker(snapshot);
      }
    });
  }

  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    var y = sin(lon2 - lon1) * cos(lat2);
    var x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);
    var bearing = atan2(y, x);

    // Convert radian to degree and normalize the bearing
    bearing = (degrees(bearing) + 360) % 360;

    return bearing;
  }

  double degrees(double radians) => radians * 180.0 / pi;

  double radians(double degrees) {
    return degrees * pi / 180;
  }

  void _updateMarker(DocumentSnapshot snapshot) async {
    MarkerId markerId = MarkerId(snapshot.id);

    debugPrint('CHECKING FOR SELECTEDROUTE TO DISPLAY $_selectedRoute');
    if (snapshot.exists &&
        snapshot['Status'] == 'Active' &&
        (_routeFilter == null || snapshot['Route Number'] == _routeFilter)) {
      GeoPoint location = snapshot['Location'];
      LatLng locationlatlng = LatLng(location.latitude, location.longitude);

      // Get the previous location for this vehicle
      LatLng? previousLocation = _previousLocations[markerId];

      double bearing = 0.0;

// Check if there is a previous location
      if (previousLocation != null) {
        // Calculate bearing based on previous and current location
        bearing = calculateBearing(
            radians(previousLocation.latitude),
            radians(previousLocation.longitude),
            radians(locationlatlng.latitude),
            radians(locationlatlng.longitude));
      } else {
        // Use the initial bearing from the snapshot for the first update
        bearing = snapshot['Bearing'] is double
            ? snapshot['Bearing']
            : double.parse(
                snapshot['Bearing'].toString()); // Handle different data types
      }

// Store the current location as the previous location for the next update
      _previousLocations[markerId] = locationlatlng;

// Continue with the rest of your code...

      String jeepRoute = snapshot['Route Number'];
      String capacityStatus = snapshot['Capacity'];
      String plateNumber = snapshot['Plate Number'];
      String picture = snapshot['Picture'];

      LatLng snappedPosition =
          findNearestPolylinePoint(locationlatlng, _mappolylines);
      final jeepIcon = await jeepMarker();
      debugPrint('Bearing for $jeepRoute: $bearing');
      LatLng position = LatLng(location.latitude, location.longitude);
      Marker marker = Marker(
        icon: jeepIcon,
        markerId: markerId,
        position: snappedPosition,
        rotation: bearing,
        onTap: () {
          _selectedMarkerId = markerId;
          _selectedJeepRoute = jeepRoute;
          _selectedCapacityStatus = capacityStatus;
          _selectedPicture = picture;
          _selectedPlateNumber = plateNumber;
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
      _previousLocations.remove(markerId);

      if (_selectedMarkerId == markerId) {
        deselectMarker();
      } else {
        notifyListeners();
      }
    }
  }

  //SNAPPING JEEP TO POLYLINES
  double distanceBetweenLatLng(LatLng point1, LatLng point2) {
    // Convert latitude and longitude to radians
    double lat1 = point1.latitude * (pi / 180);
    double lon1 = point1.longitude * (pi / 180);
    double lat2 = point2.latitude * (pi / 180);
    double lon2 = point2.longitude * (pi / 180);

    // Haversine formula to calculate the great-circle distance between two points
    double a = pow(sin((lat2 - lat1) / 2), 2) +
        cos(lat1) * cos(lat2) * pow(sin((lon2 - lon1) / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Earth radius in meters
    double radius = 6371000;

    // Calculate the distance
    double distance = radius * c;

    return distance;
  }

  LatLng findNearestPolylinePoint(
      LatLng vehiclePosition, Set<Polyline> polylines) {
    // Ensure that there is at least one polyline with points
    if (polylines.isEmpty) {
      throw ArgumentError(
          'The polylines set must contain at least one polyline with points');
    }

    // Initialize the nearestPoint variable
    LatLng nearestPoint = polylines
        .firstWhere((polyline) => polyline.points.isNotEmpty)
        .points
        .first;
    double minDistance = double.infinity;

    for (Polyline polyline in polylines) {
      for (LatLng polylinePoint in polyline.points) {
        double currentDistance =
            distanceBetweenLatLng(vehiclePosition, polylinePoint);
        if (currentDistance < minDistance) {
          minDistance = currentDistance;
          nearestPoint = polylinePoint;
        }
      }
    }

    return nearestPoint;
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
