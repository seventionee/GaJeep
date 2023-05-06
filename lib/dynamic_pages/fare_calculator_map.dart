import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:search_map_place_updated/search_map_place_updated.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../providers/request_location_permission.dart';
import '../component/constants.dart';
import '../pages/learnmore.dart';
import '../providers/route_polylines.dart';
import '../providers/jeeps_location.dart';
import 'package:provider/provider.dart';
import '../pages/routes_directory.dart';
import '../pages/mapsinterface.dart';

class FareCalculatorMapInterface extends StatefulWidget {
  static const routeName = '/farecalculatormapinterface';
  final LatLng initialcalculatorposition;
  final String selectedRoute;
  const FareCalculatorMapInterface(
      {super.key,
      required this.selectedRoute,
      required this.initialcalculatorposition});
  @override
  createState() => _FareCalculatorMapInterface();
}

class _FareCalculatorMapInterface extends State<FareCalculatorMapInterface> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // for polyline calculation
  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer(); //for controlling google map interface
  //for polylines

  bool _useRoutePoints1 = false; //for toggling route orientation polylines
  Set<Polyline> mappolylines = {};
  List<LatLng> polylinePoints = [];
  final List<LatLng> _selectedPoints = [];
  final Set<Marker> _markers = {};

  final bool _isrouteshown = true; //for toggling polylines appearance
  bool _firstLoad = true;
  late LatLng userLocation = const LatLng(10.298333, 123.893366);
  late LatLng initialPosition;
  final bool _showUserLocation = false;
  StreamSubscription<Position>?
      positionStreamSubscription; //constantly check user position

  //for maps style
  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  //animating to user location
  Future<void> animateToUserLocation(GoogleMapController controller) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: initialPosition, zoom: 17),
      ));
    });
  }

  Future<void> animateToInitialPosition(GoogleMapController controller) async {
    if (_firstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Move the camera to the user's location or initial position.
        LatLng target =
            _showUserLocation ? userLocation : widget.initialcalculatorposition;
        await controller.moveCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 17),
        ));

        // Animate the camera from the user's location to the initial position if necessary.
        if (_showUserLocation) {
          await controller.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  min(userLocation.latitude,
                      widget.initialcalculatorposition.latitude),
                  min(userLocation.longitude,
                      widget.initialcalculatorposition.longitude),
                ),
                northeast: LatLng(
                  max(userLocation.latitude,
                      widget.initialcalculatorposition.latitude),
                  max(userLocation.longitude,
                      widget.initialcalculatorposition.longitude),
                ),
              ),
              100.0, // Add some padding around the locations.
            ),
          );
        }

        _firstLoad = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    subscribeUserLocationUpdates();
    initialPosition = widget.initialcalculatorposition;

    getPolylineforCalculator(
      context,
      selectedRoute: widget.selectedRoute,
      useRoutePoints1: _useRoutePoints1,
    ).then((polylines) {
      setState(() {
        mappolylines = polylines.toSet();
        if (polylines.isNotEmpty) {
          polylinePoints = polylines.first.points;
        }
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
      ),
    ).listen((Position position) async {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });

      final GoogleMapController controller =
          await _mapControllerCompleter.future;

      if (_firstLoad) {
        await animateToUserLocation(controller);
        _firstLoad = false;
      }
    });
  }

  void _handleTap(LatLng tappedPoint) async {
    LatLng closestPoint = _getClosestPoint(tappedPoint, polylinePoints);
    if (_selectedPoints.length < 2) {
      setState(() {
        _selectedPoints.add(closestPoint);
        _markers.add(
          Marker(
            markerId: MarkerId(_selectedPoints.length.toString()),
            position: closestPoint,
          ),
        );
      });
      if (_selectedPoints.length == 2) {
        double distance = _calculateDistanceAlongPolyline(
            polylinePoints, _selectedPoints[0], _selectedPoints[1]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Distance: ${distance.toStringAsFixed(2)} meters'),
            duration: const Duration(seconds: 3),
          ),
        );

        // Add a delay before clearing the markers
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            _selectedPoints.clear();
            _markers.clear();
          });
        });
      }
    }
  }

  LatLng _getClosestPoint(LatLng tappedPoint, List<LatLng> polylinePoints) {
    late LatLng closestPoint;
    double minDistance = double.infinity;
    for (LatLng point in polylinePoints) {
      double distance = Geolocator.distanceBetween(tappedPoint.latitude,
          tappedPoint.longitude, point.latitude, point.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
      }
    }
    return closestPoint;
  }

  double _calculateDistanceAlongPolyline(
      List<LatLng> polylinePoints, LatLng start, LatLng end) {
    double totalDistance = 0.0;
    int startIndex = -1;
    int endIndex = -1;

    for (int i = 0; i < polylinePoints.length - 1; i++) {
      LatLng point = polylinePoints[i];
      LatLng nextPoint = polylinePoints[i + 1];

      if (startIndex == -1 && (point == start || nextPoint == start)) {
        startIndex = i;
      }
      if (endIndex == -1 && (point == end || nextPoint == end)) {
        endIndex = i;
      }
      if (startIndex != -1 && endIndex != -1) {
        break;
      }
    }

    if (startIndex != -1 && endIndex != -1) {
      for (int i = startIndex; i <= endIndex; i++) {
        LatLng point = polylinePoints[i];
        LatLng nextPoint = polylinePoints[i + 1];
        totalDistance += Geolocator.distanceBetween(point.latitude,
            point.longitude, nextPoint.latitude, nextPoint.longitude);
      }
    }

    return totalDistance;
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getJsonFile('asset/mapstyle.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: primaryColor,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              '${widget.selectedRoute} - Fare Calculator',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Epilogue', //font style
                fontWeight: FontWeight.w400,
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              //MENU
              children: <Widget>[
                //MENU HEADER
                const DrawerHeader(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('asset/drawerheadernobackground.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: null),
                //View All Routes On Map
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
                        'View All Routes',
                        style: TextStyle(
                            fontFamily: 'Epilogue', //font style
                            fontWeight: FontWeight.w400,
                            fontSize: 20.0,
                            color: Colors.black),
                      ),
                      tileColor: backgroundColor,
                      leading:
                          const Icon(Icons.map_outlined, color: Colors.black),
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          Mapsinterface.routeName,
                          arguments: widget.initialcalculatorposition,
                        );
                      },
                    ),
                  ),
                ),
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
                      leading: const Icon(Icons.directions_transit_filled_sharp,
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
                GoogleMap(
                  onTap: _handleTap,
                  markers: _markers,
                  onCameraMove: (position) {
                    // Removed reference to vehicleLocationProvider
                  },
                  onMapCreated: (GoogleMapController controller) async {
                    _mapControllerCompleter.complete(controller);
                    updateMapController(context, controller);
                    controller.setMapStyle(snapshot.data!);
                  },
                  compassEnabled: false,
                  minMaxZoomPreference: const MinMaxZoomPreference(15, 30),
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: widget.initialcalculatorposition,
                    zoom: 15,
                  ),
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  polylines: mappolylines,
                ),
                Positioned(
                  top: 10,
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
                      borderRadius:
                          BorderRadius.circular(50.0), // set the border radius
                    ),
                    child: FloatingActionButton(
                      heroTag: null,
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      backgroundColor: secondaryColor,
                      onPressed: () async {
                        Position position = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high);
                        LatLng currentLocation =
                            LatLng(position.latitude, position.longitude);

                        // Update the userLocation variable
                        setState(() {
                          userLocation = currentLocation;
                        });

                        final GoogleMapController controller =
                            await _mapControllerCompleter.future;
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: userLocation, zoom: 15),
                          ),
                        );
                      },
                      child: const Icon(Icons.location_searching),
                    ),
                  ),
                ),
                //Toggle Route Orientation
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
                          onPressed: () async {
                            debugPrint('FAB IS TAPPED');
                            setState(() {
                              _useRoutePoints1 = !_useRoutePoints1;
                            });

                            List<Polyline> newPolylines =
                                await getPolylineforCalculator(context,
                                    selectedRoute: widget.selectedRoute,
                                    useRoutePoints1: _useRoutePoints1);
                            setState(() {
                              mappolylines = newPolylines.toSet();
                              if (newPolylines.isNotEmpty) {
                                polylinePoints = newPolylines.first.points;
                              }
                            });
                          },
                          child: const Icon(Icons.mode_of_travel)),
                    )),
              ],
            );
          }),
        );
      },
    );
  }
}
