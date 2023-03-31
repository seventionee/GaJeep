import 'package:flutter/material.dart';
import 'learnmore.dart';
import 'mapsinterface.dart';

void main() {
  runApp(const MyApp());
}

// STATELESS WIDGET
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

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
        home: const MyHomePage(title: 'GaJeep Color Scheme'),
        routes: {
          LearnMorePage.routeName: (context) => const LearnMorePage(),
          Mapsinterface.routeName: (context) => Mapsinterface(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //welcome page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset(
          'asset/logo/gajeep_logo1.png',
          fit: BoxFit.cover,
          width: 300,
          height: 300,
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
