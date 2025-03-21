import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

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
      inventory: 8,
      isColor: false,
      discount: 0.0, // No discount
      updatedAt: DateTime.parse("2025-03-01T10:00:00Z"),
    ),
  ],
);

// Product list
List<Product> products = [mockIpad, mockLaptop, mockIpad, mockLaptop];

// Categories
List<Category> categories = [
  Category(
    id: '1',
    name: 'Desktops',
    description: "High-performance desktop PCs for gaming and work.",
    image: "desktop.png",
  ),
  Category(
    id: '2',
    name: 'Laptops',
    description: "Powerful and portable laptops for every need.",
    image: "laptop.png",
  ),
  Category(
    id: '3',
    name: 'Monitors',
    description: "HD and 4K monitors for work and gaming.",
    image: "monitor.png",
  ),
  Category(
    id: '4',
    name: 'Speakers',
    description: "Gaming headsets, wireless speakers, and audio accessories.",
    image: "speaker.png",
  ),
  Category(
    id: '5',
    name: 'Keyboards',
    description: "Mechanical, membrane, and wireless keyboards.",
    image: "keyboard.png",
  ),
  Category(
    id: '6',
    name: 'Headphones',
    description: "Wireless and wired headphones with great sound quality.",
    image: "music.png",
  ),
];

List<Category> specialCategories = [
  Category(
    id: '2',
    name: "New Products",
    icon: const Icon(
      Icons.fiber_new,
      color: primaryColor,
      size: 40,
    ), // "New" label icon for newly released products
    description: "Check out the latest additions to our store.",
  ),
  Category(
    id: '1',
    name: "Promotional",
    icon: const Icon(
      Icons.local_offer,
      color: Colors.red,
      size: 40,
    ), // Tag icon representing discounts and promotions
    description: "Exclusive deals and limited-time offers available here.",
  ),
  Category(
    id: '3',
    name: "Best Sellers",
    icon: const Icon(
      Icons.star,
      color: Colors.amber,
      size: 40,
    ), // Star icon representing popular and top-rated products
    description: "Discover the most popular and highly rated products.",
  ),
];
