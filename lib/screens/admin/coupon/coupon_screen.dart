import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/screens/admin/coupon/components/coupon_dialog.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminCouponScreen extends StatefulWidget {
  const AdminCouponScreen({super.key});

  @override
  State<AdminCouponScreen> createState() => _AdminCouponScreenState();
}

class _AdminCouponScreenState extends State<AdminCouponScreen> {
  @override
  void initState() {
    super.initState();
    final couponProvider = context.read<CouponProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      couponProvider.loadCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;

    return Consumer<CouponProvider>(
      builder: (context, couponProvider, child) {
        final coupons = couponProvider.coupons;
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 32.0 : defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Coupons Management',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 24 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 24 : 16,
                          vertical: isLargeScreen ? 16 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _showAddCouponDialog(context, couponProvider);
                      },
                      icon: const Icon(Icons.add),
                      label: Text(
                        'Add New Coupon',
                        style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isLargeScreen ? 24 : 16),
                buildDashboard(coupons),
                SizedBox(height: isLargeScreen ? 32 : 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coupon List',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 20 : 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isLargeScreen ? 16 : 12),
                        if (couponProvider.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (coupons.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.confirmation_number_outlined,
                                    size: isLargeScreen ? 64 : 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No coupons found',
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 18 : 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Create your first coupon to start offering discounts',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 16 : 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          _buildResponsiveTable(
                            coupons,
                            context,
                            couponProvider,
                            isLargeScreen,
                          ),
                      ],
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

  Widget _buildResponsiveTable(
    List<Coupon> coupons,
    BuildContext context,
    CouponProvider couponProvider,
    bool isLargeScreen,
  ) {
    return isLargeScreen
        ? buildCouponTable(coupons, context, couponProvider, isLargeScreen)
        : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: buildCouponTable(
            coupons,
            context,
            couponProvider,
            isLargeScreen,
          ),
        );
  }
}

Widget _buildStatisticCard(
  String title,
  int value,
  Color color,
  IconData icon,
  bool isLargeScreen,
) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(icon, color: color, size: isLargeScreen ? 24 : 20),
                    SizedBox(width: isLargeScreen ? 8 : 4),
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 16 : 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: isLargeScreen ? 28 : 24,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: isLargeScreen ? 80 : 60,
              width: isLargeScreen ? 80 : 60,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: value.toDouble(),
                      color: color,
                      title:
                          value > 9
                              ? '$value'
                              : '', // Only show text if there's space
                      radius: isLargeScreen ? 30 : 25,
                      titleStyle: TextStyle(
                        fontSize: isLargeScreen ? 16 : 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      showTitle: value > 0, // Don't show title for zero values
                    ),
                    if (value == 0)
                      PieChartSectionData(
                        value: 1,
                        color: Colors.grey[300]!,
                        title: '',
                        radius: isLargeScreen ? 30 : 25,
                      ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: isLargeScreen ? 20 : 15,
                  startDegreeOffset: -90,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildDashboard(List<Coupon> coupons) {
  int totalCoupons = coupons.length;
  int usedCoupons = coupons.where((c) => c.timesUsed > 0).length;
  int activeCoupons = coupons.where((c) => !c.disable).length;
  int disabledCoupons = coupons.where((c) => c.disable).length;

  return LayoutBuilder(
    builder: (context, constraints) {
      bool isLargeScreen = constraints.maxWidth > 1000;
      bool isMediumScreen =
          constraints.maxWidth > 600 && constraints.maxWidth <= 1000;

      // Determine grid layout based on screen size
      int crossAxisCount;
      double childAspectRatio;

      if (isLargeScreen) {
        crossAxisCount = 4;
        childAspectRatio = 1.5;
      } else if (isMediumScreen) {
        // For medium screens, use 2 columns but with more height
        crossAxisCount = 2;
        childAspectRatio = 1.8;
      } else {
        crossAxisCount = 1;
        childAspectRatio = 1.2;
      }

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: isLargeScreen ? 16.0 : 8.0,
        crossAxisSpacing: isLargeScreen ? 16.0 : 8.0,
        children: [
          _buildStatisticCard(
            'Total Coupons',
            totalCoupons,
            Colors.blue,
            Icons.confirmation_number,
            isLargeScreen,
          ),
          _buildStatisticCard(
            'Used Coupons',
            usedCoupons,
            Colors.green,
            Icons.check_circle,
            isLargeScreen,
          ),
          _buildStatisticCard(
            'Active Coupons',
            activeCoupons,
            Colors.orange,
            Icons.flash_on,
            isLargeScreen,
          ),
          _buildStatisticCard(
            'Disabled Coupons',
            disabledCoupons,
            Colors.red,
            Icons.cancel,
            isLargeScreen,
          ),
        ],
      );
    },
  );
}

Widget buildCouponTable(
  List<Coupon> coupons,
  BuildContext context,
  CouponProvider couponProvider,
  bool isLargeScreen,
) {
  return DataTable(
    headingTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      color: primaryColor,
      fontSize: isLargeScreen ? 16 : 14,
    ),
    dataTextStyle: TextStyle(
      fontSize: isLargeScreen ? 15 : 13,
      color: Colors.black87,
    ),
    columnSpacing: isLargeScreen ? 32.0 : 16.0,
    horizontalMargin: isLargeScreen ? 24.0 : 16.0,
    headingRowHeight: isLargeScreen ? 60.0 : 50.0,
    dataRowHeight: isLargeScreen ? 72.0 : 56.0,
    columns: const [
      DataColumn(label: Text('Status')),
      DataColumn(label: Text('Code')),
      DataColumn(label: Text('Created At')),
      DataColumn(label: Text('Max Uses')),
      DataColumn(label: Text('Times Used')),
      DataColumn(label: Text('Value')),
      DataColumn(label: Text('Actions')),
    ],
    rows:
        coupons.map((coupon) {
          return DataRow(
            cells: [
              DataCell(
                Switch(
                  value: !coupon.disable,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    couponProvider.updateCoupon(coupon.id, {'disable': !value});
                  },
                ),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: Text(
                    coupon.code,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(FormatHelper.formatDateTime(coupon.createdAt.toDate())),
              ),
              DataCell(Text(coupon.maxUses.toString())),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(coupon.timesUsed.toString()),
                    SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            coupon.maxUses > 0
                                ? (coupon.timesUsed / coupon.maxUses).clamp(
                                  0.0,
                                  1.0,
                                )
                                : 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        coupon.type == CouponType.percent
                            ? Colors.blue[50]
                            : Colors.green[50],
                  ),
                  child: Text(
                    coupon.type == CouponType.percent
                        ? '${(coupon.value * 100).toStringAsFixed(0)}%'
                        : FormatHelper.formatCurrency(coupon.value),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color:
                          coupon.type == CouponType.percent
                              ? Colors.blue[700]
                              : Colors.green[700],
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.blue[600],
                        size: isLargeScreen ? 24 : 20,
                      ),
                      tooltip: 'Edit coupon',
                      onPressed: () {
                        _showEditCouponDialog(coupon, context, couponProvider);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red[600],
                        size: isLargeScreen ? 24 : 20,
                      ),
                      tooltip: 'Delete coupon',
                      onPressed: () {
                        _showDeleteConfirmation(
                          context,
                          coupon,
                          couponProvider,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
  );
}

void _showDeleteConfirmation(
  BuildContext context,
  Coupon coupon,
  CouponProvider couponProvider,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Coupon'),
        content: Text(
          'Are you sure you want to delete the coupon "${coupon.code}"?',
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              couponProvider.deleteCoupon(coupon.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _showEditCouponDialog(
  Coupon coupon,
  BuildContext context,
  CouponProvider couponProvider,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => CouponDialog(isEditing: true, coupon: coupon),
  );
}

void _showAddCouponDialog(BuildContext context, CouponProvider couponProvider) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => CouponDialog(isEditing: false),
  );
}
