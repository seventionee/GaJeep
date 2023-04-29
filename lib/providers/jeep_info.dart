import 'package:flutter/material.dart';

class VehicleInfoWidget extends StatefulWidget {
  final String jeepRoute;
  final String capacityStatus;

  const VehicleInfoWidget(
      {required this.jeepRoute, required this.capacityStatus});

  @override
  _VehicleInfoWidgetState createState() => _VehicleInfoWidgetState();
}

class _VehicleInfoWidgetState extends State<VehicleInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jeep: ${widget.jeepRoute}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Capacity: ${widget.capacityStatus}'),
        ],
      ),
    );
  }
}
