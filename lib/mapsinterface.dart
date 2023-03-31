import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class Mapsinterface extends StatefulWidget {
  static const routeName = '/mapsinterface';

  @override
  createState() => _Mapsinterface();
}

class _Mapsinterface extends State<Mapsinterface> {
  late GoogleMapController _controller;

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    await Permission.location.request();
  }

  void _showUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    final Position position = await Geolocator.getCurrentPosition();
    final CameraPosition userPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 19,
    );
    _controller.animateCamera(CameraUpdate.newCameraPosition(userPosition));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getJsonFile('asset/mapstyle.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return MaterialApp(
          home: Scaffold(
            body: GoogleMap(
              onMapCreated: (GoogleMapController controller) async {
                _controller = controller;
                _controller.setMapStyle(snapshot.data!);
              },
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: const CameraPosition(
                target: LatLng(10.3156173, 123.882969),
                zoom: 19,
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: _showUserLocation,
              tooltip: 'Show user location',
              child: const Icon(Icons.location_searching),
            ),
          ),
        );
      },
    );
  }
}
