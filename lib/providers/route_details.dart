import 'package:flutter/material.dart';
import '../component/constants.dart';
import '../providers/polylinesdrawer.dart';

class RouteDetailsModal extends StatefulWidget {
  final String routeName;
  final String routeDescription;

  const RouteDetailsModal(
      {Key? key, required this.routeName, required this.routeDescription})
      : super(key: key);

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
            StreamBuilder<int>(
              stream: getActiveVehiclesForRoute(widget.routeName),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text('Available jeeps: ',
                        style: TextStyle(
                          fontFamily: 'Epilogue', //font style
                          fontWeight: FontWeight.w400,
                          fontSize: 20.0,
                          color: Colors.black,
                        )),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    else if (snapshot.hasError)
                      Text('Error: ${snapshot.error}')
                    else
                      Text('${snapshot.data}',
                          style: const TextStyle(
                            fontFamily: 'Epilogue', //font style
                            fontWeight: FontWeight.w400,
                            fontSize: 20.0,
                            color: Colors.black,
                          )),
                  ],
                );
              },
            ),
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
