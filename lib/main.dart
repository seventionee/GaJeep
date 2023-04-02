import 'package:flutter/material.dart';
import 'learnmore.dart';
import 'mapsinterface.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

//STARTING THE FLUTTER APP
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Landing Page',
      theme: ThemeData(
        //color palette
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFF8BB28), //main color - ignore first two Fs
          secondary: const Color(0xFFFA7F81), //secondary color
          tertiary: const Color(0xFF86246A), //tertiary color from jeep icon
        ),
      ),
      home: const SplashScreen(), // set SplashScreen as the initial screen
      routes: {
        LearnMorePage.routeName: (context) => const LearnMorePage(),
        Mapsinterface.routeName: (context) => const Mapsinterface(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  createState() => _SplashScreenState();
}

//SPLASHSCREEN CLASS
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a delay before navigating to the home screen
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                const MyHomePage(title: 'GaJeep Color Scheme')),
      );
    });
  }

  //SPLASHSCREEN

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Hero(
        tag: const Text('welcomelogo'),
        child: Image.asset(
          'asset/logo/gajeep_logo1.png',
          fit: BoxFit.cover,
          width: 250,
          height: 250,
        ),
      ),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    timeDilation = 1.5;
    return Scaffold(
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Hero(
          tag: const Text('welcomelogo'),
          child: Image.asset(
            'asset/logo/gajeep_logo1.png',
            fit: BoxFit.cover,
            width: 250,
            height: 250,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black, // set the border color
              width: 1.0, // set the border width
            ),
            borderRadius: BorderRadius.circular(25.0), // set the border radius
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                Mapsinterface.routeName,
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
                fontFamily: 'Epilogue', // set the font family to "Raleway"
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
            borderRadius: BorderRadius.circular(25.0), // set the border radius
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
    );
  }
}
