import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';

class ProductRepository {
  final CollectionReference _productsRef = FirebaseFirestore.instance
      .collection('products');

  // Get all products
  Future<List<NewProduct>> getAllProducts() async {
    final querySnapshot = await _productsRef.get();
    return querySnapshot.docs.map((doc) {
      return NewProduct.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Get product by ID
  Future<NewProduct?> getProductById(String productId) async {
    final doc = await _productsRef.doc(productId).get();
    if (doc.exists) {
      return NewProduct.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Add a new product
  Future<void> addProduct(NewProduct product) async {
    await _productsRef.doc(product.id).set(product.toMap());
  }

  // Update a product
  Future<void> updateProduct(NewProduct product) async {
    await _productsRef.doc(product.id).update(product.toMap());
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    await _productsRef.doc(productId).delete();
  }

  // Sort products by criteria
  // criteria: 'name_asc', 'name_desc', 'price_asc', 'price_desc'
  Query sortProducts(String criteria) {
    CollectionReference productsRef = FirebaseFirestore.instance.collection(
      'products',
    );

    switch (criteria) {
      case 'name_asc':
        return productsRef.orderBy('name');
      case 'name_desc':
        return productsRef.orderBy('name', descending: true);
      case 'price_asc':
        return productsRef.orderBy('price');
      case 'price_desc':
        return productsRef.orderBy('price', descending: true);
      default:
        return productsRef;
    }
  }
}
