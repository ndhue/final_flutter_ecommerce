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
  // Define the _activated variable

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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: (value) {
        setState(() {
          displayedUsers =
              users
                  .map((user) => UserModel.fromMap(user))
                  .where(
                    (user) =>
                        user.fullName.toLowerCase().contains(
                          value.toLowerCase(),
                        ) ||
                        user.email.toLowerCase().contains(value.toLowerCase()),
                  )
                  .toList();
        });
      },
    );
  }

  Widget _buildCustomersTable() {
  return LayoutBuilder(
    builder: (context, constraints) {
      double columnWidth = constraints.maxWidth / 5; // Chia đều cột theo chiều rộng

      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth, // Đảm bảo bảng không nhỏ hơn chiều rộng màn hình
            ),
            child: DataTable(
              columnSpacing: columnWidth * 0.1,
              headingRowColor: MaterialStateProperty.all(Colors.blueGrey[50]),
              columns: const [
                DataColumn(
                  label: Text(
                    'ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Address',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: displayedUsers.map((user) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: columnWidth,
                        child: Text(
                          user.id,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: columnWidth,
                        child: Text(
                          user.fullName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: columnWidth,
                        child: Text(
                          user.email,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
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
                    DataCell(
                      SizedBox(
                        width: columnWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditCustomerDialog(user),
                            ),
                            TextButton(
                              onPressed: () => _showCustomerDetails(user),
                              child: const Text(
                                "Details",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    },
  );
}
  void _showCustomerDetails(UserModel user) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 500,
          height: 500,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blueGrey[50],
                width: double.infinity,
                child: const Text(
                  'Customer Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Customer Identify:', user.id),
                      _buildInfoRow('Full name:', user.fullName),
                      _buildInfoRow('Email:', user.email),
                      _buildInfoRow('Address:', user.shippingAddress),
                      _buildInfoRow('Loyalty Points:', '${user.loyaltyPoints}'),
                      _buildInfoRow('Loyalty Points Used:', '${user.loyaltyPointsUsed}'),
                      _buildInfoRow('Activated:', user.activated ? 'Yes' : 'No'),
                      // Thêm các trường khác nếu bạn muốn
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showEditCustomerDialog(UserModel user) {
  // Tạo controller để có thể chỉnh sửa
  final fullNameController = TextEditingController(text: user.fullName);
  final emailController = TextEditingController(text: user.email);
  final addressController = TextEditingController(text: user.shippingAddress);

  bool isActivated = user.activated;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 500,
          height: 550,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blueGrey[50],
                    width: double.infinity,
                    child: const Text(
                      'Update Customer Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildEditableField('Full name', fullNameController),
                          _buildEditableField('Email', emailController),
                          _buildEditableField('Address', addressController),
                          Row(
                            children: [
                              const Text(
                                'Activted:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                value: isActivated,
                                onChanged: (value) {
                                  setState(() {
                                    isActivated = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Ở đây bạn có thể gọi setState hoặc lưu vào DB
                            setState(() {
                              // Cập nhật thông tin người dùng
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

}
Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 70),
        Expanded(
          child: Text(value),
        ),
      ],
    ),
  );
}


Widget _buildEditableField(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    ),
  );
}