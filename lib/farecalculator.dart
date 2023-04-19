import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrentLocationScreen extends StatefulWidget {
  static const routeName = '/currentlocationscreen';
  const CurrentLocationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  late GoogleMapController mapController;
  late LatLng currentLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Current Location"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.4219999, -122.0840575),
                zoom: 10,
              ),
              onTap: _onMapTapped,
              markers: _createMarkers(),
            ),
          ),
          ElevatedButton(
            onPressed: currentLocation != null ? _onLocationSelected : null,
            child: const Text("Select Location"),
          ),
        ],
      ),
    );
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};
    markers.add(
      Marker(
        markerId: const MarkerId("currentLocation"),
        position: currentLocation,
      ),
    );
    return markers;
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      currentLocation = location;
    });
  }

  void _onLocationSelected() {
    // TODO: do something with the selected location
  }
}