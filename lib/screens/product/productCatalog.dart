import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/buttons/cart_button.dart';
import 'package:flutter/material.dart';
import 'package:final_ecommerce/models/models_export.dart';
import '/widgets/product_card.dart';
import '/data/mock_data.dart';


class ProductCatalog extends StatefulWidget {
  final String category; // Danh mục được chọn

  const ProductCatalog({super.key, required this.category});

  @override
  _ProductCatalogState createState() => _ProductCatalogState();
}

class _ProductCatalogState extends State<ProductCatalog> {
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.category; // Khởi tạo danh mục được chọn
  }

  // Lọc sản phẩm theo danh mục
  List<Product> get filteredProducts {
    if (selectedCategory.toLowerCase() == 'all') {
      return products; // Trả về tất cả sản phẩm nếu danh mục là "All"
    }
    return products
        .where((product) =>
            product.category.toLowerCase() == selectedCategory.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.only(right: defaultPadding),
        backgroundColor: Colors.white,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const SizedBox(width: 8),
              Text(
                selectedCategory,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        actions: [CartButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(filteredProducts.isNotEmpty)
             Align(
             child: Text(
              '${filteredProducts.length} Items',
              style: TextStyle(fontSize: 16, color: iconColor),
            ), 
            ),
            SizedBox(height: 20,),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.filter_alt, color: iconColor,),
                      onPressed: () {},
                    ),
                Text('Filter')
                  ], 
                ),

                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: iconColor),
                      onPressed: () {},
                    ),
                  
                  Text('Sort by')
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}