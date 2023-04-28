import 'package:flutter/material.dart';
import '../component/constants.dart';

class RouteDetailsModal extends StatefulWidget {
  final String routeName;
  final String routeDescription;

  const RouteDetailsModal(
      {super.key, required this.routeName, required this.routeDescription});

  @override
  RouteDetailsModalState createState() => RouteDetailsModalState();
}

class RouteDetailsModalState extends State<RouteDetailsModal> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Route Number: ${widget.routeName}',
          style: const TextStyle(
            fontFamily: 'Epilogue', //font style
            fontWeight: FontWeight.w400,
            fontSize: 20.0,
            color: Colors.black,
          )),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(widget.routeDescription,
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
