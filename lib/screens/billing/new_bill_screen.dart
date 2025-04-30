import 'package:flutter/material.dart';

class NewBillScreen extends StatefulWidget {
  const NewBillScreen({Key? key}) : super(key: key);

  @override
  _NewBillScreenState createState() => _NewBillScreenState();
}

class _NewBillScreenState extends State<NewBillScreen> {
  final List<BillItem> _items = [];
  double _totalAmount = 0;
  double _totalCGST = 0;
  double _totalSGST = 0;
  final _productController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  double _selectedGSTRate = 5;

  void _addItem() {
    if (_productController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final price = double.parse(_priceController.text);
    final quantity = int.parse(_quantityController.text);
    final totalPrice = price * quantity;
    final gstAmount = (totalPrice * _selectedGSTRate) / 100;
    final cgst = gstAmount / 2;
    final sgst = gstAmount / 2;

    setState(() {
      _items.add(
        BillItem(
          name: _productController.text,
          price: price,
          quantity: quantity,
          gstRate: _selectedGSTRate,
          cgst: cgst,
          sgst: sgst,
        ),
      );
      _calculateTotals();
      _clearInputs();
    });
  }

  void _calculateTotals() {
    double total = 0;
    double cgst = 0;
    double sgst = 0;

    for (var item in _items) {
      total += (item.price * item.quantity) + item.cgst + item.sgst;
      cgst += item.cgst;
      sgst += item.sgst;
    }

    setState(() {
      _totalAmount = total;
      _totalCGST = cgst;
      _totalSGST = sgst;
    });
  }

  void _clearInputs() {
    _productController.clear();
    _priceController.clear();
    _quantityController.clear();
    setState(() {
      _selectedGSTRate = 5;
    });
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
                      controller: _productController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              prefixText: '₹',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
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
                  subtitle: Text(
                    'Qty: ${item.quantity} × ₹${item.price.toStringAsFixed(2)}',
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${((item.price * item.quantity) + item.cgst + item.sgst).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'GST: ${item.gstRate}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CGST:'),
                    Text('₹${_totalCGST.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SGST:'),
                    Text('₹${_totalSGST.toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '₹${_totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Generate and save invoice
        },
        backgroundColor: const Color(0xFF1E88E5),
        icon: const Icon(Icons.receipt_long),
        label: const Text('Generate Invoice'),
      ),
    );
  }
}

class BillItem {
  final String name;
  final double price;
  final int quantity;
  final double gstRate;
  final double cgst;
  final double sgst;

  BillItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.gstRate,
    required this.cgst,
    required this.sgst,
  });
} 