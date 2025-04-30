import 'package:flutter/material.dart';

class NewBillScreen extends StatefulWidget {
  const NewBillScreen({Key? key}) : super(key: key);

  @override
  _NewBillScreenState createState() => _NewBillScreenState();
}

class _NewBillScreenState extends State<NewBillScreen> {
  final List<BillItem> _items = [];
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  double _selectedGSTRate = 5;

  void _addItem() {
    if (_productNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _items.add(
        BillItem(
          name: _productNameController.text,
          price: double.parse(_priceController.text),
          quantity: int.parse(_quantityController.text),
          gstRate: _selectedGSTRate,
        ),
      );
      _productNameController.clear();
      _priceController.clear();
      _quantityController.clear();
    });
  }

  double _calculateTotal() {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  double _calculateGST() {
    return _items.fold(0, (sum, item) => sum + item.gstAmount);
  }

  @override
  Widget build(BuildContext context) {
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
                    TextField(
                      controller: _productNameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: '₹',
                        border: OutlineInputBorder(),
                      ),
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
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('Qty: ${item.quantity} × ₹${item.price}'),
                  trailing: Text(
                    '₹${item.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                  _buildTotalRow('Subtotal', _calculateTotal() - _calculateGST()),
                  _buildTotalRow('GST', _calculateGST()),
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
  final String name;
  final double price;
  final int quantity;
  final double gstRate;

  BillItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.gstRate,
  });

  double get total => (price * quantity) + gstAmount;
  double get gstAmount => (price * quantity) * (gstRate / 100);
} 