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
    return AlertDialog(
      title: Text('Jeep Route: ${widget.jeepRoute}',
          style: const TextStyle(
            fontFamily: 'Epilogue', //font style
            fontWeight: FontWeight.w400,
            fontSize: 20.0,
            color: Colors.black,
          )),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Capacity Status: ${widget.capacityStatus}',
                style: const TextStyle(
                  fontFamily: 'Epilogue', //font style
                  fontWeight: FontWeight.w400,
                  fontSize: 20.0,
                  color: Colors.black,
                )),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close',
              style: TextStyle(
                fontFamily: 'Epilogue', //font style
                fontWeight: FontWeight.w400,
                fontSize: 20.0,
                color: Colors.black,
              )),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
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
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
