import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reports_provider.dart';
import 'package:intl/intl.dart';

class ProductPerformanceScreen extends ConsumerStatefulWidget {
  const ProductPerformanceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductPerformanceScreen> createState() => _ProductPerformanceScreenState();
}

class _ProductPerformanceScreenState extends ConsumerState<ProductPerformanceScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  List<Map<String, dynamic>>? _topProducts;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final products = await ref.read(reportsProvider).getTopSellingProducts(
        _startDate,
        _endDate,
        limit: 10, // Show top 10 products
      );
      setState(() => _topProducts = products);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Performance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Report for ${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM, yyyy').format(_endDate)}',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Top Selling Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_topProducts != null && _topProducts!.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _topProducts!.length,
                      itemBuilder: (context, index) {
                        final product = _topProducts![index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '#${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['name'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Product ID: ${product['productId']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildMetricColumn(
                                      'Units Sold',
                                      product['quantity'].toString(),
                                      Icons.inventory,
                                    ),
                                    _buildMetricColumn(
                                      'Revenue',
                                      '₹${product['revenue'].toStringAsFixed(2)}',
                                      Icons.currency_rupee,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  else
                    const Center(
                      child: Text('No product data available for the selected period'),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.blue,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 