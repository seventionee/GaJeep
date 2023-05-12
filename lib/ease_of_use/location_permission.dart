import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_1/component/constants.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> showLocationPermissionDialog(
    BuildContext context, Function onOkPressed) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text(
        'Location Permission Required',
        style: TextStyle(
          fontFamily: 'Epilogue', //font style
          fontWeight: FontWeight.w400,
          fontSize: 20.0,
          color: Colors.black,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Please enable location permission in settings to use this feature.\n\n'
              '1. Open app settings, then select permissions.',
              style: TextStyle(
                fontFamily: 'Epilogue', //font style
                fontWeight: FontWeight.w400,
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15), // add some space
            Image.asset(
                'asset/userpermissionimages/LocationPermission1.jpg'), // replace with your image path
            const SizedBox(height: 15), // add some space
            const Text(
              '2. Select location',
              style: TextStyle(
                fontFamily: 'Epilogue', //font style
                fontWeight: FontWeight.w400,
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15), // add some space
            Image.asset(
                'asset/userpermissionimages/LocationPermission2.jpg'), // replace with your image path
            const SizedBox(height: 15), // add some space
            const Text(
              '3. Select "Allow only while using the app"',
              style: TextStyle(
                fontFamily: 'Epilogue', //font style
                fontWeight: FontWeight.w400,
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15), // add some space
            Image.asset(
                'asset/userpermissionimages/LocationPermission3.jpg'), // replace with your image path
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            SystemNavigator.pop();
            await openAppSettings();
          },
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
            'Open App Settings',
            style: TextStyle(
              fontFamily: 'Epilogue', //font style
              fontWeight: FontWeight.w400,
              fontSize: 17.0,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}
