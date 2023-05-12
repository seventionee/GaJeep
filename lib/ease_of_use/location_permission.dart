import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> showLocationPermissionDialog(
    BuildContext context, Function onOkPressed) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Location Permission'),
      content: const Text('You have denied location permission. '
          'Please enable location permission in settings to use this feature.'),
      actions: [
        TextButton(
          onPressed: () async {
            SystemNavigator.pop();
            await openAppSettings();
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
