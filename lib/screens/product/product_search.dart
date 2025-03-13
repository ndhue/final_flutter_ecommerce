import 'package:flutter/material.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/routes/router.dart' as router;

class ProductSearch extends StatefulWidget {
  const ProductSearch({super.key});

  @override
  _ProductSearchState createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  List<String> recentSearches = [
    "Iphone 12 pro max",
    "Camera fujifilm",
    "Tripod Mini",
    "Bluetooth speaker",
    "Drawing pad",
  ];
  TextEditingController searchController = TextEditingController();

  void _searchProduct(String query) {
    if (query.isNotEmpty) {
      setState(() {
        if (!recentSearches.contains(query)) {
          recentSearches.insert(0, query); // Lưu vào lịch sử tìm kiếm
        }
      });

      // Chuyển sang trang SearchResults và truyền query
      Navigator.pushNamed(context, searchResultRoute, arguments: query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: "Search...",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.grey),
          ),
          onSubmitted: _searchProduct, // Khi nhấn Enter, gọi hàm tìm kiếm
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Last search",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed:
                      () => setState(() {
                        recentSearches.clear();
                      }),
                  child: const Text(
                    "Clear all",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recentSearches.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: Text(recentSearches[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed:
                          () => setState(() {
                            recentSearches.removeAt(index);
                          }),
                    ),
                    onTap:
                        () => _searchProduct(
                          recentSearches[index],
                        ), // Khi click vào, tìm lại từ khóa
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
