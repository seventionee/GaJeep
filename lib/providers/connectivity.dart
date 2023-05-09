import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import '../component/constants.dart';

class ConnectivityNotifier extends InheritedWidget {
  final bool isConnected;

  const ConnectivityNotifier({
    Key? key,
    required this.isConnected,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(ConnectivityNotifier oldWidget) {
    return oldWidget.isConnected != isConnected;
  }

  static ConnectivityNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ConnectivityNotifier>()!;
  }
}

class ConnectivityPromptScreen extends StatefulWidget {
  final Widget child;

  const ConnectivityPromptScreen({super.key, required this.child});

  @override
  createState() => _ConnectivityPromptScreenState();
}

class _ConnectivityPromptScreenState extends State<ConnectivityPromptScreen> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          _isConnected = false;
        });
      } else {
        setState(() {
          _isConnected = true;
        });
      }
    });
  }

  void _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityNotifier(isConnected: _isConnected, child: widget.child);
  }
}

Widget showPromptScreen(BuildContext context, Widget child) {
  final bool isConnected = ConnectivityNotifier.of(context).isConnected;

  if (isConnected) {
    return child;
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
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
                onPressed: () => SystemNavigator.pop(),
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
    });

    return child;
  }
}
