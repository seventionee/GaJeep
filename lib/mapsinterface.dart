import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';
import 'component/constants.dart';
import 'learnmore.dart';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: use_key_in_widget_constructors
class Mapsinterface extends StatefulWidget {
  static const routeName = '/mapsinterface';
  const Mapsinterface({Key? key}) : super(key: key);
  @override
  createState() => _Mapsinterface();
}

class _Mapsinterface extends State<Mapsinterface> {
  late GoogleMapController _controller;
  Set<Polyline> _polylines = {};
  bool _isrouteshown = true;

  LatLng _userLocation = const LatLng(10.298333, 123.893366);
  StreamSubscription<Position>? _positionStreamSubscription;
  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _subscribeUserLocationUpdates();
    getPolylinesFromFirestore().then((polylines) {
      setState(() {
        _polylines = polylines.toSet();
      });
    });
  }

  void _toggleroutesvisibility() {
    setState(() {
      _isrouteshown = !_isrouteshown;
    });
  }

  Future<List<Polyline>> getPolylinesFromFirestore() async {
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
      List<LatLng> latLngPoints = geoPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      debugPrint('Polyline fetch for $routeNumber: $latLngPoints');

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
          width: 5,
          onTap: () {});

      polylines.add(polyline);
      polylineIdCounter++;
    }

    return polylines;
  }

  Future<void> _requestLocationPermission() async {
    await Permission.location.request();
  }

  void _subscribeUserLocationUpdates() async {
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

    _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    )).listen((Position position) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _userLocation, zoom: 17)));
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel(); // Add this line
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
            return Container();
          }
          return MaterialApp(
            home: Scaffold(
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  //MENU
                  children: <Widget>[
                    const DrawerHeader(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'asset/drawerheadernobackground.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: null),
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
                            // Add your action here
                          },
                        ),
                      ),
                    ),
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
              body: Builder(builder: (context) {
                return Stack(
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
                        zoom: 17,
                      ),
                      zoomControlsEnabled: false, // Remove zoom controls
                      myLocationButtonEnabled: false, // Remove location button
                      mapToolbarEnabled: false,
                      polylines: _isrouteshown ? _polylines : {},
                    ),
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
                            onPressed: () => _controller.animateCamera(
                                CameraUpdate.newCameraPosition(CameraPosition(
                                    target: _userLocation, zoom: 17))),
                            child: const Icon(Icons.location_searching),
                          ),
                        )),
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
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                        )),
                    Positioned(
                      top: 50,
                      left: 16,
                      right: 16,
                      child: SearchMapPlaceWidget(
                        apiKey: 'AIzaSyBOS4cS8wIYV2tRBhtf5O2hnIZ1Iley9Jc',
                        language: 'en',
                        bgColor: Colors.white,
                        location: _userLocation,
                        radius: 14697,
                        strictBounds: true,
                        iconColor: Colors.black,
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
                  ],
                );
              }),
            ),
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
