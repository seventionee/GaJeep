import 'package:flutter/material.dart';
import 'pages/learnmore.dart';
import 'pages/mapsinterface.dart';
import 'pages/routes_directory.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/home.dart';
import 'package:provider/provider.dart';
import 'providers/jeeps_location.dart';
import 'dynamic_pages/route_details_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//STARTING THE FLUTTER APP
void main() async {
  //make sure to initialize firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBVnkaLr9-BnWw_JFJkELPlW6Rn8EaemFk',
      appId: '1:138811229758:android:7f59f6d22112ca29ae336f',
      messagingSenderId: '138811229758',
      projectId: 'gajeep-c5101',
      databaseURL:
          'https://gajeep-c5101-default-rtdb.asia-southeast1.firebasedatabase.app/',
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => VehicleLocationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

//SET AND DECLARE ROUTING DIRECTORIES
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //color palette
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFF8BB28), //main color - ignore first two Fs
          secondary: const Color(0xFFFA7F81), //secondary color
          tertiary: const Color(0xFF86246A), //tertiary color from jeep icon
        ),
      ),
      home: const SplashScreen(), // set SplashScreen as the initial screen
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case LearnMorePage.routeName:
            return MaterialPageRoute(
                builder: (context) => const LearnMorePage());
          case Mapsinterface.routeName:
            final LatLng initialPosition = settings.arguments as LatLng;
            return MaterialPageRoute(
                builder: (context) =>
                    Mapsinterface(initialPosition: initialPosition));
          case RoutesDirectory.routeName:
            return MaterialPageRoute(
                builder: (context) => const RoutesDirectory());
          case RouteDetails.routeName:
            final String routeNumber = settings.arguments as String;
            return MaterialPageRoute(
                builder: (context) => const RouteDetails(routeNumber: ''));
          default:
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
        }
      },
    );
  }
}
