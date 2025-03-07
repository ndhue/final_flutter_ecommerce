import 'package:final_ecommerce/models/models_export.dart';

Product mockIpad = Product(
  id: "productId2",
  name: "iPad Pro 12.9-inch",
  brand: "Apple",
  category: "Tablets",
  description: "The latest iPad Pro with M2 chip and Liquid Retina display.",
  rating: 4.8,
  salesCount: 250,
  totalReviews: 40,
  images: [
    "https://picsum.photos/250?image=1",
    "https://picsum.photos/250?image=2",
  ],
  activated: true,
  createdAt: DateTime.parse("2025-02-18T10:00:00Z"),
  variants: [
    Variant(
      variantId: "v1",
      name: "128GB Wi-Fi",
      costPrice: 25000000,
      sellingPrice: 27000000,
      discountPrice: 30000000,
      inventory: 10,
      isColor: false,
      discount: 0.2, // 20% discount
      updatedAt: DateTime.parse("2025-02-18T10:00:00Z"),
    ),
    Variant(
      variantId: "v2",
      name: "256GB Wi-Fi + Cellular",
      costPrice: 30000000,
      sellingPrice: 32000000,
      discountPrice: 35000000,
      inventory: 5,
      isColor: false,
      discount: 0.2, // 20% discount
      updatedAt: DateTime.parse("2025-02-18T10:00:00Z"),
    ),
  ],
);

Product mockLaptop = Product(
  id: "productId3",
  name: "Dell XPS 15 Dell XPS 15 Dell XPS 15",
  brand: "Dell",
  category: "Laptops",
  description: "Dell XPS 15 with 12th Gen Intel i7, 16GB RAM, and 512GB SSD.",
  rating: 4.6,
  salesCount: 180,
  totalReviews: 120,
  images: [
    "https://picsum.photos/250?image=2",
    "https://picsum.photos/250?image=3",
  ],
  activated: true,
  createdAt: DateTime.parse("2025-03-01T10:00:00Z"),
  variants: [
    Variant(
      variantId: "v1",
      name: "16GB RAM / 512GB SSD",
      costPrice: 35000000,
      sellingPrice: 37000000,
      discountPrice: 37000000, // No discount
      inventory: 15,
      isColor: false,
      discount: 0.0, // No discount
      updatedAt: DateTime.parse("2025-03-01T10:00:00Z"),
    ),
    Variant(
      variantId: "v2",
      name: "32GB RAM / 1TB SSD",
      costPrice: 45000000,
      sellingPrice: 47000000,
      discountPrice: 47000000, // No discount
      inventory: 8,
      isColor: false,
      discount: 0.0, // No discount
      updatedAt: DateTime.parse("2025-03-01T10:00:00Z"),
    ),
  ],
);

// Product list
List<Product> products = [mockIpad, mockLaptop, mockIpad, mockLaptop];
