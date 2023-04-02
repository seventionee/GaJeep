import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class Mapsinterface extends StatefulWidget {
  static const routeName = '/mapsinterface';
  const Mapsinterface({Key? key}) : super(key: key);
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
                //GOOGLEMAP START
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
                //GOOGLE MAP END
                //MENU START
                Positioned(
                    top: 30,
                    left: 16,
                    child: Container(
                      //style for menu button
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black, // set the border color
                          width: 1.0, // set the border width
                        ),
                        borderRadius: BorderRadius.circular(
                            25.0), // set the border radius
                      ),
                      child: FloatingActionButton.extended(
                        heroTag: null,
                        label: const Text(
                          'Menu',
                          style: TextStyle(
                            fontFamily: 'Epilogue', //font style
                            fontWeight: FontWeight.w400,
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
                        ),
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          // Add your action here
                        },
                        tooltip: 'Options',
                        icon: const Icon(Icons.menu),
                      ),
                    )),
                //MENU END
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: FloatingActionButton.small(
                    heroTag: null,
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    backgroundColor: Theme.of(context).colorScheme.primary,
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
