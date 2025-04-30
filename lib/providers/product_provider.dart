import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

final productProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductNotifier();
});

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductNotifier() : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      // TODO: Replace with Firebase data
      final products = [
        Product(
          id: '1',
          name: 'MacBook Pro 14"',
          price: 54999,
          gstRate: 18,
        ),
        Product(
          id: '2',
          name: 'iPhone 15 Pro Max',
          price: 129900,
          gstRate: 18,
        ),
        Product(
          id: '3',
          name: 'iPad Pro 12.9"',
          price: 29990,
          gstRate: 18,
        ),
        Product(
          id: '4',
          name: 'Apple Watch Ultra',
          price: 99990,
          gstRate: 18,
        ),
        Product(
          id: '5',
          name: 'AirPods Pro',
          price: 12990,
          gstRate: 18,
        ),
        Product(
          id: '6',
          name: 'Mac mini',
          price: 24990,
          gstRate: 18,
        ),
        Product(
          id: '7',
          name: 'HomePod mini',
          price: 249990,
          gstRate: 18,
        ),
        Product(
          id: '8',
          name: 'Apple TV 4K',
          price: 2999,
          gstRate: 18,
        ),
        Product(
          id: '9',
          name: 'AirTag',
          price: 7999,
          gstRate: 18,
        ),
        Product(
          id: '10',
          name: 'Magic Keyboard',
          price: 24900,
          gstRate: 18,
        ),
      ];

      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final currentProducts = state.value ?? [];
      state = AsyncValue.data([...currentProducts, product]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final currentProducts = state.value ?? [];
      final index = currentProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        final updatedProducts = [...currentProducts];
        updatedProducts[index] = product;
        state = AsyncValue.data(updatedProducts);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final currentProducts = state.value ?? [];
      state = AsyncValue.data(currentProducts.where((p) => p.id != id).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
} 