import 'package:flutter/material.dart';

import 'components/navigation_drawer.dart';

class AdminEntryPoint extends StatefulWidget {
  const AdminEntryPoint({super.key});

  @override
  State<AdminEntryPoint> createState() => _AdminEntryPointState();
}

class _AdminEntryPointState extends State<AdminEntryPoint> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      drawer: CustomDrawer(),
      body: Center(child: Text("Admin Dashboard")),
    );
  }
}
