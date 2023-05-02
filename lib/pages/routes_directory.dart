import '../providers/polylinesdrawer.dart';
import '../component/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dynamic_pages/route_details_screen.dart';

class RoutesDirectory extends StatelessWidget {
  const RoutesDirectory({Key? key}) : super(key: key);
  static const routeName = '/routesdirectory';

  Future<List<QueryDocumentSnapshot>> fetchRoutes() async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('Routes');
    QuerySnapshot querySnapshot = await collection.get();
    return querySnapshot.docs;
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
        title: const Text(
          'Routes Directory',
          style: TextStyle(
            fontFamily: 'Epilogue', //font style
            fontWeight: FontWeight.w400,
            fontSize: 20.0,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: fetchRoutes(),
        builder: (BuildContext context,
            AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext ctx, int index) {
              String routeNumber = snapshot.data![index]['Route Number'];
              String routeDescription =
                  snapshot.data![index]['Route Description'];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      width: 1.0,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                    color: primaryColor,
                  ),
                  child: Column(
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Route Description: $routeDescription',
                              style: const TextStyle(
                                fontFamily: 'Epilogue', //font style
                                fontWeight: FontWeight.w400,
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            StreamBuilder<int>(
                              stream: getActiveVehiclesForRoute(routeNumber),
                              builder: (BuildContext context,
                                  AsyncSnapshot<int> activeVehiclesSnapshot) {
                                if (activeVehiclesSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (activeVehiclesSnapshot.hasError) {
                                  return Text(
                                      'Error: ${activeVehiclesSnapshot.error}');
                                }
                                return Text(
                                  'Active Vehicles: ${activeVehiclesSnapshot.data}',
                                  style: const TextStyle(
                                    fontFamily: 'Epilogue', //font style
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20.0,
                                    color: Colors.black,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RouteDetails(
                                  routeNumber: routeNumber,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                secondaryColor),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                          ),
                          child: const Text(
                            'View Route',
                            style: TextStyle(
                              fontFamily: 'Epilogue', //font style
                              fontWeight: FontWeight.w400,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
