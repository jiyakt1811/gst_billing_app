import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';

class NewBillScreen extends ConsumerStatefulWidget {
  const NewBillScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NewBillScreen> createState() => _NewBillScreenState();
}

class _NewBillScreenState extends ConsumerState<NewBillScreen> {
  final List<BillItem> _items = [];
  final _quantityController = TextEditingController();
  Product? _selectedProduct;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_selectedProduct == null || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product and enter quantity')),
      );
      return;
    }

    setState(() {
      _items.add(
        BillItem(
          product: _selectedProduct!,
          quantity: int.parse(_quantityController.text),
        ),
      );
      _selectedProduct = null;
      _quantityController.clear();
    });
  }

  double _calculateSubtotal() {
    return _items.fold(0, (sum, item) => sum + (item.product.basePrice * item.quantity));
  }

  double _calculateCGST() {
    return _items.fold(0, (sum, item) => sum + (item.product.cgst * item.quantity));
  }

  double _calculateSGST() {
    return _items.fold(0, (sum, item) => sum + (item.product.sgst * item.quantity));
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateCGST() + _calculateSGST();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Bill'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<Product>(
                      value: _selectedProduct,
                      decoration: const InputDecoration(
                        labelText: 'Select Product',
                        border: OutlineInputBorder(),
                      ),
                      items: products.map((product) {
                        return DropdownMenuItem(
                          value: product,
                          child: Text('${product.name} (₹${product.basePrice})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProduct = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Add Item'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(item.product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Qty: ${item.quantity} × ₹${item.product.basePrice}'),
                        Text('GST: ${item.product.gstRate}%'),
                        Text('CGST: ₹${(item.product.cgst * item.quantity).toStringAsFixed(2)}'),
                        Text('SGST: ₹${(item.product.sgst * item.quantity).toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: Text(
                      '₹${(item.product.total * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTotalRow('Subtotal', _calculateSubtotal()),
                  _buildTotalRow('CGST', _calculateCGST()),
                  _buildTotalRow('SGST', _calculateSGST()),
                  const Divider(),
                  _buildTotalRow(
                    'Total',
                    _calculateTotal(),
                    isTotal: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Generate invoice
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Generate Invoice'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class BillItem {
  final Product product;
  final int quantity;

  BillItem({
    required this.product,
    required this.quantity,
  });
} 