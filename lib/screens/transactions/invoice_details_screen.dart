import 'package:flutter/material.dart';
import '../../models/invoice.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailsScreen({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${invoice.id.substring(0, 8)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${invoice.date.toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (invoice.customerName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Customer: ${invoice.customerName}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    if (invoice.customerPhone != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Phone: ${invoice.customerPhone}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...invoice.items.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Quantity: ${item.quantity}'),
                          Text('Price: ₹${item.price.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('GST Rate: ${item.product.gstRate}%'),
                          Text('GST Amount: ₹${item.gstAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${((item.price * item.quantity) + item.gstAmount).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTotalRow('Subtotal', invoice.subtotal),
                    _buildTotalRow('Total GST', invoice.totalGst),
                    const Divider(),
                    _buildTotalRow(
                      'Total Payable',
                      invoice.totalPayable,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
} 