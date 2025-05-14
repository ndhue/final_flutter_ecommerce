import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/user_model.dart';
import 'package:flutter/material.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  List<UserModel> allUsers = [];
  List<UserModel> displayedUsers = [];
  bool isLoading = true;

  UserModel? selectedUser;

  String _sortColumn = "fullName";
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }

  bool _isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 800 && width <= 1200;
  }

  Future<void> fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final users =
        snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

    setState(() {
      allUsers = users;
      displayedUsers = users;
      isLoading = false;
    });
  }

  void _sortUsers(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }

      displayedUsers.sort((a, b) {
        var aValue;
        var bValue;

        switch (column) {
          case 'fullName':
            aValue = a.fullName;
            bValue = b.fullName;
            break;
          case 'email':
            aValue = a.email;
            bValue = b.email;
            break;
          case 'city':
            aValue = a.city;
            bValue = b.city;
            break;
          default:
            aValue = a.fullName;
            bValue = b.fullName;
        }

        if (aValue == null) return _sortAscending ? -1 : 1;
        if (bValue == null) return _sortAscending ? 1 : -1;

        int comparison = aValue.compareTo(bValue);
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = _isLargeScreen(context);
    final isMediumScreen = _isMediumScreen(context);

    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLargeScreen || isMediumScreen)
                      _buildStatisticsCards(),
                    SizedBox(height: isLargeScreen ? 24.0 : 16.0),
                    _buildSearchBar(isLargeScreen),
                    SizedBox(height: isLargeScreen ? 24.0 : 16.0),
                    isLargeScreen
                        ? Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: _buildCustomersTable(isLargeScreen),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 2,
                                child:
                                    selectedUser != null
                                        ? _buildDetailsPanel()
                                        : const Center(
                                          child: Text(
                                            'Select a customer to view details',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        )
                        : Expanded(child: _buildCustomersTable(isLargeScreen)),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatisticsCards() {
    final totalUsers = allUsers.length;
    final activeUsers = allUsers.where((user) => user.activated).length;
    final completedProfileUsers =
        allUsers
            .where(
              (user) =>
                  user.fullName.isNotEmpty &&
                  user.city.isNotEmpty &&
                  user.district.isNotEmpty &&
                  user.ward.isNotEmpty &&
                  user.shippingAddress.isNotEmpty,
            )
            .length;

    return Row(
      children: [
        _buildStatCard(
          title: 'Total Customers',
          value: totalUsers.toString(),
          icon: Icons.people,
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          title: 'Active Customers',
          value: activeUsers.toString(),
          icon: Icons.verified_user,
          color: Colors.green,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          title: 'Completed Profiles',
          value: '$completedProfileUsers / $totalUsers',
          icon: Icons.assignment_turned_in,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsPanel() {
    final user = selectedUser!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : "?",
                    style: const TextStyle(fontSize: 24, color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('ID', user.id),
                  _buildInfoRow('Full Name', user.fullName),
                  _buildInfoRow('Email', user.email),
                  _buildInfoRow(
                    'Status',
                    user.activated ? 'Active' : 'Inactive',
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Shipping Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('City', user.city),
                  _buildInfoRow('District', user.district),
                  _buildInfoRow('Ward', user.ward),
                  _buildInfoRow('Address', user.shippingAddress),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () => _showEditCustomerDialog(user),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isLargeScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isLargeScreen ? 16.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search customers by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (value) {
                setState(() {
                  displayedUsers =
                      allUsers.where((user) {
                        return user.fullName.toLowerCase().contains(
                              value.toLowerCase(),
                            ) ||
                            user.email.toLowerCase().contains(
                              value.toLowerCase(),
                            );
                      }).toList();

                  selectedUser = null;
                });
              },
            ),
          ),
          if (isLargeScreen) ...[
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: fetchUsers,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomersTable(bool isLargeScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: isLargeScreen ? 30 : 20,
              dataRowMinHeight: isLargeScreen ? 60 : 48,
              dataRowMaxHeight: isLargeScreen ? 80 : 64,
              headingRowHeight: isLargeScreen ? 56 : 48,
              headingRowColor: MaterialStateProperty.all(Colors.blueGrey[50]),
              showCheckboxColumn: false,
              columns: [
                DataColumn(
                  label: const Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onSort: (_, __) => _sortUsers('fullName'),
                ),
                DataColumn(
                  label: const Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onSort: (_, __) => _sortUsers('email'),
                ),
                DataColumn(
                  label: const Text(
                    'City',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onSort: (_, __) => _sortUsers('city'),
                ),
                if (isLargeScreen)
                  const DataColumn(
                    label: Text(
                      'District',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (isLargeScreen)
                  const DataColumn(
                    label: Text(
                      'Ward',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (isLargeScreen)
                  const DataColumn(
                    label: Text(
                      'Shipping Address',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                const DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows:
                  displayedUsers.map((user) {
                    return DataRow(
                      selected: selectedUser?.id == user.id,
                      onSelectChanged: (_) {
                        setState(() {
                          selectedUser = user;
                        });
                      },
                      cells: [
                        DataCell(
                          SizedBox(
                            width: isLargeScreen ? 150 : 120,
                            child: Text(
                              user.fullName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight:
                                    selectedUser?.id == user.id
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: isLargeScreen ? 220 : 180,
                            child: Text(
                              user.email,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight:
                                    selectedUser?.id == user.id
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: Text(
                              user.city,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (isLargeScreen)
                          DataCell(
                            SizedBox(
                              width: 120,
                              child: Text(
                                user.district,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        if (isLargeScreen)
                          DataCell(
                            SizedBox(
                              width: 120,
                              child: Text(
                                user.ward,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        if (isLargeScreen)
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Text(
                                user.shippingAddress,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  user.activated
                                      ? Colors.green[50]
                                      : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.activated ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color:
                                    user.activated ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: isLargeScreen ? 24 : 20,
                                ),
                                tooltip: 'Edit',
                                onPressed: () => _showEditCustomerDialog(user),
                              ),
                              if (!isLargeScreen)
                                IconButton(
                                  icon: Icon(
                                    Icons.visibility,
                                    color: Colors.grey,
                                    size: isLargeScreen ? 24 : 20,
                                  ),
                                  tooltip: 'View Details',
                                  onPressed: () {
                                    setState(() {
                                      selectedUser = user;
                                    });
                                    _showCustomerDetails(user);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showCustomerDetails(UserModel user) {
    if (_isLargeScreen(context)) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.email,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('ID', user.id),
                        _buildInfoRow('Full Name', user.fullName),
                        _buildInfoRow('Email', user.email),
                        _buildInfoRow(
                          'Status',
                          user.activated ? 'Active' : 'Inactive',
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Shipping Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('City', user.city),
                        _buildInfoRow('District', user.district),
                        _buildInfoRow('Ward', user.ward),
                        _buildInfoRow('Address', user.shippingAddress),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditCustomerDialog(user);
                        },
                      ),
                    ],
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
    final fullNameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final cityController = TextEditingController(text: user.city);
    final districtController = TextEditingController(text: user.district);
    final wardController = TextEditingController(text: user.ward);
    final addressController = TextEditingController(text: user.shippingAddress);

    bool isActivated = user.activated;
    final isLargeScreen = _isLargeScreen(context);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(isLargeScreen ? 64 : 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: isLargeScreen ? 700 : 500,
            height: isLargeScreen ? 600 : 550,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Update Customer Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                        child:
                            isLargeScreen
                                ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildEditableField(
                                            'Full name',
                                            fullNameController,
                                          ),
                                          _buildEditableField(
                                            'Email',
                                            emailController,
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                'Status:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Switch(
                                                value: isActivated,
                                                onChanged:
                                                    (value) => setState(
                                                      () => isActivated = value,
                                                    ),
                                              ),
                                              Text(
                                                isActivated
                                                    ? 'Active'
                                                    : 'Inactive',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildEditableField(
                                            'City',
                                            cityController,
                                          ),
                                          _buildEditableField(
                                            'District',
                                            districtController,
                                          ),
                                          _buildEditableField(
                                            'Ward',
                                            wardController,
                                          ),
                                          _buildEditableField(
                                            'Shipping Address',
                                            addressController,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  children: [
                                    _buildEditableField(
                                      'Full name',
                                      fullNameController,
                                    ),
                                    _buildEditableField(
                                      'Email',
                                      emailController,
                                    ),
                                    _buildEditableField('City', cityController),
                                    _buildEditableField(
                                      'District',
                                      districtController,
                                    ),
                                    _buildEditableField('Ward', wardController),
                                    _buildEditableField(
                                      'Shipping Address',
                                      addressController,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Activated:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Switch(
                                          value: isActivated,
                                          onChanged:
                                              (value) => setState(
                                                () => isActivated = value,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () async {
                              final updatedUser = user.copyWith(
                                fullName: fullNameController.text,
                                email: emailController.text,
                                shippingAddress: addressController.text,
                                city: cityController.text,
                                district: districtController.text,
                                ward: wardController.text,
                                activated: isActivated,
                              );

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.id)
                                  .update(updatedUser.toMap());

                              Navigator.of(context).pop();

                              if (selectedUser?.id == user.id) {
                                setState(() {
                                  selectedUser = updatedUser;
                                });
                              }

                              await fetchUsers();
                            },
                            child: const Text('Save Changes'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
