import 'package:flutter/material.dart';
import 'package:flutter_app_1/providers/connectivity.dart';

class LearnMorePage extends StatelessWidget {
  static const routeName = '/learnmore';

  const LearnMorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return showPromptScreen(
      context,
      Scaffold(
          appBar: AppBar(
            title: const Text(
              'About GaJeep',
              style: TextStyle(
                fontFamily: 'Epilogue', //font style
                fontWeight: FontWeight.w400,
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                color: Colors.black),
            backgroundColor: const Color(0xFFF8BB28),
          ),
          body: SingleChildScrollView(
              child: Column(children: [
            SizedBox(
              height: 300,
              width: 300,
              child: Image.asset(
                'asset/logo/gajeep_logo1.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'What is GaJeep?',
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'GaJeep is a mobile application that allows commuters to track the location of jeepneys in real-time. It also helps commuters calculate their fare based on distance travelled and view jeepney route information. GaJeep aims to positively influence the public transportation commuting experience.',
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Features',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: const [
                          Icon(Icons.check_circle, color: Color(0xFFF8BB28)),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              'Real-time location tracking of available jeepneys',
                              style: TextStyle(
                                fontFamily: 'Epilogue',
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: const [
                          Icon(Icons.check_circle, color: Color(0xFFF8BB28)),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              'Real-time tracking of passenger capacity status of jeepneys',
                              style: TextStyle(
                                fontFamily: 'Epilogue',
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: const [
                          Icon(Icons.check_circle, color: Color(0xFFF8BB28)),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              'View Route infromations to familiarize with the routes',
                              style: TextStyle(
                                fontFamily: 'Epilogue',
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: const [
                          Icon(Icons.check_circle, color: Color(0xFFF8BB28)),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              'Accurately calculate fare based on current rates and actual distance travelled',
                              style: TextStyle(
                                fontFamily: 'Epilogue',
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]))
          ]))),
    );
  }
}
