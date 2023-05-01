import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/polylinesdrawer.dart';
import '../component/constants.dart';

class RouteDetails extends StatefulWidget {
  final String routeNumber;
  final String routeDescription;

  const RouteDetails(
      {super.key, required this.routeNumber, required this.routeDescription});

  @override
  createState() => _RouteDetailsState();
}

class _RouteDetailsState extends State<RouteDetails> {
  late Future<DocumentSnapshot> _routeDocFuture;

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
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          String routeNumber = snapshot.data!['Route Number'];

          return ListView(
            children: [
              ListTile(
                title: Text('Route Number: $routeNumber'),
                subtitle: Text('Route Description: ${widget.routeDescription}'),
              ),
              ListTile(
                title: const Text('Number of Active Vehicles'),
                subtitle: StreamBuilder<int>(
                  stream: getActiveVehiclesForRoute(widget.routeNumber),
                  builder: (BuildContext context,
                      AsyncSnapshot<int> activeVehiclesSnapshot) {
                    if (activeVehiclesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (activeVehiclesSnapshot.hasError) {
                      return Text('Error: ${activeVehiclesSnapshot.error}');
                    }
                    return Text('${activeVehiclesSnapshot.data}');
                  },
                ),
              ),
              const ListTile(
                title: Text('List of Active Vehicles'),
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: getActiveVehiclesListForRoute(widget.routeNumber),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>>
                        activeVehiclesListSnapshot) {
                  if (activeVehiclesListSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (activeVehiclesListSnapshot.hasError) {
                    return Text('Error: ${activeVehiclesListSnapshot.error}');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeVehiclesListSnapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> vehicle =
                          activeVehiclesListSnapshot.data![index];
                      String plateNumber = vehicle['plateNumber'];
                      String capacityStatus = vehicle['capacityStatus'];

                      return ListTile(
                        title: Text('Plate Number: $plateNumber'),
                        subtitle: Text('Capacity Status: $capacityStatus'),
                        onTap: () {
                          // Handle vehicle tap
                        },
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
