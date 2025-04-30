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
  double _selectedGSTRate = 5;
  Product? _editingProduct;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _showProductForm([Product? product]) {
    _editingProduct = product;
    if (product != null) {
      _nameController.text = product.name;
      _priceController.text = product.basePrice.toString();
      _selectedGSTRate = product.gstRate;
    } else {
      _nameController.clear();
      _priceController.clear();
      _selectedGSTRate = 5;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _editingProduct == null ? 'Add Product' : 'Edit Product',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Base Price',
                    prefixText: '₹',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<double>(
                  value: _selectedGSTRate,
                  decoration: const InputDecoration(
                    labelText: 'GST Rate',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5%')),
                    DropdownMenuItem(value: 12, child: Text('12%')),
                    DropdownMenuItem(value: 18, child: Text('18%')),
                    DropdownMenuItem(value: 28, child: Text('28%')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGSTRate = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final product = Product(
                        id: _editingProduct?.id ?? DateTime.now().toString(),
                        name: _nameController.text,
                        basePrice: double.parse(_priceController.text),
                        gstRate: _selectedGSTRate,
                      );

                      if (_editingProduct == null) {
                        ref.read(productProvider.notifier).addProduct(product);
                      } else {
                        ref.read(productProvider.notifier).updateProduct(product);
                      }

                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(_editingProduct == null ? 'Add Product' : 'Update Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1E88E5),
                child: Text(
                  product.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Base Price: ₹${product.basePrice.toStringAsFixed(2)}'),
                  Text('GST Rate: ${product.gstRate}%'),
                  Text('Total: ₹${product.total.toStringAsFixed(2)}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF1E88E5)),
                    onPressed: () => _showProductForm(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Product'),
                          content: Text('Are you sure you want to delete ${product.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(productProvider.notifier).deleteProduct(product.id);
                                Navigator.pop(context);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.add),
      ),
    );
  }
} 