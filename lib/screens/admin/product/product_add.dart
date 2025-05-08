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
    debugPrint("Uploading ${selectedImages.length} images to Cloudinary...");
    for (var image in selectedImages) {
      final url = await CloudinaryService.uploadImage(image);
      if (url != null) {
        urls.add(url);
      }
    }

    debugPrint("Uploaded ${urls.length} images to Cloudinary");
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

        debugPrint("Adding product");

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Product"),
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
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child:
                  isWide
                      ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildProductInfoSection()),
                          const SizedBox(width: 24),
                          Expanded(flex: 1, child: _buildImagesSection()),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductInfoSection(),
                          const SizedBox(height: 20),
                          _buildImagesSection(),
                        ],
                      ),
            ),
          );
        },
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitProduct,
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
      ],
    );
  }

  Widget _buildProductInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Product Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: idController,
            decoration: const InputDecoration(
              labelText: "Product ID*",
              hintText: "Enter a unique product ID",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a product ID";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Product Name*",
              hintText: "Enter product name",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a product name";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
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
          const SizedBox(height: 16),
          Row(
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
                    if (double.tryParse(value) == null) {
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
                    if (double.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: discountController,
            decoration: const InputDecoration(
              labelText: "Discount (0.0 - 1.0)",
              hintText: "0.1 = 10% discount",
              border: OutlineInputBorder(),
            ),
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
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: "Description*",
              hintText: "Enter product description",
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a description";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: isActivated,
                onChanged: (val) => setState(() => isActivated = val!),
              ),
              const Text("Activate this product"),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "* Note: Variants can be added after creating the product",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Product Images",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),

          // Show selected image previews
          if (previewImages.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(previewImages.length, (index) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImagePreview(previewImages[index]),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),

          // Show existing image URLs
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      imageUrls[index],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stack) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image),
                          ),
                    ),
                  ),
                  title: Text(
                    imageUrls[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeImageUrl(index),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Text field for manual URL entry
          TextField(
            decoration: const InputDecoration(
              labelText: "Add Image URL",
              hintText: "Enter image URL and press +",
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.image),
            ),
            onSubmitted: _addImageUrl,
          ),
          const SizedBox(height: 8),
          // Button to pick images from device
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text("Select Images"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Manual URL entry button
          ElevatedButton.icon(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (imageUrls.isEmpty && previewImages.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Icon(Icons.image, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    "No images added yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(dynamic image) {
    if (kIsWeb) {
      if (image is XFile) {
        return FutureBuilder<Uint8List>(
          future: image.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              );
            } else {
              return Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade300,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
          },
        );
      } else {
        return Image.memory(
          image as Uint8List,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      }
    } else {
      return Image.file(
        image as File,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }
}
