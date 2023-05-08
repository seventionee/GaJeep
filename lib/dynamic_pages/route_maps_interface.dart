import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_1/dynamic_pages/route_details_screen.dart';
import 'package:flutter_app_1/pages/fare_calculator_directory.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../providers/request_location_permission.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';
import '../component/constants.dart';
import '../pages/learnmore.dart';
import '../providers/route_polylines.dart';
import '../providers/jeeps_location.dart';
import 'package:provider/provider.dart';
import '../providers/jeep_info.dart';
import '../pages/routes_directory.dart';
import '../pages/mapsinterface.dart';
import '../dynamic_pages/fare_calculator_map.dart';

class RouteMapInterface extends StatefulWidget {
  static const routeName = '/routemapinterface';
  final LatLng initialPosition;
  final String selectedRoute;
  const RouteMapInterface(
      {super.key, required this.selectedRoute, required this.initialPosition});
  @override
  createState() => _RouteMapInterface();
}

class _RouteMapInterface extends State<RouteMapInterface> {
  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer(); //for controlling google map interface
  Set<Polyline> mappolylines = {}; //for polylines
  final bool _isrouteshown = true; //for toggling polylines appearance
  bool _firstLoad = true;
  bool _useRoutePoints1 = false;
  String _currentDirectionDescription = '';
  String _currentDirectionOrientation = '';
  late LatLng userLocation = const LatLng(10.298333, 123.893366);
  late LatLng initialPosition;
  List<LatLng> polylinePoints = [];
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
            _showUserLocation ? userLocation : widget.initialPosition;
        await controller.moveCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 17),
        ));

        // Animate the camera from the user's location to the initial position if necessary.
        if (_showUserLocation) {
          await controller.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  min(userLocation.latitude, widget.initialPosition.latitude),
                  min(userLocation.longitude, widget.initialPosition.longitude),
                ),
                northeast: LatLng(
                  max(userLocation.latitude, widget.initialPosition.latitude),
                  max(userLocation.longitude, widget.initialPosition.longitude),
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
    initialPosition = widget.initialPosition;

    getPolylineForSpecificRoute(
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

  @override
  void dispose() {
    positionStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: ChangeNotifierProvider<VehicleLocationProvider>(
        create: (_) =>
            VehicleLocationProvider(routeFilter: widget.selectedRoute),
        child: FutureBuilder(
          future: getJsonFile('asset/mapstyle.json'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Column(
                  children: [
                    Text(
                      '${widget.selectedRoute} - Route Map',
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
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  //MENU
                  children: <Widget>[
                    //MENU HEADER
                    const DrawerHeader(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'asset/drawerheadernobackground.png'),
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
                          leading: const Icon(Icons.map_outlined,
                              color: Colors.black),
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              Mapsinterface.routeName,
                              arguments: widget.initialPosition,
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
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(FareCalculatorDirectory.routeName);
                          },
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
                              rotateGesturesEnabled: false,
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
                                  const MinMaxZoomPreference(15, 30),
                              mapType: MapType.normal,
                              myLocationEnabled: true,
                              initialCameraPosition: CameraPosition(
                                target: widget.initialPosition,
                                zoom: 15,
                              ),
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                              mapToolbarEnabled: false,
                              polylines: _isrouteshown ? mappolylines : {},
                              markers: vehicleLocationProvider
                                  .vehicleMarkers.values
                                  .toSet(),
                            ),
                            if (vehicleLocationProvider.selectedMarkerId !=
                                null)
                              if (vehicleLocationProvider.selectedMarkerId !=
                                      null &&
                                  !vehicleLocationProvider.isUpdatingWidget)
                                Align(
                                  alignment: Alignment.center,
                                  child: Visibility(
                                    visible: vehicleLocationProvider
                                                .selectedMarkerId !=
                                            null &&
                                        !vehicleLocationProvider
                                            .isUpdatingWidget,
                                    child: VehicleInfoWidget(
                                      jeepRoute: vehicleLocationProvider
                                              .selectedJeepRoute ??
                                          '',
                                      capacityStatus: vehicleLocationProvider
                                              .selectedCapacityStatus ??
                                          '',
                                      plateNumber: vehicleLocationProvider
                                              .selectedPlateNumber ??
                                          '',
                                      picture: vehicleLocationProvider
                                              .selectedPicture ??
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
                              foregroundColor:
                                  const Color.fromARGB(255, 0, 0, 0),
                              backgroundColor: secondaryColor,
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

                                List<Polyline> newPolylines =
                                    // ignore: use_build_context_synchronously
                                    await getPolylineForSpecificRoute(context,
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

                    //Fare calculator button
                    Positioned(
                        bottom: 90,
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FareCalculatorMapInterface(
                                    initialcalculatorposition:
                                        widget.initialPosition,
                                    selectedRoute: widget.selectedRoute,
                                  ),
                                ),
                              );
                            },
                            child: const Icon(Icons.calculate_rounded,
                                color: Colors.black),
                          ),
                        )),

                    //SEARCH MAP WIDGET
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
                  ],
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'What do you want to do?',
            style: TextStyle(
              fontFamily: 'Epilogue', //font style
              fontWeight: FontWeight.w400,
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RouteDetails(
                      routeNumber: widget.selectedRoute,
                    ),
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(primaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                child: Text(
                  'View ${widget.selectedRoute} Route Details',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Epilogue', //font style
                    fontWeight: FontWeight.w400,
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    Mapsinterface.routeName,
                    arguments: widget.initialPosition,
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(secondaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                child: const Text(
                  'View All Routes on Map',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Epilogue', //font style
                    fontWeight: FontWeight.w400,
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    return false;
  }
}
