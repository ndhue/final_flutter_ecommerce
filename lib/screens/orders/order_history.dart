import 'package:final_ecommerce/data/orders_data.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrdersHistoryScreenState createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  // Sao chép danh sách đơn hàng để có thể cập nhật trạng thái
  List<Map<String, dynamic>> orderList = List.from(orders);

  // Hàm đánh dấu đơn hàng đã được đánh giá
  void _markAsReviewed(int index) {
    setState(() {
      orderList[index]["isReviewed"] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn đã mua", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: orderList.length,
          itemBuilder: (context, index) {
            final order = orderList[index];

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên cửa hàng & trạng thái
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (order["isFavorite"])
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Yêu thích",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Text(
                              order["store"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          order["status"],
                          style: const TextStyle(color: primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Hình ảnh & Tên sản phẩm
                    Row(
                      children: [
                        Image.asset(
                          order["image"],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            order["product"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Giá sản phẩm
                    Row(
                      children: [
                        if (order["priceOld"] > 0)
                          Text(
                            "${order["priceOld"]}đ",
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(width: 5),
                        Text(
                          "${order["priceNew"]}đ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Tổng số tiền
                    Text(
                      "Tổng số tiền: ${order["total"]}đ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    // Đánh giá hoặc Mua lại
                    if (order.containsKey("reviewReward"))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: primaryColor),
                            const SizedBox(width: 5),
                            Text(
                              "Đánh giá sản phẩm trước để nhận ${order["reviewReward"]} Xu",
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black12),
                          ),
                          child: const Text("Mua lại"),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
