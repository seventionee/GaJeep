import 'package:flutter/material.dart';
import 'package:flutter_app_1/mapsinterface.dart';
import 'package:google_maps_webservice/places.dart';

import 'component/location_list_tile.dart';
import 'component/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Searchscreen extends StatefulWidget {
  static const routeName = '/searchscreen';
  const Searchscreen({Key? key}) : super(key: key);

  @override
  createState() => _SearchscreenState();
}

class _SearchscreenState extends State<Searchscreen> {
  final _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyBOS4cS8wIYV2tRBhtf5O2hnIZ1Iley9Jc');
  List<PlacesSearchResult> _searchResults = [];

  Future<void> _searchPlaces(String query) async {
    final response = await _places.searchByText(query);
    setState(() {
      _searchResults = response.results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const Padding(
            padding: EdgeInsets.only(left: defaultPadding),
            child: CircleAvatar(
              backgroundColor: primaryColor,
              child: Icon(Icons.place, color: Colors.black),
            ),
          ),
          title: const Text(
            "Search Place",
            style: TextStyle(
              fontFamily: 'Epilogue', //font style
              fontWeight: FontWeight.w400,
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
        ),
        body: Column(
          children: [
            Form(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: TextFormField(
                  style: const TextStyle(
                    fontFamily: 'Epilogue', //font style
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                  cursorColor: Colors.black,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _searchPlaces(value);
                    } else {
                      setState(() {
                        _searchResults = [];
                      });
                    }
                  },
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: "Where do you want to go?",
                    hintStyle: TextStyle(
                      fontFamily: 'Epilogue', //font style
                      fontWeight: FontWeight.w400,
                      fontSize: 15.0,
                      color: Colors.grey,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Icon(Icons.search_rounded, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
            const Divider(
              height: 4,
              thickness: 4,
              color: secondaryColor5LightTheme,
            ),
            const Divider(
              height: 4,
              thickness: 4,
              color: secondaryColor5LightTheme,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (BuildContext context, int index) {
                  final place = _searchResults[index];
                  return LocationListTile(
                    press: () async {
                      // Call the Geocoding API with the place's name to get its geolocation
                      final geocodingResponse =
                          await _places.getDetailsByPlaceId(place.placeId);
                      double latitude =
                          geocodingResponse.result.geometry!.location.lat;
                      double longitude =
                          geocodingResponse.result.geometry!.location.lng;
                      LatLng placelocation = LatLng(latitude, longitude);
                      // Pass the geolocation data back to the previous screen
                      debugPrint('LatLng: $placelocation');
                      setState(() {
                        Navigator.of(context).pushNamed(Mapsinterface.routeName,
                            arguments: {placelocation});
                      });
                    },
                    location: place.name,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
