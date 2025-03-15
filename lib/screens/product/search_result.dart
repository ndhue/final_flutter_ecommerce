import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/models_export.dart';
import '/widgets/product_card.dart';
import '/data/mock_data.dart';
import '/widgets/buttons/cart_button.dart';
import '/routes/route_constants.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({super.key});

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "Search result";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      setState(() {
        searchQuery = args;
        searchController.text = args;
      });
    }
  }

  List<Product> get filteredProducts {
    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, productSearchRoute);
            }
          },
        ),
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: "Search...",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.grey),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value.isEmpty ? "Search result" : value;
            });
          },
        ),
        actions: const [CartButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search result for "$searchQuery"',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  filteredProducts.isEmpty
                      ? const Center(
                        child: Text(
                          'No products found.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: filteredProducts[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
