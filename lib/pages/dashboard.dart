import 'package:bengkelan/lib/db/handler.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Map<String, int> _carServiceStatusCount = {
    "Queued": 0,
    "Working": 0,
    "Finished": 0,
  };
  late int? _userId;

  List<TableRow> _inProgressCarsRow = [];

  @override
  Widget build(BuildContext context) {
    var arg = ModalRoute.of(context)!.settings.arguments as Map<String, int?>;
    _userId = arg["userId"];

    if (_userId == null) {
      Navigator.of(context).popAndPushNamed("/login");
      return Placeholder();
    }

    _getInProgressCars().then((list) async {
      await _getCarServiceStatusCount();

      _inProgressCarsRow = list;
      setState(() {});
      await Future.delayed(Duration(seconds: 5));
    });

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            "BENGKELAN",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            const Text(
              "Your Cars",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed("/list", arguments: {"status": "Queued"});
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          backgroundColor: Colors.yellow,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.zero),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Queued",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "${_carServiceStatusCount["Queued"]}",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            "/list",
                            arguments: {"status": "Working"},
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          backgroundColor: Colors.lightBlue,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.zero),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "In Progress",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "${_carServiceStatusCount["Working"]}",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            "/list",
                            arguments: {"status": "Finished"},
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          backgroundColor: Colors.lightGreen,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.zero),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Done",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "${_carServiceStatusCount["Finished"]}",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              "Cars in Service",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
            ),
            Expanded(
              flex: 13,
              child: Table(
                border: TableBorder.all(),
                columnWidths: {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(30),
                  2: FlexColumnWidth(4),
                },
                children: _inProgressCarsRow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCarServiceStatusCount() async {
    await DatabaseHandler.get()
        .count(
          table: "service_status",
          where: {"user_id": _userId, "status": "Queued"},
        )
        .then((count) {
          _carServiceStatusCount["Queued"] = count;
        });

    await DatabaseHandler.get()
        .count(
          table: "service_status",
          where: {"user_id": _userId, "status": "Working"},
        )
        .then((count) {
          _carServiceStatusCount["Working"] = count;
        });

    await DatabaseHandler.get()
        .count(
          table: "service_status",
          where: {"user_id": _userId, "status": "Finished"},
        )
        .then((count) {
          _carServiceStatusCount["Finished"] = count;
        });
  }

  Future<List<TableRow>> _getInProgressCars() async {
    List<TableRow> returnList = [];

    returnList.add(
      TableRow(
        children: <Widget>[
          TableCell(child: Center(child: const Text("No"))),
          TableCell(child: Center(child: const Text("Car"))),
          TableCell(child: Center(child: const Text("Details"))),
        ],
      ),
    );

    await DatabaseHandler.get()
        .getAll(
          table: "service_status st,car cr",
          fields: "cr.name, st.id",
          where:
              "st.car_id = cr.id AND user_id = $_userId AND st.status='Working'",
        )
        .then((list) {
          int counter = 1;

          for (var item in list) {
            Map<String, dynamic> row = item as Map<String, dynamic>;

            returnList.add(
              TableRow(
                children: <Widget>[
                  TableCell(child: Center(child: Text("$counter"))),
                  TableCell(child: Center(child: Text(row["name"]))),
                  TableCell(
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed("/details", arguments: {"id": row["id"]});
                        },
                        child: const Text("View"),
                      ),
                    ),
                  ),
                ],
              ),
            );

            counter += 1;
          }
        });

    return returnList;
  }
}
