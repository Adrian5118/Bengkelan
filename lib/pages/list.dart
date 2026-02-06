import 'package:bengkelan/lib/db/handler.dart';
import 'package:flutter/material.dart';
import 'package:searchable_listview/searchable_listview.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<dynamic> _listing = [];
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    var arg =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    String status = arg["status"]! as String;
    int userId = arg["userId"]! as int;

    DatabaseHandler.get()
        .getAll(
          table: "service_status st,car car",
          fields: "st.id, car.name, st.user_id",
          where: "st.user_id = $userId AND st.status = '$status'",
        )
        .then((list) {
          if (!_isLoaded) {
            setState(() {
              _listing = list;
              _isLoaded = true;
            });
          }
        });

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("${_getDisplayStatus(status)} Car Listings")),
      ),
      body: SearchableList(
        initialList: _listing,
        itemBuilder: (item) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Text(
                  item["name"] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                flex: 3,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      "/details",
                      arguments: {
                        "serviceId": item["id"] as int,
                        "userId": item["user_id"] as int,
                      },
                    );
                  },
                  child: Text(
                    "Details",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          );
        },
        filter: (query) => _listing
            .where(
              (item) => (item["name"] as String).toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList(),
      ),
    );
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
