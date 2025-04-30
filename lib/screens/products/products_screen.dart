import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _gstController = TextEditingController();
  Product? _editingProduct;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _editProduct(Product product) {
    setState(() {
      _editingProduct = product;
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
      _gstController.text = product.gstRate.toString();
    });
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: _editingProduct?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        price: double.parse(_priceController.text),
        gstRate: double.parse(_gstController.text),
      );

      if (_editingProduct != null) {
        await ref.read(productProvider.notifier).updateProduct(product);
      } else {
        await ref.read(productProvider.notifier).addProduct(product);
      }

      _clearForm();
    }
  }

  void _clearForm() {
    setState(() {
      _editingProduct = null;
      _nameController.clear();
      _priceController.clear();
      _gstController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: productsAsync.when(
        data: (products) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _gstController,
                      decoration: const InputDecoration(
                        labelText: 'GST Rate (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a GST rate';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid GST rate';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveProduct,
                            child: Text(_editingProduct != null ? 'Update' : 'Add'),
                          ),
                        ),
                        if (_editingProduct != null) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _clearForm,
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price: ₹${product.price.toStringAsFixed(2)}'),
                          Text('GST Rate: ${product.gstRate}%'),
                          Text('CGST: ₹${product.cgst.toStringAsFixed(2)}'),
                          Text('SGST: ₹${product.sgst.toStringAsFixed(2)}'),
                          Text('Total: ₹${product.total.toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editProduct(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => ref
                                .read(productProvider.notifier)
                                .deleteProduct(product.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
} 