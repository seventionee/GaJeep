import 'package:flutter/material.dart';
import 'package:flutter_app_1/component/constants.dart';
import 'package:intro_slider/intro_slider.dart';

class FareCalculatorTutorial extends StatefulWidget {
  const FareCalculatorTutorial({super.key});
  static const routeName = '/farecalculatortutorial';
  @override
  createState() => _FareCalculatorTutorial();
}

class _FareCalculatorTutorial extends State<FareCalculatorTutorial> {
  List<ContentConfig> listContentConfig = [];

  final introSliderKey = GlobalKey<IntroSliderState>();

  @override
  void initState() {
    super.initState();

    listContentConfig.add(
      const ContentConfig(
        title: "Pin Origin Point",
        styleTitle: TextStyle(
          fontFamily: 'Epilogue', //font style
          fontWeight: FontWeight.w400,
          fontSize: 30.0,
          color: Colors.black,
        ),
        description:
            "Tap the first point along the polyine. This point should represent where you rode the jeepney in that route.",
        styleDescription: TextStyle(
          fontFamily: 'Epilogue', //font style
          fontWeight: FontWeight.w400,
          fontSize: 20.0,
          color: Colors.black,
        ),
        pathImage: "asset/calculatortutorial/pin_start_point.jpg",
        widthImage: 180,
        heightImage: 400,
        backgroundColor: primaryColor,
      ),
    );
    listContentConfig.add(
      const ContentConfig(
        title: "Pin End Point",
        styleTitle: TextStyle(
          fontFamily: 'Epilogue', //font style
          fontWeight: FontWeight.w400,
          fontSize: 30.0,
          color: Colors.black,
        ),
        description:
            "After tapping the first point (origin), you may tap the second point which is your destination. Remember to place the points in correct order as indicated by the arrow between the two points.",
        styleDescription: TextStyle(
          fontFamily: 'Epilogue', //font style
          fontWeight: FontWeight.w400,
          fontSize: 20.0,
          color: Colors.black,
        ),
        pathImage: "asset/calculatortutorial/pin_end_point.jpg",
        widthImage: 180,
        heightImage: 400,
        backgroundColor: secondaryColor,
      ),
    );
    listContentConfig.add(
      const ContentConfig(
        title: "Toggle Route Direction",
        styleTitle: TextStyle(
          fontFamily: 'Epilogue', //font style
          fontWeight: FontWeight.w400,
          fontSize: 30.0,
          color: Colors.black,
        ),
        description:
            "The interface only shows one half of the route for accurate route calculation. Tap the toggle route button to show the route direction matching to the direction you're going. The arrows across the map and the appbar are indicators to check.",
        styleDescription: TextStyle(
          fontFamily: 'Epilogue', //font style
          fontWeight: FontWeight.w400,
          fontSize: 20.0,
          color: Colors.black,
        ),
        pathImage: "asset/calculatortutorial/toggle_route.jpg",
        backgroundColor: primaryColor,
      ),
    );
  }

  void onDonePress() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      key: introSliderKey,
      listContentConfig: listContentConfig,
      onDonePress: onDonePress,
      isShowNextBtn: false,
      renderSkipBtn: TextButton(
        onPressed: () async {
          onDonePress();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: const BorderSide(color: Colors.black),
            ),
          ),
        ),
        child: const Text(
          'Skip',
          style: TextStyle(
            fontFamily: 'Epilogue', //font style
            fontWeight: FontWeight.w400,
            fontSize: 20.0,
            color: Colors.black,
          ),
        ),
      ),
      renderDoneBtn: TextButton(
        onPressed: () async {
          onDonePress();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: const BorderSide(color: Colors.black),
            ),
          ),
        ),
        child: const Text(
          'Done',
          style: TextStyle(
            fontFamily: 'Epilogue', //font style
            fontWeight: FontWeight.w400,
            fontSize: 20.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
