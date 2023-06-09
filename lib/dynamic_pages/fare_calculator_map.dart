import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_1/ease_of_use/location_permission.dart';
import 'package:flutter_app_1/ease_of_use/tutorial_map_interface.dart';
import 'package:flutter_app_1/providers/connectivity.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../providers/request_location_permission.dart';
import '../component/constants.dart';
import '../providers/route_polylines.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Set<Marker> mapMarkers = {};
  bool _locationEnabled = false;
  List<LatLng> polylinePoints = [];
  final List<LatLng> _selectedPoints = [];
  final Set<Marker> _markers = {};
  String _currentDirectionDescription = '';
  String _currentDirectionOrientation = '';
  //for toggling polylines appearance
  bool _firstLoad = true;
  late LatLng userLocation = const LatLng(10.298333, 123.893366);
  late LatLng initialPosition;
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

  Future<void> _checkLocationPermission() async {
    PermissionStatus permissionStatus = await Permission.location.status;
    setState(() {
      _locationEnabled = permissionStatus == PermissionStatus.granted;
    });
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    subscribeUserLocationUpdates();
    initialPosition = widget.initialcalculatorposition;
    _checkLocationPermission();
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

    getDirectionMarkersforCalculator(
      context,
      selectedRoute: widget.selectedRoute,
      useRoutePoints1: _useRoutePoints1,
      handleTap: _handleTap,
    ).then((markers) {
      setState(() {
        mapMarkers = markers.toSet();
      });
    });

    getDirectionDescription(
      widget.selectedRoute,
      _useRoutePoints1,
    ).then((directionDescription) {
      setState(() {
        _currentDirectionDescription = directionDescription;
      });
    });

    getDirectionOrientation(
      widget.selectedRoute,
      _useRoutePoints1,
    ).then((directionOrientation) {
      setState(() {
        _currentDirectionOrientation = directionOrientation;
      });
    });
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

  Future<BitmapDescriptor> distanceMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'asset/icons/calculate_pin.png',
    );
  }

  void _handleTap(LatLng tappedPoint) async {
    LatLng closestPoint = _getClosestPoint(tappedPoint, polylinePoints);
    final distanceicon = await distanceMarker();
    if (_selectedPoints.length < 2) {
      setState(() {
        _selectedPoints.add(closestPoint);
        _markers.add(
          Marker(
            markerId: MarkerId(_selectedPoints.length.toString()),
            icon: distanceicon,
            position: closestPoint,
          ),
        );
      });
      if (_selectedPoints.length == 2) {
        double distance = _calculateDistanceAlongPolyline(
            polylinePoints, _selectedPoints[0], _selectedPoints[1]);

        //getting startpointadress
        String startPointAddress = await getAddressFromLatLng(
            _selectedPoints[0].latitude, _selectedPoints[0].longitude);
        debugPrint('Start point address: $startPointAddress');

        //getting endpoint address
        String endPointAddress = await getAddressFromLatLng(
            _selectedPoints[1].latitude, _selectedPoints[1].longitude);
        debugPrint('End point address: $endPointAddress');

        // Call the showDistanceDialog function
        // ignore: use_build_context_synchronously
        showDistanceDialog(
            context, distance, startPointAddress, endPointAddress);

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

  //fare calculator
  double calculateFare(double distance, {bool isDiscounted = false}) {
    double baseFare = 12.0;
    double perKilometerRate = 1.50;
    double firstFourKilometers = 4 * 1000; // meters
    double discountRate = 0.20;

    double fare = baseFare;

    if (distance > firstFourKilometers) {
      fare += (distance - firstFourKilometers) / 1000 * perKilometerRate;
    }

    if (isDiscounted) {
      fare = fare * (1 - discountRate);
    }

    return fare;
  }

// Function to show the distance in an AlertDialog
  void showDistanceDialog(BuildContext context, double distance,
      String startPointAddress, String endPointAddress) {
    double fare = calculateFare(distance);
    double discountedFare = calculateFare(distance, isDiscounted: true);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: distance == 0.0
              ? const Text(
                  'Calculation Error',
                  style: TextStyle(
                    fontFamily: 'Epilogue', //font style
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Fare Calculation',
                  style: TextStyle(
                    fontFamily: 'Epilogue', //font style
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
          content: distance == 0.0
              ? const Text(
                  'Please place the points in the opposite, correct order.')
              : Text(
                  'Distance: ${distance.toStringAsFixed(2)} meters\n\nStart point: $startPointAddress\nEnd point: $endPointAddress\n\nRegular Fare: Php ${fare.toStringAsFixed(2)}\nDiscounted Fare (20%): Php ${discountedFare.toStringAsFixed(2)}'),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  _selectedPoints.clear();
                  _markers.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Epilogue', //font style
                  fontWeight: FontWeight.w400,
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}';
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
    }
    return 'Address not found';
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

  //using Haversine formula
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
    return showPromptScreen(
      context,
      FutureBuilder(
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
              title: Column(
                children: [
                  Text(
                    '${widget.selectedRoute} - Fare Calculator',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Epilogue', //font style
                      fontWeight: FontWeight.w400,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _currentDirectionDescription,
                    style: const TextStyle(
                      fontFamily: 'Epilogue', //font style
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _currentDirectionOrientation,
                    style: const TextStyle(
                      fontFamily: 'Epilogue', //font style
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            //REST OF INTERFACE
            body: Builder(builder: (context) {
              return Stack(
                children: [
                  GoogleMap(
                    onTap: _handleTap,
                    markers: {...mapMarkers, ..._markers},
                    onCameraMove: (position) {
                      // Removed reference to vehicleLocationProvider
                    },
                    onMapCreated: (GoogleMapController controller) async {
                      _mapControllerCompleter.complete(controller);

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
                        borderRadius: BorderRadius.circular(
                            50.0), // set the border radius
                      ),
                      child: FloatingActionButton(
                        heroTag: null,
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        backgroundColor: secondaryColor,
                        onPressed: () async {
                          PermissionStatus permissionStatus =
                              await Permission.location.status;
                          if (permissionStatus == PermissionStatus.granted) {
                            Position position =
                                await Geolocator.getCurrentPosition(
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
                                CameraPosition(target: userLocation, zoom: 17),
                              ),
                            );
                          } else {
                            // Request location permission again
                            await Permission.location.request();
                            // Check the updated permission status
                            PermissionStatus updatedStatus =
                                await Permission.location.status;
                            if (updatedStatus == PermissionStatus.granted) {
                              // Permission granted, perform the desired action
                              // (e.g., pan to user location)
                              Position position =
                                  await Geolocator.getCurrentPosition(
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
                                  CameraPosition(
                                      target: userLocation, zoom: 17),
                                ),
                              );
                            } else {
                              // ignore: use_build_context_synchronously
                              showLocationPermissionDialog(context, () async {
                                // Open app settings/permissions
                              });
                            }
                          }
                        },
                        child: _locationEnabled
                            ? const Icon(Icons.location_searching)
                            : const Icon(Icons.location_disabled),
                      ),
                    ),
                  ),
//tutorial button
                  Positioned(
                      bottom: 90,
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
                            backgroundColor: primaryColor,
                            onPressed: () async {
                              Navigator.pushNamed(
                                  context, FareCalculatorTutorial.routeName);
                            },
                            child: const Icon(Icons.help)),
                      )),

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
                            backgroundColor: primaryColor,
                            onPressed: () async {
                              debugPrint('FAB IS TAPPED');
                              setState(() {
                                _useRoutePoints1 = !_useRoutePoints1;
                              });

                              _currentDirectionDescription =
                                  await getDirectionDescription(
                                      widget.selectedRoute, _useRoutePoints1);

                              _currentDirectionOrientation =
                                  await getDirectionOrientation(
                                      widget.selectedRoute, _useRoutePoints1);

                              //rebuilding polylines upon toggle
                              List<Polyline> newPolylines =
                                  // ignore: use_build_context_synchronously
                                  await getPolylineforCalculator(context,
                                      selectedRoute: widget.selectedRoute,
                                      useRoutePoints1: _useRoutePoints1);
                              setState(() {
                                mappolylines = newPolylines.toSet();
                                if (newPolylines.isNotEmpty) {
                                  polylinePoints = newPolylines.first.points;
                                }
                              });

                              List<Marker> newMarker =
                                  // ignore: use_build_context_synchronously
                                  await getDirectionMarkersforCalculator(
                                      context,
                                      selectedRoute: widget.selectedRoute,
                                      useRoutePoints1: _useRoutePoints1,
                                      handleTap: _handleTap);
                              setState(() {
                                mapMarkers = newMarker.toSet();
                              });
                            },
                            child: const Icon(Icons.mode_of_travel)),
                      )),
                ],
              );
            }),
          );
        },
      ),
    );
  }
}
