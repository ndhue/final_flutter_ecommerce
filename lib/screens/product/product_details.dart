import 'package:final_ecommerce/providers/cart_provider.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/buttons/cart_button.dart';
import 'package:flutter/material.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:provider/provider.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key, required this.product});

  final Product product;

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late Product productSelected;
  int _currentImageIndex = 0;
  String ? _selectedStorage;
  Color ? _selectedColor;

  @override
  void initState() {
    super.initState();
    productSelected = widget.product;
    _selectedColor = productSelected.variants.isNotEmpty ? productSelected.variants[0].color : null;
    _selectedStorage = productSelected.variants.isNotEmpty ? productSelected.variants[0].name : null;
  }

  void _nextImage() {
    if (_currentImageIndex < productSelected.images.length - 1) {
      setState(() {
        _currentImageIndex++;
      });
    }
  }

  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _selectStorage(String storage){
    setState(() {
      _selectedStorage =  storage;
    });
  }

  void _previousImage() {
    if (_currentImageIndex > 0) {
      setState(() {
        _currentImageIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasColorOptions = productSelected.variants.any((variant) => variant.isColor);

    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.only(right: defaultPadding),
        backgroundColor: Colors.white,
        title: const Text(
          'Details Product',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [CartButton()],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Image.network(
                    productSelected.images[_currentImageIndex],
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  //top: MediaQuery.of(context).size.height * 0.4,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: _currentImageIndex > 0 ? _previousImage : null,
                  ),
                ),
                Positioned(
                 // top: MediaQuery.of(context).size.height * 0.4,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: _currentImageIndex < productSelected.images.length - 1 ? _nextImage : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                productSelected.images.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productSelected.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${productSelected.variants[0].sellingPrice}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (hasColorOptions) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Choose the color',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: productSelected.variants
                          .where((variant) => variant.isColor)
                          .map((variant) => GestureDetector(
                                onTap: () => _selectColor(variant.color ?? Colors.transparent),
                                child: ColorOption(
                                  variant.color ?? Colors.transparent,
                                  isSelected: _selectedColor == variant.color,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Choose the storage',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 10.0,
                    children: productSelected.variants.map((variant) {
                      return GestureDetector(
                        onTap: () => _selectStorage(variant.name),
                        child: StorageOption(variant.name, isSelected: _selectedStorage == variant.name),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description of product',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productSelected.description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false).addToCart(productSelected);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${productSelected.name} đã được thêm vào giỏ hàng')),
            );
          },
          child: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class StorageOption extends StatelessWidget {
  final String storage;
  const StorageOption(this.storage, {this.isSelected=false});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.grey,
        //border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey, width: 2),
      ),
     
        child: Text(storage, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      
       
    );
  }
}

class ColorOption extends StatelessWidget {
  final Color color;
  const ColorOption(this.color, {this.isSelected = false});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? Colors.blue : Colors.grey, width: 2),
      ),
    );
  }
}