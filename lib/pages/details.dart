import 'dart:ui';

import 'package:bengkelan/lib/db/handler.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int _loadState = 0;

  String _carName = "";
  String _carManufacturer = "";
  String _carPlate = "";
  String _carStatus = "";
  String _carDetails = "";

  @override
  Widget build(BuildContext context) {
    var arg = ModalRoute.of(context)!.settings.arguments as Map<String, int?>;
    int serviceId = arg["serviceId"]!;
    int userId = arg["userId"]!;

    if (_loadState == 0) {
      DatabaseHandler.get()
          .getOne(
            table: "service_status st,car car,user usr",
            fields: "st.id, car.name, car.plate_number, st.status, st.details",
            where: "st.id = $serviceId AND usr.id = $userId",
          )
          .then((entry) async {
            _carName = entry["name"];
            _carPlate = entry["plate_number"];
            _carStatus = entry["status"];
            _carDetails = entry["details"];
            int carId = 0;

            await DatabaseHandler.get()
                .getOne(
                  table: "service_status",
                  fields: "car_id",
                  where: {"id": serviceId, "user_id": userId},
                )
                .then((entry) {
                  carId = entry["car_id"];
                });

            await DatabaseHandler.get()
                .getOne(
                  table: "manufacturer mft,car car",
                  fields: "mft.name",
                  where: "car.id = $carId AND mft.id = car.manufacturer_id",
                )
                .then((entry) {
                  _carManufacturer = entry["name"];
                });

            setState(() {
              _loadState = 1;
            });
          });
    }

    return Scaffold(
      appBar: AppBar(title: Center(child: const Text("Details"))),
      body: <Widget>[
        CircularProgressIndicator(),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "$_carManufacturer $_carName ($_carPlate)",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      color: _getColorBasedOnStatus(_carStatus),
                      padding: EdgeInsetsGeometry.symmetric(
                        vertical: 8,
                        horizontal: 6,
                      ),
                      child: Text(
                        _getDisplayStatus(_carStatus),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 48),
                  child: const Text(
                    "Details",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 48),
                  child: TextFormField(
                    textAlign: TextAlign.justify,
                    readOnly: true,
                    initialValue: _carDetails,
                  ),
                ),
              ),
            ],
          ),
        ),
      ][_loadState],
    );
  }

  Color _getColorBasedOnStatus(String status) {
    switch (status) {
      case "Queued":
        return Colors.yellow;
      case "Working":
        return Colors.lightBlue;
      case "Finished":
        return Colors.lightGreen;
      default:
        return Colors.white;
    }
  }

  String _getDisplayStatus(String status) {
    switch (status) {
      case "Queued":
        return "Queued";
      case "Working":
        return "In Progress";
      case "Finished":
        return "Done";
      default:
        return "Invalid";
    }
  }
}
