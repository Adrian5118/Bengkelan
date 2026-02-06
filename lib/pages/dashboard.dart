import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _carsInQueue = 0;
  int _carsInService = 0;
  int _carsFinished = 0;
  late int? _userId;

  @override
  @mustCallSuper
  void initState() {
    _userId = ModalRoute.of(context)!.settings.arguments as int?;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      Navigator.of(context).popAndPushNamed("/login");
      return Placeholder();
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            "BENGKELAN",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
