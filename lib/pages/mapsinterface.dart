import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../providers/request_location_permission.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';
import '../component/constants.dart';
import 'learnmore.dart';
import '../providers/polylinesdrawer.dart';
import '../providers/jeeps_location.dart';
import 'package:provider/provider.dart';
import '../providers/jeep_info.dart';
import 'routes_directory.dart';

// ignore: use_key_in_widget_constructors
class Mapsinterface extends StatefulWidget {
  static const routeName = '/mapsinterface';
  final LatLng initialPosition;

  const Mapsinterface({Key? key, required this.initialPosition})
      : super(key: key);
  @override
  createState() => _Mapsinterface();
}

class _Mapsinterface extends State<Mapsinterface> {
  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer(); //for controlling google map interface
  Set<Polyline> mappolylines = {}; //for polylines
  bool _isrouteshown = true; //for toggling polylines appearance

  LatLng userLocation = const LatLng(10.298333, 123.893366);
  bool _showUserLocation = false;
  StreamSubscription<Position>?
      positionStreamSubscription; //constantly check user position

  //for maps style
  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    subscribeUserLocationUpdates();
    getPolylinesFromFirestore(context).then((polylines) {
      setState(() {
        mappolylines = polylines.toSet();
      });
    });
  }

  void onCameraMoveHandler(CameraPosition position,
      VehicleLocationProvider vehicleLocationProvider) {
    if (vehicleLocationProvider.selectedMarkerId != null) {
      LatLng currentPosition = vehicleLocationProvider
          .vehicleMarkers[vehicleLocationProvider.selectedMarkerId]!.position;

      //getting distance
      double distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          position.target.latitude,
          position.target.longitude);

      if (distance > 250) {
        // You can adjust this threshold value as needed
        vehicleLocationProvider.deselectMarker();
      }
    }
  }

  //toggling routes visibility via FAB
  void _toggleroutesvisibility() {
    setState(() {
      _isrouteshown = !_isrouteshown;
    });
  }

  void updateMapController(
      BuildContext context, GoogleMapController controller) {
    Provider.of<VehicleLocationProvider>(context, listen: false)
        .updateMapController(controller);
  }

  //constantly check user location
  void subscribeUserLocationUpdates() async {
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

    positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    )).listen((Position position) async {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });
      if (_showUserLocation) {
        final GoogleMapController controller =
            await _mapControllerCompleter.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: userLocation, zoom: 17)));
      }
    });
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: FutureBuilder(
        future: getJsonFile('asset/mapstyle.json'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          return Scaffold(
            //MENU
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                //MENU
                children: <Widget>[
                  //MENU HEADER
                  const DrawerHeader(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('asset/drawerheadernobackground.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: null),
                  //ROUTE DIRECTORY
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 1.0,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25.0)),
                        color: primaryColor,
                      ),
                      child: ListTile(
                        title: const Text(
                          'Route Directory',
                          style: TextStyle(
                              fontFamily: 'Epilogue', //font style
                              fontWeight: FontWeight.w400,
                              fontSize: 20.0,
                              color: Colors.black),
                        ),
                        tileColor: backgroundColor,
                        leading: const Icon(
                            Icons.directions_transit_filled_sharp,
                            color: Colors.black),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(RoutesDirectory.routeName);
                        },
                      ),
                    ),
                  ),
                  //FARE CALCULATOR
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 1.0,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25.0)),
                        color: primaryColor,
                      ),
                      child: ListTile(
                        title: const Text(
                          'Fare Calculator',
                          style: TextStyle(
                            fontFamily: 'Epilogue', //font style
                            fontWeight: FontWeight.w400,
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
                        ),
                        leading: const Icon(Icons.calculate_rounded,
                            color: Colors.black),
                        onTap: () {},
                      ),
                    ),
                  ),
                  //ABOUT GAJEEP
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 1.0,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25.0)),
                        color: primaryColor,
                      ),
                      child: ListTile(
                        title: const Text(
                          'About GaJeep',
                          style: TextStyle(
                            fontFamily: 'Epilogue', //font style
                            fontWeight: FontWeight.w400,
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
                        ),
                        leading: const Icon(Icons.info_outline_rounded,
                            color: Colors.black),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            LearnMorePage.routeName,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //END OF MENU DRAWER

            //REST OF INTERFACE
            body: Builder(builder: (context) {
              return Stack(
                children: [
                  //GOOGLE MAPS
                  Consumer<VehicleLocationProvider>(
                    builder: (context, vehicleLocationProvider, child) {
                      debugPrint(
                          'Selected marker: ${vehicleLocationProvider.selectedMarkerId}'); // Add this print statement
                      debugPrint(
                          'Selected jeep route: ${vehicleLocationProvider.selectedJeepRoute}'); // Add this print statement
                      debugPrint(
                          'Selected capacity status: ${vehicleLocationProvider.selectedCapacityStatus}'); // Add this print statement
                      return Stack(
                        children: [
                          GoogleMap(
                            onTap: (LatLng position) {
                              debugPrint('TAPPED ON GOOGLE MAPS');
                              vehicleLocationProvider.deselectMarker();
                            },
                            onCameraMove: (position) {
                              onCameraMoveHandler(
                                  position, vehicleLocationProvider);
                            },
                            onMapCreated:
                                (GoogleMapController controller) async {
                              _mapControllerCompleter.complete(controller);
                              updateMapController(context, controller);
                              controller.setMapStyle(snapshot.data!);
                            },
                            compassEnabled: false,
                            minMaxZoomPreference:
                                const MinMaxZoomPreference(15, 20),
                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            initialCameraPosition: CameraPosition(
                              target: widget.initialPosition,
                              zoom: 17,
                            ),
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            mapToolbarEnabled: false,
                            polylines: _isrouteshown ? mappolylines : {},
                            markers: vehicleLocationProvider
                                .vehicleMarkers.values
                                .toSet(),
                          ),
                          if (vehicleLocationProvider.selectedMarkerId != null)
                            if (vehicleLocationProvider.selectedMarkerId !=
                                    null &&
                                !vehicleLocationProvider.isUpdatingWidget)
                              Align(
                                alignment: Alignment.center,
                                child: Visibility(
                                  visible: vehicleLocationProvider
                                              .selectedMarkerId !=
                                          null &&
                                      !vehicleLocationProvider.isUpdatingWidget,
                                  child: VehicleInfoWidget(
                                    jeepRoute: vehicleLocationProvider
                                            .selectedJeepRoute ??
                                        '',
                                    capacityStatus: vehicleLocationProvider
                                            .selectedCapacityStatus ??
                                        '',
                                  ),
                                ),
                              ),
                        ],
                      );
                    },
                  ),

                  //MENU BUTTON
                  Positioned(
                      bottom: 90,
                      right: 16,
                      child: Container(
                        //style for menu button
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black, // set the border color
                            width: 1.0, // set the border width
                          ),
                          borderRadius: BorderRadius.circular(
                              50.0), // set the border radius
                        ),
                        child: FloatingActionButton(
                          heroTag: null,
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          backgroundColor: primaryColor,
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: const Icon(Icons.menu_rounded),
                        ),
                      )),

                  //SHOW USER LOCATION FAB
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black, // set the border color
                          width: 1.0, // set the border width
                        ),
                        borderRadius: BorderRadius.circular(
                            50.0), // set the border radius
                      ),
                      child: FloatingActionButton(
                        heroTag: null,
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        backgroundColor: secondaryColor,
                        onPressed: () async {
                          setState(() {
                            _showUserLocation = true;
                          });
                          final GoogleMapController controller =
                              await _mapControllerCompleter.future;
                          controller.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(target: userLocation, zoom: 17),
                            ),
                          );
                        },
                        child: const Icon(Icons.location_searching),
                      ),
                    ),
                  ),

                  //TOGGLE DIRECTIONS APPERANCE FAB
                  Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black, // set the border color
                            width: 1.0, // set the border width
                          ),
                          borderRadius: BorderRadius.circular(
                              50.0), // set the border radius
                        ),
                        child: FloatingActionButton(
                          heroTag: null,
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          backgroundColor: secondaryColor,
                          onPressed: _toggleroutesvisibility,
                          child: Icon(_isrouteshown
                              ? Icons.directions
                              : Icons.directions_off),
                        ),
                      )),

                  //SEARCH MAP WIDGET
                  Positioned(
                    top: 50,
                    left: 16,
                    right: 16,
                    child: SearchMapPlaceWidget(
                      apiKey: 'AIzaSyBOS4cS8wIYV2tRBhtf5O2hnIZ1Iley9Jc',
                      language: 'en',
                      bgColor: Colors.white,
                      location: userLocation,
                      radius: 14697,
                      strictBounds: true,
                      iconColor: Colors.black,
                      textColor: Colors.black,
                      placeholder: 'Where do you want to go to?',
                      onSelected: (Place place) async {
                        final geolocation = await place.geolocation;
                        final cameraUpdate =
                            CameraUpdate.newLatLng(geolocation!.coordinates!);
                        // Use the mapcontroller from the Completer
                        final GoogleMapController controller =
                            await _mapControllerCompleter.future;
                        controller.animateCamera(cameraUpdate);
                      },
                    ),
                  ),
                ],
              );
            }),
          );
        },
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Exit',
            style: TextStyle(
              fontFamily: 'Epilogue', //font style
              fontWeight: FontWeight.w400,
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Are you sure you want to exit?',
            style: TextStyle(
              fontFamily: 'Epilogue', //font style
              fontWeight: FontWeight.w400,
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              child: const Text(
                'No',
                style: TextStyle(
                  fontFamily: 'Epilogue', //font style
                  fontWeight: FontWeight.w400,
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontFamily: 'Epilogue', //font style
                  fontWeight: FontWeight.w400,
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
    return false;
  }
}
