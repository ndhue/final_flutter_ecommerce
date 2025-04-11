

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AdminIcomeScreen extends StatefulWidget {
  const AdminIcomeScreen({super.key});

  @override
  State<AdminIcomeScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminIcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Text("Income Management Screen"),
      ),
    );
  }
  }