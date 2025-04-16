import 'package:final_ecommerce/models/models_export.dart';
import 'package:flutter/material.dart';

class TrackOrderBottomSheet extends StatelessWidget {
  final List<StatusHistory> statusHistory;

  const TrackOrderBottomSheet({super.key, required this.statusHistory});

  @override
  Widget build(BuildContext context) {
    final sortedHistory = List<StatusHistory>.from(statusHistory)
      ..sort((a, b) => b.time.compareTo(a.time)); // latest first

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Track Order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Status list
          ...sortedHistory.map((history) {
            final isDone = _isDone(history.status);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time
                  SizedBox(
                    width: 60,
                    child: Text(
                      "${history.time.hour.toString().padLeft(2, '0')}:${history.time.minute.toString().padLeft(2, '0')} ${history.time.hour < 12 ? 'am' : 'pm'}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  // Timeline icon
                  Column(
                    children: [
                      Icon(
                        isDone
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: isDone ? Colors.blue : Colors.grey,
                      ),
                      if (history != sortedHistory.last)
                        Container(
                          width: 2,
                          height: 32,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Status Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history.status,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDone ? Colors.black : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusNote(history.status),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _isDone(String status) {
    return status == 'Confirmed' ||
        status == 'Shipping' ||
        status == 'Delivered' ||
        status == 'Cancelled';
  }

  String _getStatusNote(String status) {
    switch (status) {
      case 'Pending':
        return 'Waiting for confirmation';
      case 'Confirmed':
        return 'Your order has been confirmed';
      case 'Shipping':
        return 'Order is on the way';
      case 'Delivered':
        return 'Your order has been delivered';
      case 'Cancelled':
        return 'Your order has been cancelled';
      default:
        return '';
    }
  }
}
