import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/polylinesdrawer.dart';

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
        title: const Text('Routes Directory'),
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

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (BuildContext ctx, int index) {
              String routeNumber = snapshot.data![index]['Route Number'];
              String routeDescription =
                  snapshot.data![index]['Route Description'];

              return Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Route Number: $routeNumber'),
                      Text('Route Description: $routeDescription'),
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
                              'Active Vehicles: ${activeVehiclesSnapshot.data}');
                        },
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
