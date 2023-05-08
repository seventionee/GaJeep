import 'package:flutter/material.dart';
import '../component/constants.dart';
import '../dynamic_pages/route_details_screen.dart';

class VehicleInfoWidget extends StatefulWidget {
  final String jeepRoute;
  final String capacityStatus;
  final String plateNumber;
  final String picture;

  const VehicleInfoWidget(
      {Key? key,
      required this.jeepRoute,
      required this.capacityStatus,
      required this.plateNumber,
      required this.picture})
      : super(key: key);

  @override
  VehicleInfoWidgetState createState() => VehicleInfoWidgetState();
}

class VehicleInfoWidgetState extends State<VehicleInfoWidget> {
  late ValueNotifier<bool> _imageLoaded;

  @override
  void initState() {
    super.initState();
    _imageLoaded = ValueNotifier<bool>(false);
  }

  void showFullScreenImage(BuildContext context, String imageUrl) {
    if (_imageLoaded.value) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      child: Image.network(imageUrl),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(secondaryColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Close Image',
                        style: TextStyle(
                          fontFamily: 'Epilogue', //font style
                          fontWeight: FontWeight.w400,
                          fontSize: 22.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -150),
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: AlertDialog(
          titlePadding: const EdgeInsets.all(8.0),
          contentPadding: const EdgeInsets.all(4),
          title: Center(
            child: Text('Route: ${widget.jeepRoute}',
                style: const TextStyle(
                  fontFamily: 'Epilogue',
                  fontWeight: FontWeight.w400,
                  fontSize: 16.0,
                  color: Colors.black,
                )),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Column(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _imageLoaded,
                        builder: (context, value, child) {
                          return IgnorePointer(
                            ignoring: !value,
                            child: GestureDetector(
                              onTap: () {
                                showFullScreenImage(context, widget.picture);
                              },
                              child: AbsorbPointer(
                                absorbing: !_imageLoaded.value,
                                child: Container(
                                  width: 150,
                                  height: 95,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      widget.picture,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            _imageLoaded.value = true;
                                          });
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 5),
                      Text('Plate Number ${widget.plateNumber}',
                          style: const TextStyle(
                            fontFamily: 'Epilogue',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Colors.black,
                          )),
                      Text('Capacity Status: ${widget.capacityStatus}',
                          style: const TextStyle(
                            fontFamily: 'Epilogue',
                            fontWeight: FontWeight.w400,
                            fontSize: 15.0,
                            color: Colors.black,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteDetails(
                        routeNumber: widget.jeepRoute,
                      ),
                    ),
                  );
                },
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
                  'Route Details',
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
