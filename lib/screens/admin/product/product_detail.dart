import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/new_product_model.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AdminProductDetailScreen extends StatefulWidget {
  final NewProduct product;
  final int initialTab;

  const AdminProductDetailScreen({
    super.key,
    required this.product,
    this.initialTab = 0,
  });

  @override
  State<AdminProductDetailScreen> createState() =>
      _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late NewProduct product;
  bool isEditing = false;
  bool isAddingVariant = false;
  bool _isLoading = false;
  List<dynamic> _variants = [];
  int _currentImageIndex = 0;

  // Tab controller
  late TabController _tabController;

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

    // Initialize tab controller
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
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
    _tabController.dispose();
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
        // Get variant provider
        final variantProvider = Provider.of<VariantProvider>(
          context,
          listen: false,
        );

        // Add variant through provider
        await variantProvider.addVariant(
          productId: product.id,
          variantId: _variantIdController.text,
          colorName: _colorNameController.text,
          colorCode: _colorCodeController.text,
          inventory: int.tryParse(_inventoryController.text) ?? 0,
          activated: _variantActivated,
        );

        // Get updated product
        final productProvider = Provider.of<ProductProvider>(
          context,
          listen: false,
        );

        final updatedProduct = await productProvider.fetchProductById(
          product.id,
        );

        // Update local product state
        setState(() {
          product = updatedProduct;
          isAddingVariant = false;
          _resetVariantForm();
          _isLoading = false;
        });

        // Refresh variants
        _fetchVariants();

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

      // Use the variant provider to delete the variant
      final variantProvider = Provider.of<VariantProvider>(
        context,
        listen: false,
      );

      await variantProvider.deleteVariant(
        productId: product.id,
        variantId: variantId,
        colorCode: colorCode,
      );

      // Check if the color was removed from the product
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      final updatedProduct = await productProvider.fetchProductById(product.id);

      // Update local product state with new availableColors
      setState(() {
        product = updatedProduct;
        _isLoading = false;
      });

      // Refresh variants
      _fetchVariants();

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

  void _previousImage() {
    if (_currentImageIndex > 0) {
      setState(() {
        _currentImageIndex--;
      });
    }
  }

  void _nextImage() {
    if (_currentImageIndex < product.images.length - 1) {
      setState(() {
        _currentImageIndex++;
      });
    }
  }

  // Check if the screen is large
  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }

  // Check if the screen is medium
  bool _isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 800 && width <= 1200;
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = _isLargeScreen(context);
    final bool isMediumScreen = _isMediumScreen(context);

    return Scaffold(
      appBar: AppBar(
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Details'),
            Tab(icon: Icon(Icons.edit), text: 'Edit'),
            Tab(icon: Icon(Icons.color_lens), text: 'Variants'),
          ],
          onTap: (index) {
            // Set editing mode based on tab
            setState(() {
              isEditing = index == 1;
            });
          },
        ),
      ),
      body:
          _isLoading && !isAddingVariant
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  // Details tab
                  _buildDetailsTab(isLargeScreen, isMediumScreen),

                  // Edit tab
                  _buildEditTab(isLargeScreen, isMediumScreen),

                  // Variants tab
                  _buildVariantsTab(isLargeScreen, isMediumScreen),
                ],
              ),
    );
  }

  Widget _buildDetailsTab(bool isLargeScreen, bool isMediumScreen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child:
          isLargeScreen
              ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image gallery section
                  Expanded(flex: 4, child: _buildImageGallery(isLargeScreen)),
                  const SizedBox(width: 24),
                  // Product info section
                  Expanded(
                    flex: 6,
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Product Information',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildProductInfo(isLargeScreen),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image gallery
                  _buildImageGallery(isLargeScreen),
                  const SizedBox(height: 24),

                  // Product details
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildProductInfo(isLargeScreen),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildEditTab(bool isLargeScreen, bool isMediumScreen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child:
            isLargeScreen
                ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image gallery section
                    Expanded(flex: 4, child: _buildImageGallery(isLargeScreen)),
                    const SizedBox(width: 24),
                    // Edit form section
                    Expanded(
                      flex: 6,
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Edit Product',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 16),
                              _buildEditForm(isLargeScreen),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: _toggleEdit,
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: _saveProduct,
                                    child: const Text('Save Changes'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image gallery
                    _buildImageGallery(isLargeScreen),
                    const SizedBox(height: 24),

                    // Edit form
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit Product',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildEditForm(isLargeScreen),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: _toggleEdit,
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _saveProduct,
                                  child: const Text('Save Changes'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildVariantsTab(bool isLargeScreen, bool isMediumScreen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Product Variants',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 24 : 18,
                            fontWeight: FontWeight.bold,
                          ),
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

                    if (isAddingVariant)
                      isLargeScreen
                          ? _buildLargeScreenVariantForm()
                          : _buildAddVariantForm(),

                    if (_isLoading && !isAddingVariant)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_variants.isEmpty && !isAddingVariant)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 48.0),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.color_lens_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No variants added yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _toggleAddVariant,
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Variant'),
                            ),
                          ],
                        ),
                      )
                    else if (!isAddingVariant)
                      isLargeScreen
                          ? _buildLargeScreenVariantList()
                          : _buildVariantList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeScreenVariantList() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: DataTable(
        columnSpacing: 30,
        columns: const [
          DataColumn(label: Text('Color')),
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Color Name')),
          DataColumn(label: Text('Inventory')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows:
            _variants.map<DataRow>((variant) {
              return DataRow(
                cells: [
                  DataCell(
                    Container(
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
                  ),
                  DataCell(Text(variant['variantId'] ?? 'No ID')),
                  DataCell(Text(variant['colorName'] ?? 'Unnamed')),
                  DataCell(Text('${variant['inventory'] ?? 0}')),
                  DataCell(
                    Switch(
                      value: variant['activated'] ?? false,
                      onChanged: (value) {
                        _updateVariantStatus(variant['variantId'], value);
                      },
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Implement edit variant functionality
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
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildVariantList() {
    return ListView.builder(
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
                color: _getColorFromHex(variant['colorCode'] ?? '#FFFFFF'),
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
                    _deleteVariant(variant['variantId'], variant['colorCode']);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLargeScreenVariantForm() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Variant',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First column - Variant ID & Inventory
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Second column - Color fields
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
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
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              if (!RegExp(
                                r'^#(?:[0-9a-fA-F]{3}){1,2}$',
                              ).hasMatch(value)) {
                                return 'Invalid color code';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: _showColorPicker,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getColorFromHex(
                                _colorCodeController.text.isEmpty
                                    ? '#FFFFFF'
                                    : _colorCodeController.text,
                              ),
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'The color will be added to the product\'s available colors',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
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
            if (int.parse(value) < 0) {
              return 'Inventory cannot be negative';
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

  Widget _buildImageGallery(bool isLargeScreen) {
    if (product.images.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLargeScreen) ...[
              const Text(
                'Product Images',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ],
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Image.network(
                    product.images[_currentImageIndex],
                    height: isLargeScreen ? 400 : 250,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: isLargeScreen ? 400 : 250,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: isLargeScreen ? 400 : 250,
                          height: isLargeScreen ? 400 : 250,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                  ),
                ),
                if (product.images.length > 1) ...[
                  Positioned(
                    left: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed:
                            _currentImageIndex > 0 ? _previousImage : null,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                        onPressed:
                            _currentImageIndex < product.images.length - 1
                                ? _nextImage
                                : null,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (product.images.length > 1) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: product.images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                _currentImageIndex == index
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            product.images[index],
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 20,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLargeScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('ID', product.id),
                    _infoRow('Name', product.name),
                    _infoRow('Brand', product.brand),
                    _infoRow('Category', product.category),
                    _infoRow(
                      'Cost Price',
                      FormatHelper.formatCurrency(product.costPrice),
                    ),
                    _infoRow(
                      'Selling Price',
                      FormatHelper.formatCurrency(product.sellingPrice),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(
                      'Discount',
                      '${(product.discount * 100).toStringAsFixed(0)}%',
                    ),
                    _infoRow(
                      'Status',
                      product.activated ? 'Active' : 'Inactive',
                    ),
                    _infoRow(
                      'Created At',
                      FormatHelper.formatDateTime(product.createdAt.toDate()),
                    ),
                    _infoRow('Rating', '${product.rating} ★'),
                    _infoRow('Sales Count', product.salesCount.toString()),
                    _infoRow('Total Reviews', product.totalReviews.toString()),
                  ],
                ),
              ),
            ],
          )
        else ...[
          _infoRow('ID', product.id),
          _infoRow('Name', product.name),
          _infoRow('Brand', product.brand),
          _infoRow('Category', product.category),
          _infoRow(
            'Cost Price',
            FormatHelper.formatCurrency(product.costPrice),
          ),
          _infoRow(
            'Selling Price',
            FormatHelper.formatCurrency(product.sellingPrice),
          ),
          _infoRow(
            'Discount',
            '${(product.discount * 100).toStringAsFixed(0)}%',
          ),
          _infoRow('Status', product.activated ? 'Active' : 'Inactive'),
          _infoRow(
            'Created At',
            FormatHelper.formatDateTime(product.createdAt.toDate()),
          ),
          _infoRow('Rating', '${product.rating} ★'),
          _infoRow('Sales Count', product.salesCount.toString()),
          _infoRow('Total Reviews', product.totalReviews.toString()),
        ],
        const SizedBox(height: 24),
        const Text(
          'Description',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(product.description),
        ),
        const SizedBox(height: 24),
        const Text(
          'Available Colors',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              product.availableColors.map((colorCode) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getColorFromHex(colorCode),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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
          Expanded(child: Text(value, style: const TextStyle(height: 1.3))),
        ],
      ),
    );
  }

  Widget _buildEditForm(bool isLargeScreen) {
    return isLargeScreen
        ? Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First column
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
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
                        decoration: const InputDecoration(
                          labelText: 'Brand',
                          border: OutlineInputBorder(),
                        ),
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
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Second column
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _costPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Cost Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter cost price";
                          }
                          if (double.tryParse(value) == null ||
                              double.tryParse(value)! <= 0) {
                            return "Please enter a valid number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _sellingPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Selling Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter selling price";
                          }
                          if (double.tryParse(value) == null ||
                              double.tryParse(value)! <= 0) {
                            return "Please enter a valid number";
                          }
                          final sellingPrice = double.tryParse(value);
                          final costPrice = double.tryParse(
                            _costPriceController.text,
                          );
                          if (sellingPrice != null &&
                              costPrice != null &&
                              sellingPrice <= costPrice) {
                            return "Selling price must be greater than cost price";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _discountController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
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
        )
        : Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
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
              decoration: const InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(),
              ),
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
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
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
              decoration: const InputDecoration(
                labelText: 'Cost Price',
                border: OutlineInputBorder(),
              ),
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
              decoration: const InputDecoration(
                labelText: 'Selling Price',
                border: OutlineInputBorder(),
              ),
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
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
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
