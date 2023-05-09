import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:flutter_app_1/providers/connectivity.dart';
import 'learnmore.dart';
import 'mapsinterface.dart';
import '../providers/request_location_permission.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../component/constants.dart';
import '../providers/splashscreenwithcallback.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  createState() => _SplashScreenState();
}

//SPLASH SCREEN
class _SplashScreenState extends State<SplashScreen> {
  final Connectivity _connectivity = Connectivity();
  @override
  void initState() {
    super.initState();
    checkConnectivity(); //check user connectivity to internet
    requestLocationPermission(); //initially ask for user permission to show location
    // Simulate a delay before navigating to the home screen
  }

  //initially ask for user permission to show location

  //check user connectivity to internet
  Future<void> checkConnectivity() async {
    ConnectivityResult connectivityResult =
        await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // User is not connected to the internet, show error message
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontFamily: 'Epilogue', //font style
                  fontWeight: FontWeight.w400,
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
              content: const Text(
                'Please check your internet connection and try again.',
                style: TextStyle(
                  fontFamily: 'Epilogue', //font style
                  fontWeight: FontWeight.w400,
                  fontSize: 15.0,
                  color: Colors.black,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      SystemNavigator.pop(), //exit the app after user taps OK
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
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontFamily: 'Epilogue', //font style
                      fontWeight: FontWeight.w400,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } else {
      //If User is connected to the internet, proceed with splash screen
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  const MyHomePage(title: 'GaJeep Color Scheme')),
        );
      });
    }
  }

  //SPLASHSCREEN design
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'asset/logo/gajeep_logo1.png',
              fit: BoxFit.cover,
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//adding splashscreen to tapped routes

//homepage design

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    timeDilation = 1.5;
    return showPromptScreen(
      context,
      Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            'asset/logo/gajeep_logo1.png',
            fit: BoxFit.cover,
            width: 250,
            height: 250,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black, // set the border color
                width: 1.0, // set the border width
              ),
              borderRadius:
                  BorderRadius.circular(25.0), // set the border radius
            ),
            child: ElevatedButton(
              onPressed: () {
                // Show the splash screen before navigating
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => SplashScreenWithCallback(
                    onComplete: () {
                      Navigator.pop(context); // Close the splash screen dialog
                      Navigator.pushNamed(
                        context,
                        Mapsinterface.routeName,
                        arguments: const LatLng(10.3156173, 123.882969),
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 50),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(25.0), // set the corner radius
                ), // increase the minimum width and height
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontWeight: FontWeight.w400,
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30.0),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black, // set the border color
                width: 1.0, // set the border width
              ),
              borderRadius:
                  BorderRadius.circular(25.0), // set the border radius
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  LearnMorePage.routeName,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 50),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(25.0), // set the corner radius
                ), // increase the minimum width and height
              ),
              child: const Text(
                'Learn More',
                style: TextStyle(
                  fontFamily: 'Epilogue', //font style
                  fontWeight: FontWeight.w400,
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ])),
      ),
    );
  }
}
