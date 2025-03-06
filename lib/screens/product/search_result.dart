import 'package:flutter/material.dart';

class SearchResults extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      "name":
          "Earphones for monitor with high-quality sound and noise cancelling",
      "price": "\$199.99",
      "image":
          "https://bizweb.dktcdn.net/100/340/129/products/tai-nghe-sony-ch-ch520-cuongphanvn-13.jpg?v=1680431911657",
    },
    {
      "name": "Monitor LG 22\" 4K Ultra HD with HDR10",
      "price": "\$199.99",
      "image": "https://example.com/ipadpro.jpg",
    },
    {
      "name": "Earphones for monitor",
      "price": "\$199.99",
      "image": "https://example.com/ipadpro.jpg",
    },
    {
      "name": "Monitor LG 22\" 4K",
      "price": "\$199.99",
      "image": "https://example.com/ipadpro.jpg",
    },
    {
      "name": "Earphones for monitor",
      "price": "\$199.99",
      "image": "https://example.com/ipadpro.jpg",
    },
    {
      "name": "Monitor LG 22\" 4K",
      "price": "\$199.99",
      "image": "https://example.com/laptop1.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: "Earphone",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.grey),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
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
                Text(
                  "Search result for \"Earphone\"",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      double imageSize = constraints.maxWidth * 1;
                      double textSize = constraints.maxWidth * 0.07;
                      double buttonHeight = constraints.maxHeight * 0.8;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 7,
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: imageSize,
                                    height: imageSize,
                                    child: Image.network(
                                      product["image"],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      product["name"],
                                      style: TextStyle(
                                        fontSize: textSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      product["price"],
                                      style: TextStyle(
                                        fontSize: textSize * 0.9,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  bottom: 10,
                                ),
                                child: SizedBox(
                                  height: buttonHeight,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Text(
                                      "Add to cart",
                                      style: TextStyle(
                                        fontSize: textSize * 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
