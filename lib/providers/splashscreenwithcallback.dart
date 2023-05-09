import 'package:flutter/material.dart';

import '../component/constants.dart';

class SplashScreenWithCallback extends StatefulWidget {
  const SplashScreenWithCallback({Key? key, required this.onComplete})
      : super(key: key);

  final Function onComplete;

  @override
  createState() => _SplashScreenWithCallbackState();
}

class _SplashScreenWithCallbackState extends State<SplashScreenWithCallback> {
  @override
  void initState() {
    super.initState();

    // Call the onComplete callback after a delay
    Future.delayed(const Duration(seconds: 2), () {
      widget.onComplete();
    });
  }

//splashscreen with callback design
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

class LoadingSplashScreen extends StatelessWidget {
  const LoadingSplashScreen({super.key});

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
