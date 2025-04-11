import 'package:flutter/material.dart';
import 'package:final_ecommerce/data/users_data.dart';
import 'package:final_ecommerce/models/user_model.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  late List<UserModel> displayedUsers;

  @override
  void initState() {
    super.initState();
    displayedUsers = users.map((user) => UserModel.fromMap(user)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(child: _buildCustomersTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search customers...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (value) {
        setState(() {
          displayedUsers = users
              .map((user) => UserModel.fromMap(user))
              .where((user) => user.fullName.toLowerCase().contains(value.toLowerCase()) ||
                  user.email.toLowerCase().contains(value.toLowerCase()))
              .toList();
        });
      },
    );
  }

 Widget _buildCustomersTable() {
  return LayoutBuilder(
    builder: (context, constraints) {
      double columnWidth = constraints.maxWidth / 6; // 6 cột

      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: columnWidth * 0.1,
              headingRowColor: MaterialStateProperty.all(Colors.blueGrey[50]),
              columns: const [
                DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Points', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Used', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: displayedUsers.map((user) {
                return DataRow(cells: [
                  DataCell(SizedBox(width: columnWidth, child: Text(user.id))),
                  DataCell(SizedBox(width: columnWidth, child: Text(user.fullName))),
                  DataCell(SizedBox(
                    width: columnWidth,
                    child: Text(user.email, overflow: TextOverflow.ellipsis),
                  )),
                  DataCell(SizedBox(width: columnWidth, child: Text('${user.loyaltyPoints}'))),
                  DataCell(SizedBox(width: columnWidth, child: Text('${user.loyaltyPointsUsed}'))),
                  DataCell(
                    SizedBox(
                      width: columnWidth,
                      child: Tooltip(
                        message: user.shippingAddress,
                        child: Text(
                          user.shippingAddress,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      );
    },
  );
}

}