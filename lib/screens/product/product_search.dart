import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/search_history_storage.dart';
import 'package:final_ecommerce/widgets/buttons/cart_button.dart';
import 'package:flutter/material.dart';

class ProductSearch extends StatefulWidget {
  const ProductSearch({super.key});

  @override
  State<ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  List<String> recentSearches = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final history = await SearchHistoryStorage.loadSearchHistory();
    setState(() {
      recentSearches = history;
    });
  }

  Future<void> _saveSearchHistory() async {
    await SearchHistoryStorage.saveSearchHistory(recentSearches);
  }

  void _searchProduct(String query) {
    if (query.isNotEmpty) {
      setState(() {
        if (!recentSearches.contains(query)) {
          recentSearches.insert(0, query); // Add to recent searches
          if (recentSearches.length > 10) {
            recentSearches.removeLast(); // Limit history to 10 items
          }
        }
      });
      _saveSearchHistory();

      // Navigate to SearchResults screen with the query
      Navigator.pushNamed(context, searchResultRoute, arguments: query);
    }
  }

  void _clearSearchHistory() {
    setState(() {
      recentSearches.clear();
    });
    SearchHistoryStorage.clearSearchHistory();
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
          decoration: InputDecoration(
            hintText: "Search...",
            hintStyle: TextStyle(color: iconColor, fontSize: 16),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: iconColor),
          ),
          onSubmitted: _searchProduct, // Trigger search on Enter
        ),
        actions: const [CartButton()],
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
                  onPressed: _clearSearchHistory,
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
                      onPressed: () {
                        setState(() {
                          recentSearches.removeAt(
                            index,
                          ); // Remove specific search
                        });
                        _saveSearchHistory();
                      },
                    ),
                    onTap: () => _searchProduct(recentSearches[index]),
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
