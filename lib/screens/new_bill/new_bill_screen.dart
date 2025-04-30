import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/invoice.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/product_provider.dart';

class NewBillScreen extends ConsumerStatefulWidget {
  const NewBillScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NewBillScreen> createState() => _NewBillScreenState();
}

class _NewBillScreenState extends ConsumerState<NewBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  List<InvoiceItem> _selectedItems = [];
  double _subtotal = 0;
  double _totalGst = 0;
  double _totalPayable = 0;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  void _updateTotals() {
    setState(() {
      _subtotal = _selectedItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
      _totalGst = _selectedItems.fold(0, (sum, item) => sum + item.gstAmount);
      _totalPayable = _subtotal + _totalGst;
    });
  }

  Future<void> _generateInvoice() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    final invoice = Invoice(
      id: const Uuid().v4(),
      date: DateTime.now(),
      items: _selectedItems,
      subtotal: _subtotal,
      totalGst: _totalGst,
      totalPayable: _totalPayable,
      customerName: _customerNameController.text,
      customerPhone: _customerPhoneController.text,
    );

    try {
      await ref.read(invoiceProvider.notifier).addInvoice(invoice);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice generated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating invoice: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _generateInvoice,
          ),
        ],
      ),
      body: productsAsync.when(
        data: (productList) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customerPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Add Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...productList.map((product) {
                  final existingItem = _selectedItems.firstWhere(
                    (item) => item.product.id == product.id,
                    orElse: () => InvoiceItem(
                      product: product,
                      quantity: 0,
                      price: product.price,
                      gstAmount: 0,
                    ),
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('₹${product.price.toStringAsFixed(2)}'),
                                Text('GST: ${product.gstRate}%'),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: existingItem.quantity > 0
                                    ? () {
                                        setState(() {
                                          final index = _selectedItems
                                              .indexWhere((item) => item.product.id == product.id);
                                          if (index != -1) {
                                            _selectedItems[index] = InvoiceItem(
                                              product: product,
                                              quantity: existingItem.quantity - 1,
                                              price: product.price,
                                              gstAmount: (product.price * (product.gstRate / 100)) *
                                                  (existingItem.quantity - 1),
                                            );
                                            if (_selectedItems[index].quantity == 0) {
                                              _selectedItems.removeAt(index);
                                            }
                                          }
                                        });
                                        _updateTotals();
                                      }
                                    : null,
                              ),
                              Text(existingItem.quantity.toString()),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    final index = _selectedItems
                                        .indexWhere((item) => item.product.id == product.id);
                                    if (index != -1) {
                                      _selectedItems[index] = InvoiceItem(
                                        product: product,
                                        quantity: existingItem.quantity + 1,
                                        price: product.price,
                                        gstAmount: (product.price * (product.gstRate / 100)) *
                                            (existingItem.quantity + 1),
                                      );
                                    } else {
                                      _selectedItems.add(InvoiceItem(
                                        product: product,
                                        quantity: 1,
                                        price: product.price,
                                        gstAmount: product.price * (product.gstRate / 100),
                                      ));
                                    }
                                  });
                                  _updateTotals();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text('₹${_subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total GST:'),
                            Text('₹${_totalGst.toStringAsFixed(2)}'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Payable:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '₹${_totalPayable.toStringAsFixed(2)}',
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
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
} 