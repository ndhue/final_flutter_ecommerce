import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/new_product_model.dart';
import 'package:final_ecommerce/providers/product_provider.dart';
import 'package:final_ecommerce/services/cloudinary_service.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Text controllers
  final idController = TextEditingController();
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();
  final costPriceController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final discountController = TextEditingController(text: "0.0");

  List<String> imageUrls = [];
  List<XFile> selectedImages = [];
  List<dynamic> previewImages =
      []; // Will contain XFile, File or Uint8List for preview
  bool isActivated = true;

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    brandController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    costPriceController.dispose();
    sellingPriceController.dispose();
    discountController.dispose();
    super.dispose();
  }

  void _addImageUrl(String url) {
    if (url.isNotEmpty) {
      setState(() {
        imageUrls.add(url);
      });
    }
  }

  void _removeImageUrl(int index) {
    setState(() {
      imageUrls.removeAt(index);
    });
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isEmpty) return;

    setState(() {
      selectedImages.addAll(pickedFiles);

      for (var file in pickedFiles) {
        if (kIsWeb) {
          previewImages.add(file);
        } else {
          previewImages.add(File(file.path));
        }
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
      previewImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImagesToCloudinary() async {
    List<String> urls = [];
    for (var image in selectedImages) {
      final url = await CloudinaryService.uploadImage(image);
      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }

  void _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final productProvider = Provider.of<ProductProvider>(
          context,
          listen: false,
        );

        // Upload images to Cloudinary and get URLs
        List<String> uploadedImageUrls = [];
        if (selectedImages.isNotEmpty) {
          uploadedImageUrls = await _uploadImagesToCloudinary();
        }

        // Combine existing URLs and newly uploaded URLs
        final allImageUrls = [...imageUrls, ...uploadedImageUrls];

        final newProduct = NewProduct(
          id: idController.text.trim(),
          name: nameController.text.trim(),
          brand: brandController.text.trim(),
          category: categoryController.text.trim(),
          description: descriptionController.text.trim(),
          createdAt: Timestamp.now(),
          images: allImageUrls,
          costPrice: double.tryParse(costPriceController.text.trim()) ?? 0,
          sellingPrice:
              double.tryParse(sellingPriceController.text.trim()) ?? 0,
          discount: double.tryParse(discountController.text.trim()) ?? 0,
          activated: isActivated,
          availableColors: [],
        );

        await productProvider.addProduct(newProduct);

        Fluttertoast.showToast(
          msg: "Product added successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error adding product: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting ? null : _submitProduct,
            icon:
                _isSubmitting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.save),
            label: const Text("SAVE"),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isLargeScreen ? 32 : 16),
            child: Form(
              key: _formKey,
              child:
                  isWide
                      ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // For large screens, give the product info section more space
                          Expanded(
                            flex: isLargeScreen ? 3 : 2,
                            child: _buildProductInfoSection(isLargeScreen),
                          ),
                          SizedBox(width: isLargeScreen ? 32 : 24),
                          // Images section takes less space proportionally
                          Expanded(
                            flex: isLargeScreen ? 2 : 1,
                            child: _buildImagesSection(isLargeScreen),
                          ),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductInfoSection(false),
                          const SizedBox(height: 20),
                          _buildImagesSection(false),
                        ],
                      ),
            ),
          );
        },
      ),
      persistentFooterButtons: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 24 : 0),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: TextStyle(fontSize: isLargeScreen ? 16 : 14),
                ),
                child: const Text("Cancel"),
              ),
              SizedBox(width: isLargeScreen ? 24 : 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  textStyle: TextStyle(fontSize: isLargeScreen ? 16 : 14),
                ),
                child:
                    _isSubmitting
                        ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text("Saving..."),
                          ],
                        )
                        : const Text("Save Product"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfoSection(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 8),
        boxShadow:
            isLargeScreen
                ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isLargeScreen ? 22 : 18,
            ),
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),

          // Form fields have larger spacing on bigger screens
          TextFormField(
            controller: idController,
            decoration: const InputDecoration(
              labelText: "Product ID*",
              hintText: "Enter a unique product ID",
              border: OutlineInputBorder(),
            ),
            style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a product ID";
              }
              return null;
            },
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),

          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Product Name*",
              hintText: "Enter product name",
              border: OutlineInputBorder(),
            ),
            style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a product name";
              }
              return null;
            },
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),

          // On large screens, consider a more spacious layout
          isLargeScreen
              ? Column(
                children: [
                  DropdownButtonFormField<String>(
                    value:
                        brandController.text.isEmpty
                            ? null
                            : brandController.text,
                    decoration: const InputDecoration(
                      labelText: "Brand*",
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 16),
                    items:
                        brandList.map((String brand) {
                          return DropdownMenuItem<String>(
                            value: brand,
                            child: Text(brand),
                          );
                        }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select a brand";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value != null) {
                        brandController.text = value;
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value:
                        categoryController.text.isEmpty
                            ? null
                            : categoryController.text,
                    decoration: const InputDecoration(
                      labelText: "Category*",
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 16),
                    items:
                        categoryList.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select a category";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value != null) {
                        categoryController.text = value;
                      }
                    },
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          brandController.text.isEmpty
                              ? null
                              : brandController.text,
                      decoration: const InputDecoration(
                        labelText: "Brand*",
                        border: OutlineInputBorder(),
                      ),
                      items:
                          brandList.map((String brand) {
                            return DropdownMenuItem<String>(
                              value: brand,
                              child: Text(brand),
                            );
                          }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a brand";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value != null) {
                          brandController.text = value;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          categoryController.text.isEmpty
                              ? null
                              : categoryController.text,
                      decoration: const InputDecoration(
                        labelText: "Category*",
                        border: OutlineInputBorder(),
                      ),
                      items:
                          categoryList.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a category";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value != null) {
                          categoryController.text = value;
                        }
                      },
                    ),
                  ),
                ],
              ),
          SizedBox(height: isLargeScreen ? 24 : 16),

          // Price fields - same layout pattern as brand/category
          isLargeScreen
              ? Column(
                children: [
                  TextFormField(
                    controller: costPriceController,
                    decoration: const InputDecoration(
                      labelText: "Cost Price*",
                      hintText: "Enter cost price",
                      border: OutlineInputBorder(),
                      suffixText: "đ",
                    ),
                    style: const TextStyle(fontSize: 16),
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
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: sellingPriceController,
                    decoration: const InputDecoration(
                      labelText: "Selling Price*",
                      hintText: "Enter selling price",
                      border: OutlineInputBorder(),
                      suffixText: "đ",
                    ),
                    style: const TextStyle(fontSize: 16),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter selling price";
                      }
                      if (double.tryParse(value) == null ||
                          double.tryParse(value)! <= 0) {
                        return "Please enter a valid number";
                      }
                      if (costPriceController.text.isEmpty) {
                        return "Please enter cost price first";
                      }
                      final sellingPrice = double.tryParse(value);
                      final costPrice = double.tryParse(
                        costPriceController.text,
                      );
                      if (sellingPrice != null &&
                          costPrice != null &&
                          sellingPrice <= costPrice) {
                        return "Selling price must be greater than cost price";
                      }
                      return null;
                    },
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: costPriceController,
                      decoration: const InputDecoration(
                        labelText: "Cost Price*",
                        hintText: "Enter cost price",
                        border: OutlineInputBorder(),
                        suffixText: "đ",
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: sellingPriceController,
                      decoration: const InputDecoration(
                        labelText: "Selling Price*",
                        hintText: "Enter selling price",
                        border: OutlineInputBorder(),
                        suffixText: "đ",
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
                        if (costPriceController.text.isEmpty) {
                          return "Please enter cost price first";
                        }
                        final sellingPrice = double.tryParse(value);
                        final costPrice = double.tryParse(
                          costPriceController.text,
                        );
                        if (sellingPrice != null &&
                            costPrice != null &&
                            sellingPrice <= costPrice) {
                          return "Selling price must be greater than cost price";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
          SizedBox(height: isLargeScreen ? 24 : 16),

          TextFormField(
            controller: discountController,
            decoration: const InputDecoration(
              labelText: "Discount (0.0 - 1.0)",
              hintText: "0.1 = 10% discount",
              border: OutlineInputBorder(),
            ),
            style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null; // Discount can be null
              }
              final discount = double.tryParse(value);
              if (discount == null) {
                return "Please enter a valid number";
              }
              if (discount < 0 || discount > 1) {
                return "Discount must be between 0 and 1";
              }
              return null;
            },
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),

          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: "Description*",
              hintText: "Enter product description",
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
            maxLines: isLargeScreen ? 8 : 5, // More lines on large screens
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a description";
              }
              return null;
            },
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),

          Row(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  checkboxTheme: CheckboxThemeData(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                child: Checkbox(
                  value: isActivated,
                  onChanged: (val) => setState(() => isActivated = val!),
                ),
              ),
              Text(
                "Activate this product",
                style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 16 : 8),

          Text(
            "* Note: Variants can be added after creating the product",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
              fontSize: isLargeScreen ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 8),
        boxShadow:
            isLargeScreen
                ? [
                  BoxShadow(
                    color: Colors.grey.withAlpha(10),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Product Images",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 22 : 18,
                ),
              ),
              if (previewImages.length > 3)
                TextButton(
                  onPressed: () => _showAllImagesDialog(),
                  child: Text(
                    "View All (${previewImages.length})",
                    style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
                  ),
                ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),

          // Show selected image previews in a grid on large screens
          if (previewImages.isNotEmpty)
            isLargeScreen
                ? _buildLargeScreenImagePreviews()
                : _buildSmallScreenImagePreviews(),

          if (imageUrls.isNotEmpty) SizedBox(height: isLargeScreen ? 24 : 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.only(bottom: isLargeScreen ? 12 : 8),
                elevation: isLargeScreen ? 2 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isLargeScreen ? 8 : 4),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 16 : 12,
                    vertical: isLargeScreen ? 8 : 4,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(isLargeScreen ? 8 : 4),
                    child: Image.network(
                      imageUrls[index],
                      width: isLargeScreen ? 80 : 60,
                      height: isLargeScreen ? 80 : 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stack) => Container(
                            width: isLargeScreen ? 80 : 60,
                            height: isLargeScreen ? 80 : 60,
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.broken_image,
                              size: isLargeScreen ? 32 : 24,
                            ),
                          ),
                    ),
                  ),
                  title: Text(
                    imageUrls[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: isLargeScreen ? 15 : 14),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: isLargeScreen ? 24 : 20,
                    ),
                    onPressed: () => _removeImageUrl(index),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),

          TextField(
            decoration: InputDecoration(
              labelText: "Add Image URL",
              hintText: "Enter image URL and press +",
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.image),
              contentPadding: EdgeInsets.all(isLargeScreen ? 16 : 12),
            ),
            style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
            onSubmitted: _addImageUrl,
          ),
          SizedBox(height: isLargeScreen ? 16 : 8),

          isLargeScreen
              ? Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text("Select Images"),
                    ),
                  ),
                ],
              )
              : ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text("Select Images"),
              ),
          SizedBox(height: isLargeScreen ? 16 : 8),

          isLargeScreen
              ? Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final controller = TextEditingController();
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("Add Image URL"),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    hintText: "Enter image URL",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _addImageUrl(controller.text.trim());
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Add"),
                                  ),
                                ],
                              ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Image URL"),
                    ),
                  ),
                ],
              )
              : ElevatedButton.icon(
                onPressed: () {
                  final controller = TextEditingController();
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Add Image URL"),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: "Enter image URL",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _addImageUrl(controller.text.trim());
                                Navigator.pop(context);
                              },
                              child: const Text("Add"),
                            ),
                          ],
                        ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Image URL"),
              ),
          SizedBox(height: isLargeScreen ? 24 : 16),

          if (imageUrls.isEmpty && previewImages.isEmpty)
            Container(
              padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.image,
                    size: isLargeScreen ? 64 : 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: isLargeScreen ? 12 : 8),
                  Text(
                    "No images added yet",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isLargeScreen ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLargeScreenImagePreviews() {
    final displayCount = previewImages.length > 3 ? 3 : previewImages.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        if (index == 2 && previewImages.length > 3) {
          return GestureDetector(
            onTap: () => _showAllImagesDialog(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImagePreview(
                    previewImages[index],
                    isGridView: true,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Text(
                        "+${previewImages.length - 2}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GestureDetector(
                onTap: () => _showImagePreview(index),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildImagePreview(
                    previewImages[index],
                    isGridView: true,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmallScreenImagePreviews() {
    final displayCount = previewImages.length > 3 ? 3 : previewImages.length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(displayCount, (index) {
        if (index == 2 && previewImages.length > 3) {
          return GestureDetector(
            onTap: () => _showAllImagesDialog(),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: _buildImagePreview(previewImages[index]),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Text(
                        "+${previewImages.length - 2}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GestureDetector(
                onTap: () => _showImagePreview(index),
                child: _buildImagePreview(previewImages[index]),
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showAllImagesDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "All Images",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: previewImages.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                _showImagePreview(index);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildImagePreview(
                                  previewImages[index],
                                  isGridView: true,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  _removeImage(index);
                                  if (previewImages.isEmpty) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showImagePreview(int index) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Image ${index + 1} of ${previewImages.length}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _removeImage(index);
                              Navigator.of(context).pop();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                    maxWidth: double.infinity,
                  ),
                  child: _buildLargeImagePreview(previewImages[index]),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (index > 0)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showImagePreview(index - 1);
                        },
                        child: const Icon(Icons.arrow_back),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    const SizedBox(width: 16),
                    if (index < previewImages.length - 1)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showImagePreview(index + 1);
                        },
                        child: const Icon(Icons.arrow_forward),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildLargeImagePreview(dynamic image) {
    if (kIsWeb) {
      if (image is XFile) {
        return FutureBuilder<Uint8List>(
          future: image.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return Image.memory(snapshot.data!, fit: BoxFit.contain);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      } else {
        return Image.memory(image as Uint8List, fit: BoxFit.contain);
      }
    } else {
      return Image.file(image as File, fit: BoxFit.contain);
    }
  }

  Widget _buildImagePreview(dynamic image, {bool isGridView = false}) {
    final double width = isGridView ? double.infinity : 100;
    final double height = isGridView ? double.infinity : 100;
    final BoxFit fit = isGridView ? BoxFit.cover : BoxFit.cover;

    if (kIsWeb) {
      if (image is XFile) {
        return FutureBuilder<Uint8List>(
          future: image.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                width: width,
                height: height,
                fit: fit,
              );
            } else {
              return Container(
                width: width,
                height: height,
                color: Colors.grey.shade300,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
          },
        );
      } else {
        return Image.memory(
          image as Uint8List,
          width: width,
          height: height,
          fit: fit,
        );
      }
    } else {
      return Image.file(image as File, width: width, height: height, fit: fit);
    }
  }
}
