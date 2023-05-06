import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/route_polylines.dart';
import '../component/constants.dart';
import 'route_maps_interface.dart';

class RouteDetails extends StatefulWidget {
  final String routeNumber;
  static const routeName = '/routedetails';
  const RouteDetails({super.key, required this.routeNumber});

  @override
  createState() => _RouteDetailsState();
}

class _RouteDetailsState extends State<RouteDetails> {
  late Future<DocumentSnapshot> _routeDocFuture;
  late LatLng centralPoint;
  @override
  void initState() {
    super.initState();
    _routeDocFuture = fetchRouteDoc(widget.routeNumber);
  }

  Future<DocumentSnapshot> fetchRouteDoc(String routeNumber) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('Routes');
    return await collection.doc(routeNumber).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.black),
        title: Text(
          '${widget.routeNumber} - Route Details',
          style: const TextStyle(
            fontFamily: 'Epilogue', //font style
            fontWeight: FontWeight.w400,
            fontSize: 20.0,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _routeDocFuture,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            ));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          GeoPoint centralGeoPoint = snapshot.data!['Central Point'];
          LatLng routecentralPoint =
              LatLng(centralGeoPoint.latitude, centralGeoPoint.longitude);
          centralPoint = routecentralPoint;
          String routeNumber = snapshot.data!['Route Number'];
          String routeDescription = snapshot.data!['Route Description'];

          return ListView(
            children: [
              ListTile(
                title: Text(
                  'Route Number: $routeNumber',
                  style: const TextStyle(
                    fontFamily: 'Epilogue', //font style
                    fontWeight: FontWeight.w400,
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  'Route Description: $routeDescription',
                  style: const TextStyle(
                    fontFamily: 'Epilogue', //font style
                    fontWeight: FontWeight.w400,
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
              ),
              ListTile(
                title: const Text(
                  'Number of Active Vehicles',
                  style: TextStyle(
                    fontFamily: 'Epilogue', //font style
                    fontWeight: FontWeight.w400,
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                subtitle: StreamBuilder<int>(
                  stream: getActiveVehiclesForRoute(widget.routeNumber),
                  builder: (BuildContext context,
                      AsyncSnapshot<int> activeVehiclesSnapshot) {
                    if (activeVehiclesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Colors.white,
                      );
                    }
                    if (activeVehiclesSnapshot.hasError) {
                      return Text('Error: ${activeVehiclesSnapshot.error}');
                    }
                    return Text(
                      '${activeVehiclesSnapshot.data}',
                      style: const TextStyle(
                        fontFamily: 'Epilogue', //font style
                        fontWeight: FontWeight.w400,
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RouteMapInterface(
                          initialPosition: centralPoint,
                          selectedRoute: routeNumber,
                        ),
                      ),
                    );
                  },
                  child: const Text('View Route On Map'),
                ),
              ),
              const ListTile(
                title: Text(
                  'List of Active Vehicles',
                  style: TextStyle(
                    fontFamily: 'Epilogue', //font style
                    fontWeight: FontWeight.w400,
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: getActiveVehiclesListForRoute(widget.routeNumber),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>>
                        activeVehiclesListSnapshot) {
                  if (activeVehiclesListSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      color: Colors.white,
                    );
                  }
                  if (activeVehiclesListSnapshot.hasError) {
                    return Text('Error: ${activeVehiclesListSnapshot.error}');
                  }
                  return activeVehiclesListSnapshot.data!.isEmpty
                      ? const Center(
                          child: Text(
                            'There are currently no active jeepneys for this route.',
                            style: TextStyle(
                              fontFamily: 'Epilogue', //font style
                              fontWeight: FontWeight.w400,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activeVehiclesListSnapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            Map<String, dynamic> vehicle =
                                activeVehiclesListSnapshot.data![index];
                            String plateNumber = vehicle['plateNumber'];
                            String capacityStatus = vehicle['capacityStatus'];
                            GeoPoint vehicleLocationGeoPoint =
                                vehicle['Location'];
                            LatLng vehicleLocation = LatLng(
                                vehicleLocationGeoPoint.latitude,
                                vehicleLocationGeoPoint.longitude);

                            return ListTile(
                              title: Text(
                                'Plate Number: $plateNumber',
                                style: const TextStyle(
                                  fontFamily: 'Epilogue', //font style
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                'Capacity Status: $capacityStatus',
                                style: const TextStyle(
                                  fontFamily: 'Epilogue', //font style
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RouteMapInterface(
                                        initialPosition: vehicleLocation,
                                        selectedRoute: routeNumber,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('View Jeep On Map'),
                              ),
                            );
                          },
                        );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
