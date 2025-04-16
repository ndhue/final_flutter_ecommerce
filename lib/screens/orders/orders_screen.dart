import 'package:final_ecommerce/data/mock_data.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/utils.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasOrder = true; // đổi false để test Empty UI

    return Scaffold(
      body: hasOrder ? const OrderListView() : const EmptyOrderView(),
    );
  }
}

class EmptyOrderView extends StatelessWidget {
  const EmptyOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty-order.png',
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Orders Found!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Currently you do not have any orders. When you order something, it will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  entryPointScreenRoute,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderListView extends StatelessWidget {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search bar
        InkWell(
          onTap: () => {},
          onLongPress: () => {},
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  "Search order",
                  style: TextStyle(color: iconColor, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Order Received
        ...mockOrders.map((order) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildOrderItem(context, order),
          );
        }),
      ],
    );
  }

  Widget _buildOrderItem(BuildContext context, Order order) {
    var latestStatus = order.statusHistory.first;
    Color statusColor = getStatusColor(latestStatus.status);
    String date = formatDate(latestStatus.time);
    String imageUrl = order.orderDetails[0].imageUrl;
    String name = order.orderDetails[0].productName;
    String color = order.orderDetails[0].colorName;
    List<String> actions = getActionsForStatus(latestStatus.status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  orderDetailsScreenRoute,
                  arguments: order,
                );
              },
              onLongPress: () {
                Navigator.pushNamed(
                  context,
                  orderDetailsScreenRoute,
                  arguments: order,
                );
              },
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle, color: statusColor, size: 12),
                          const SizedBox(width: 8),
                          Text(
                            latestStatus.status,
                            style: TextStyle(color: statusColor),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          date,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.navigate_next, color: iconColor, size: 32),
                ],
              ),
            ),
            const Divider(height: 20),
            // Product info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    imageUrl,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 70,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Variant: $color',
                        style: TextStyle(color: darkTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Actions
            if (actions.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    actions
                        .map(
                          (action) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: OutlinedButton(
                                onPressed: () {},
                                child: Text(action),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
