import 'package:flutter/material.dart';

import 'component/location_list_tile.dart';
import 'component/constants.dart';

class Searchscreen extends StatefulWidget {
  static const routeName = '/searchscreen';
  const Searchscreen({Key? key}) : super(key: key);

  @override
  createState() => _SearchscreenState();
}

class _SearchscreenState extends State<Searchscreen> {
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
                color: Colors.black),
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
                  onChanged: (value) {},
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
            LocationListTile(
              press: () {},
              location: "Banasree, Dhaka, Bangladesh",
            ),
          ],
        ),
      ),
    );
  }
}
