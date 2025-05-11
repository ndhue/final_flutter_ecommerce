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
    return Consumer<CouponProvider>(
      builder: (context, couponProvider, child) {
        final coupons = couponProvider.coupons;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coupons Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                buildDashboard(coupons),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Coupon List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showAddCouponDialog(context, couponProvider);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buildCouponTable(coupons, context, couponProvider),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildStatisticCard(
  String title,
  int value,
  Color color,
  IconData icon,
) {
  return Card(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  SizedBox(width: 4),
                  Text(title, overflow: TextOverflow.ellipsis),
                ],
              ),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: value.toDouble(),
                    color: color,
                    title: '$value',
                    radius: 25, // Giảm kích thước radius
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 15,
                startDegreeOffset: -90,
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
      int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        children: [
          _buildStatisticCard(
            'Total',
            totalCoupons,
            Colors.blue,
            Icons.confirmation_number,
          ),
          _buildStatisticCard(
            'Used',
            usedCoupons,
            Colors.green,
            Icons.check_circle,
          ),
          _buildStatisticCard(
            'Active',
            activeCoupons,
            Colors.orange,
            Icons.flash_on,
          ),
          _buildStatisticCard(
            'Disabled',
            disabledCoupons,
            Colors.red,
            Icons.cancel,
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
) {
  return DataTable(
    columns: const [
      DataColumn(label: Text('Activate')),
      DataColumn(label: Text('Code')),
      DataColumn(label: Text('Created At')),
      DataColumn(label: Text('Max Uses')),
      DataColumn(label: Text('Times Used')),
      DataColumn(label: Text('Value')),
      DataColumn(label: Text('Status')),
      DataColumn(label: Text('Actions')),
    ],
    rows:
        coupons.map((coupon) {
          return DataRow(
            cells: [
              DataCell(
                Switch(
                  value: !coupon.disable,
                  onChanged: (value) {
                    couponProvider.updateCoupon(coupon.id, {'disable': !value});
                  },
                ),
              ),
              DataCell(Text(coupon.code)),
              DataCell(
                Text(FormatHelper.formatDateTime(coupon.createdAt.toDate())),
              ),
              DataCell(Text(coupon.maxUses.toString())),
              DataCell(Text(coupon.timesUsed.toString())),
              DataCell(
                Text(
                  coupon.type == CouponType.percent
                      ? '${(coupon.value * 100).toStringAsFixed(1)}%'
                      : FormatHelper.formatCurrency(coupon.value),
                ),
              ),
              DataCell(Text(coupon.disable ? 'Disabled' : 'Active')),

              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditCouponDialog(coupon, context, couponProvider);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        couponProvider.deleteCoupon(coupon.id);
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
