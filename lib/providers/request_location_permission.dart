import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationPermission() async {
  await Permission.location.request();
}
