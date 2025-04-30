import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super(_initialProducts);

  static final List<Product> _initialProducts = [
    Product(
      id: '1',
      name: 'Samsung 55" QLED Smart TV',
      basePrice: 54999,
      gstRate: 28,
    ),
    Product(
      id: '2',
      name: 'Apple iPhone 15 Pro',
      basePrice: 129900,
      gstRate: 18,
    ),
    Product(
      id: '3',
      name: 'Sony WH-1000XM5 Headphones',
      basePrice: 29990,
      gstRate: 18,
    ),
    Product(
      id: '4',
      name: 'Dell XPS 13 Laptop',
      basePrice: 99990,
      gstRate: 18,
    ),
    Product(
      id: '5',
      name: 'Bose SoundLink Speaker',
      basePrice: 12990,
      gstRate: 18,
    ),
    Product(
      id: '6',
      name: 'LG 8kg Washing Machine',
      basePrice: 24990,
      gstRate: 28,
    ),
    Product(
      id: '7',
      name: 'Canon EOS R5 Camera',
      basePrice: 249990,
      gstRate: 18,
    ),
    Product(
      id: '8',
      name: 'Samsung 256GB SSD',
      basePrice: 2999,
      gstRate: 18,
    ),
    Product(
      id: '9',
      name: 'Logitech MX Master Mouse',
      basePrice: 7999,
      gstRate: 18,
    ),
    Product(
      id: '10',
      name: 'Apple AirPods Pro',
      basePrice: 24900,
      gstRate: 18,
    ),
  ];

  void addProduct(Product product) {
    state = [...state, product];
  }

  void updateProduct(Product product) {
    state = state.map((p) => p.id == product.id ? product : p).toList();
  }

  void deleteProduct(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  Product? getProductById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
} 