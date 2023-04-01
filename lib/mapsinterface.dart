import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';

// ignore: use_key_in_widget_constructors
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
            body: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) async {
                    _controller = controller;
                    _controller.setMapStyle(snapshot.data!);
                  },
                  compassEnabled: false,
                  minMaxZoomPreference: const MinMaxZoomPreference(17, 19),
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(10.3156173, 123.882969),
                    zoom: 19,
                  ),
                  zoomControlsEnabled: false, // Remove zoom controls
                  myLocationButtonEnabled: false, // Remove location button
                  mapToolbarEnabled: false,
                ),
                Positioned(
                  top: 50,
                  left: 16,
                  right: 16,
                  child: SearchMapPlaceWidget(
                    apiKey: 'AIzaSyBOS4cS8wIYV2tRBhtf5O2hnIZ1Iley9Jc',
                    language: 'en',
                    bgColor: Colors.white,
                    iconColor: Theme.of(context).colorScheme.primary,
                    textColor: Colors.black,
                    placeholder: 'Where do you want to go to?',
                    onSelected: (Place place) async {
                      final geolocation = await place.geolocation;
                      final cameraUpdate =
                          CameraUpdate.newLatLng(geolocation!.coordinates!);
                      _controller.animateCamera(cameraUpdate);
                    },
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    onPressed: _showUserLocation,
                    tooltip: 'Show user location',
                    child: const Icon(Icons.location_searching),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
