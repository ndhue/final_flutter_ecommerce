import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/new_product_model.dart';
import 'package:final_ecommerce/providers/product_provider.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AdminProductDetailScreen extends StatefulWidget {
  final NewProduct product;

  const AdminProductDetailScreen({super.key, required this.product});

  @override
  State<AdminProductDetailScreen> createState() =>
      _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late NewProduct product;
  bool isEditing = false;
  bool isAddingVariant = false;
  bool _isLoading = false;
  List<dynamic> _variants = [];

  // Text controllers for editing
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _categoryController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _discountController = TextEditingController();

  // Controllers for variant
  final _variantIdController = TextEditingController();
  final _colorNameController = TextEditingController();
  final _colorCodeController = TextEditingController();
  final _inventoryController = TextEditingController();
  bool _variantActivated = true;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    _initializeControllers();
    _fetchVariants();
  }

  Future<void> _fetchVariants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch variants from Firebase
      final variantsSnapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .doc(product.id)
              .collection('variantInventory')
              .get();

      setState(() {
        _variants = variantsSnapshot.docs.map((doc) => doc.data()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading variants: $e')));
    }
  }

  void _initializeControllers() {
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _brandController.text = product.brand;
    _categoryController.text = product.category;
    _costPriceController.text = product.costPrice.toString();
    _sellingPriceController.text = product.sellingPrice.toString();
    _discountController.text = product.discount.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _discountController.dispose();
    _variantIdController.dispose();
    _colorNameController.dispose();
    _colorCodeController.dispose();
    _inventoryController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        // Reset form values when cancelling edit
        _initializeControllers();
      }
    });
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final productProvider = Provider.of<ProductProvider>(
          context,
          listen: false,
        );

        // Create updated product
        final updatedProduct = NewProduct(
          id: product.id,
          name: _nameController.text.trim(),
          brand: _brandController.text.trim(),
          category: _categoryController.text.trim(),
          description: _descriptionController.text.trim(),
          createdAt: product.createdAt,
          images: product.images,
          costPrice: double.tryParse(_costPriceController.text) ?? 0,
          sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0,
          discount: double.tryParse(_discountController.text) ?? 0,
          specs: product.specs,
          activated: product.activated,
          availableColors: product.availableColors,
          rating: product.rating,
          salesCount: product.salesCount,
          totalReviews: product.totalReviews,
          docSnapshot: product.docSnapshot,
        );

        // Update product in Firestore
        await productProvider.updateProduct(updatedProduct);

        setState(() {
          product = updatedProduct;
          isEditing = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating product: $e')));
      }
    }
  }

  void _toggleAddVariant() {
    setState(() {
      isAddingVariant = !isAddingVariant;
      if (!isAddingVariant) {
        _resetVariantForm();
      }
    });
  }

  void _resetVariantForm() {
    _variantIdController.clear();
    _colorNameController.clear();
    _colorCodeController.clear();
    _inventoryController.clear();
    _variantActivated = true;
  }

  void _addVariant() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create new variant
        final variant = {
          'variantId': _variantIdController.text,
          'colorName': _colorNameController.text,
          'colorCode': _colorCodeController.text,
          'inventory': int.tryParse(_inventoryController.text) ?? 0,
          'activated': _variantActivated,
          'createdAt': Timestamp.now(),
        };

        // Add variant to Firebase
        await FirebaseFirestore.instance
            .collection('products')
            .doc(product.id)
            .collection('variantInventory')
            .doc(_variantIdController.text)
            .set(variant);

        // Add color to product's availableColors if it's not already there
        final colorCode = _colorCodeController.text;
        final updatedColors = List<String>.from(product.availableColors);
        if (!updatedColors.contains(colorCode)) {
          updatedColors.add(colorCode);

          // Update product in Firestore
          await FirebaseFirestore.instance
              .collection('products')
              .doc(product.id)
              .update({'availableColors': updatedColors});

          // Update local product state
          setState(() {
            product = NewProduct(
              id: product.id,
              name: product.name,
              brand: product.brand,
              category: product.category,
              description: product.description,
              createdAt: product.createdAt,
              images: product.images,
              costPrice: product.costPrice,
              sellingPrice: product.sellingPrice,
              discount: product.discount,
              specs: product.specs,
              activated: product.activated,
              availableColors: updatedColors,
              rating: product.rating,
              salesCount: product.salesCount,
              totalReviews: product.totalReviews,
              docSnapshot: product.docSnapshot,
            );
          });
        }

        // Refresh variants
        _fetchVariants();

        setState(() {
          isAddingVariant = false;
          _resetVariantForm();
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Variant added successfully')),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding variant: $e')));
      }
    }
  }

  Future<void> _deleteVariant(String variantId, String colorCode) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Delete variant from Firebase
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .collection('variantInventory')
          .doc(variantId)
          .delete();

      // Check if we need to remove the color from availableColors
      final remainingVariantsWithColor =
          await FirebaseFirestore.instance
              .collection('products')
              .doc(product.id)
              .collection('variantInventory')
              .where('colorCode', isEqualTo: colorCode)
              .get();

      if (remainingVariantsWithColor.docs.isEmpty) {
        // No more variants with this color, remove from availableColors
        final updatedColors = List<String>.from(product.availableColors)
          ..remove(colorCode);

        // Update product in Firestore
        await FirebaseFirestore.instance
            .collection('products')
            .doc(product.id)
            .update({'availableColors': updatedColors});

        // Update local product state
        setState(() {
          product = NewProduct(
            id: product.id,
            name: product.name,
            brand: product.brand,
            category: product.category,
            description: product.description,
            createdAt: product.createdAt,
            images: product.images,
            costPrice: product.costPrice,
            sellingPrice: product.sellingPrice,
            discount: product.discount,
            specs: product.specs,
            activated: product.activated,
            availableColors: updatedColors,
            rating: product.rating,
            salesCount: product.salesCount,
            totalReviews: product.totalReviews,
            docSnapshot: product.docSnapshot,
          );
        });
      }

      // Refresh variants
      _fetchVariants();

      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg: "Variant deleted successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Error deleting variant: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _updateVariantStatus(String variantId, bool newStatus) async {
    try {
      // Update variant status in Firebase
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .collection('variantInventory')
          .doc(variantId)
          .update({'activated': newStatus});

      // Refresh variants
      _fetchVariants();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Variant ${newStatus ? 'activated' : 'deactivated'} successfully',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating variant: $e')));
    }
  }

  // Method to show color picker dialog
  void _showColorPicker() {
    // Parse the current color from the text field or use default white
    Color currentColor = _getColorFromHex(
      _colorCodeController.text.isEmpty ? '#FFFFFF' : _colorCodeController.text,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                currentColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsv,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Select'),
              onPressed: () {
                // Convert the color to hex format and update the controller
                final hexColor = colorToHex(currentColor);
                setState(() {
                  _colorCodeController.text = hexColor;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Product Details'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
            tooltip: isEditing ? 'Cancel Edit' : 'Edit Product',
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProduct,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body:
          _isLoading && !isAddingVariant
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductDetails(),
                      const SizedBox(height: 24),
                      _buildVariantSection(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildProductDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Image Preview
            if (product.images.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.images[0],
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size: 40),
                        ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Product fields
            isEditing ? _buildEditForm() : _buildProductInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('ID', product.id),
        _infoRow('Name', product.name),
        _infoRow('Brand', product.brand),
        _infoRow('Category', product.category),
        _infoRow('Cost Price', FormatHelper.formatCurrency(product.costPrice)),
        _infoRow(
          'Selling Price',
          FormatHelper.formatCurrency(product.sellingPrice),
        ),
        _infoRow('Discount', '${(product.discount * 100).toStringAsFixed(0)}%'),
        _infoRow('Status', product.activated ? 'Active' : 'Inactive'),
        _infoRow(
          'Created At',
          FormatHelper.formatDateTime(product.createdAt.toDate()),
        ),
        _infoRow('Rating', '${product.rating} ★'),
        _infoRow('Sales Count', product.salesCount.toString()),
        _infoRow('Total Reviews', product.totalReviews.toString()),

        const SizedBox(height: 16),
        const Text(
          'Description',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(product.description),

        const SizedBox(height: 16),
        const Text(
          'Available Colors',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              product.availableColors.map((colorCode) {
                return Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _getColorFromHex(colorCode),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(15),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _brandController,
          decoration: const InputDecoration(labelText: 'Brand'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a brand';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _categoryController,
          decoration: const InputDecoration(labelText: 'Category'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a category';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _costPriceController,
          decoration: const InputDecoration(labelText: 'Cost Price'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a cost price';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _sellingPriceController,
          decoration: const InputDecoration(labelText: 'Selling Price'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a selling price';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _discountController,
          decoration: const InputDecoration(
            labelText: 'Discount (0.0 - 1.0)',
            hintText: '0.1 = 10% discount',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null; // Discount can be empty (0)
            }
            final discount = double.tryParse(value);
            if (discount == null) {
              return 'Please enter a valid number';
            }
            if (discount < 0 || discount > 1) {
              return 'Discount must be between 0 and 1';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: product.activated,
              onChanged: (value) {
                setState(() {
                  product = NewProduct(
                    id: product.id,
                    name: product.name,
                    brand: product.brand,
                    category: product.category,
                    description: product.description,
                    createdAt: product.createdAt,
                    images: product.images,
                    costPrice: product.costPrice,
                    sellingPrice: product.sellingPrice,
                    discount: product.discount,
                    specs: product.specs,
                    activated: value ?? true,
                    availableColors: product.availableColors,
                    rating: product.rating,
                    salesCount: product.salesCount,
                    totalReviews: product.totalReviews,
                    docSnapshot: product.docSnapshot,
                  );
                });
              },
            ),
            const Text('Active'),
          ],
        ),
      ],
    );
  }

  Widget _buildVariantSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Product Variants',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (!isAddingVariant)
                  ElevatedButton.icon(
                    onPressed: _toggleAddVariant,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Variant'),
                  ),
              ],
            ),
            const Divider(),

            if (isAddingVariant) _buildAddVariantForm(),

            if (_isLoading && !isAddingVariant)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_variants.isEmpty && !isAddingVariant)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('No variants added yet')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _variants.length,
                itemBuilder: (context, index) {
                  final variant = _variants[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getColorFromHex(
                            variant['colorCode'] ?? '#FFFFFF',
                          ),
                          border: Border.all(color: Colors.grey),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(variant['colorName'] ?? 'Unnamed'),
                      subtitle: Text(
                        'ID: ${variant['variantId']} | Stock: ${variant['inventory']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: variant['activated'] ?? false,
                            onChanged: (value) {
                              _updateVariantStatus(variant['variantId'], value);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteVariant(
                                variant['variantId'],
                                variant['colorCode'],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddVariantForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add New Variant',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _variantIdController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Variant ID',
            hintText: 'Unique identifier for this variant',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a variant ID';
            }
            // Check for duplicate IDs
            for (var variant in _variants) {
              if (variant['variantId'] == value) {
                return 'This Variant ID already exists';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _colorNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Color Name',
                  hintText: 'E.g., Red, Blue, Green',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a color name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _colorCodeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Color Code (HEX)',
                  hintText: '#RRGGBB',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.color_lens),
                    tooltip: 'Pick color',
                    onPressed: _showColorPicker,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a color code';
                  }
                  if (!RegExp(r'^#(?:[0-9a-fA-F]{3}){1,2}$').hasMatch(value)) {
                    return 'Invalid color code';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showColorPicker,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _getColorFromHex(
                    _colorCodeController.text.isEmpty
                        ? '#FFFFFF'
                        : _colorCodeController.text,
                  ),
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _inventoryController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Inventory',
            hintText: 'Number of items in stock',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter inventory';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Checkbox(
              value: _variantActivated,
              onChanged: (value) {
                setState(() {
                  _variantActivated = value ?? true;
                });
              },
            ),
            const Text('Activate this variant'),
          ],
        ),

        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _toggleAddVariant,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _addVariant,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Save Variant'),
            ),
          ],
        ),
      ],
    );
  }

  Color _getColorFromHex(String hexColor) {
    if (hexColor.isEmpty) return Colors.transparent;

    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 3) {
      hexColor =
          "FF${hexColor[0]}${hexColor[0]}${hexColor[1]}${hexColor[1]}${hexColor[2]}${hexColor[2]}";
    }

    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}
