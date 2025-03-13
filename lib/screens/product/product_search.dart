import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/buttons/cart_button.dart';
import 'package:flutter/material.dart';

class ProductSearch extends StatefulWidget {
  const ProductSearch({super.key});

  @override
  // ignore: library_private_types_in_public_api
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

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

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
        leading: BackButton(
          style: ButtonStyle(iconSize: WidgetStateProperty.all(20)),
        ),
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search...",
            hintStyle: TextStyle(color: iconColor, fontSize: 16),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: iconColor),
          ),
          onSubmitted: _searchProduct, // Khi nhấn Enter, gọi hàm tìm kiếm
        ),
        actions: [CartButton()],
      ),
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        ),
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Last search",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
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
