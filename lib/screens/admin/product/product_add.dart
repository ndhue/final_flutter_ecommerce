import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final idController = TextEditingController();
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();
  final costPriceController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final discountController = TextEditingController();

  List<String> imageUrls = [];
  List<Map<String, dynamic>> variants = [
    {
      'variantId': '',
      'colorCode': '',
      'colorName': '',
      'inventory': '',
      'activated': false,
    }
  ];

  List<String> selectedColors = [];
  bool isActivated = true;

  void _addVariant() {
    setState(() {
      variants.add({
        'variantId': '',
        'colorCode': '',
        'colorName': '',
        'inventory': '',
        'activated': false,
      });
    });
  }

  void _submitProduct() {
    if (_formKey.currentState!.validate()) {
      final product = {
        'id': idController.text.trim(),
        'name': nameController.text.trim(),
        'brand': brandController.text.trim(),
        'category': categoryController.text.trim(),
        'description': descriptionController.text.trim(),
        'createdAt': Timestamp.now(),
        'images': imageUrls,
        'costPrice': double.tryParse(costPriceController.text.trim()) ?? 0,
        'sellingPrice': double.tryParse(sellingPriceController.text.trim()) ?? 0,
        'discount': double.tryParse(discountController.text.trim()) ?? 0,
        'rating': 0.0,
        'salesCount': 0,
        'totalReviews': 0,
        'activated': isActivated,
        'specs': variants,
        'availableColors': selectedColors,
      };

      // FirebaseFirestore.instance.collection('products').doc(idController.text).set(product);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Product added successfully")),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildProductInfoSection()),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildVariantSection()),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductInfoSection(),
                        const SizedBox(height: 20),
                        _buildVariantSection(),
                      ],
                    ),
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _submitProduct,
      //   icon: const Icon(Icons.save),
      //   label: const Text("Save"),
      // ),
    );
  }

 Widget _buildProductInfoSection() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Product Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        TextFormField(controller: idController, decoration: const InputDecoration(labelText: "ID")),
        TextFormField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
        TextFormField(controller: brandController, decoration: const InputDecoration(labelText: "Brand")),
        TextFormField(controller: categoryController, decoration: const InputDecoration(labelText: "Category")),
        TextFormField(controller: costPriceController, decoration: const InputDecoration(labelText: "Cost Price")),
        TextFormField(controller: sellingPriceController, decoration: const InputDecoration(labelText: "Selling Price")),
        TextFormField(controller: discountController, decoration: const InputDecoration(labelText: "Discount (0.0 - 1.0)")),
        const SizedBox(height: 16),
        const Text("Description"),
        TextFormField(
          controller: descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Enter description...",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Images"),
        ElevatedButton(
          onPressed: () {
            // TODO: Add image picker logic
          },
          child: const Text("Add Images"),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(value: isActivated, onChanged: (val) => setState(() => isActivated = val!)),
            const Text("Activate this product"),
           const Spacer(), // đẩy phần còn lại về phải
            TextButton(onPressed: () => {}, 
             child: const Text("Save", style: TextStyle(color: Colors.blue, )),
             
             ),
          ],
          
        ),
      ],
    ),
  );
}


  Widget _buildVariantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Variants", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ...variants.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> variant = entry.value;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: variant.keys.map((key) {
                  final isBool = variant[key] is bool;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: isBool
                        ? Row(
                            children: [
                              Checkbox(
                                value: variant[key] ?? false,
                                onChanged: (val) => setState(() => variant[key] = val),
                              ),
                              Text(key),
                            ],
                          )
                        : TextFormField(
                            initialValue: variant[key],
                            decoration: InputDecoration(labelText: key),
                            onChanged: (value) => variant[key] = value,
                          ),
                  );
                }).toList(),
              ),
            ),
          );
        }),
        Center(
          child: OutlinedButton.icon(
            onPressed: _addVariant,
            icon: const Icon(Icons.add),
            label: const Text("Add Variant"),
          ),
        ),
      ],
    );
  }
}
