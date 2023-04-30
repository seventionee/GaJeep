import 'package:flutter/material.dart';
import '../component/constants.dart';

class VehicleInfoWidget extends StatefulWidget {
  final String jeepRoute;
  final String capacityStatus;

  const VehicleInfoWidget(
      {super.key, required this.jeepRoute, required this.capacityStatus});

  @override
  VehicleInfoWidgetState createState() => VehicleInfoWidgetState();
}

class VehicleInfoWidgetState extends State<VehicleInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -115), // Adjust vertical position by -50 pixels
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: AlertDialog(
          titlePadding: const EdgeInsets.all(8.0),
          contentPadding: const EdgeInsets.all(8.0),
          title: Center(
            child: Text('Jeep Route: ${widget.jeepRoute}',
                style: const TextStyle(
                  fontFamily: 'Epilogue', //font style
                  fontWeight: FontWeight.w400,
                  fontSize: 16.0,
                  color: Colors.black,
                )),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Text('Capacity Status: ${widget.capacityStatus}',
                      style: const TextStyle(
                        fontFamily: 'Epilogue', //font style
                        fontWeight: FontWeight.w400,
                        fontSize: 16.0,
                        color: Colors.black,
                      )),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
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
                  'View Route',
                  style: TextStyle(
                    fontFamily: 'Epilogue', //font style
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
