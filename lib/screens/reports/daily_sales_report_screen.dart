import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reports_provider.dart';
import 'package:intl/intl.dart';

class DailySalesReportScreen extends ConsumerStatefulWidget {
  const DailySalesReportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DailySalesReportScreen> createState() => _DailySalesReportScreenState();
}

class _DailySalesReportScreenState extends ConsumerState<DailySalesReportScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final data = await ref.read(reportsProvider).getDailySalesReport(_selectedDate);
      setState(() => _reportData = data);
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Sales Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
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
                    'Report for ${DateFormat('dd MMM, yyyy').format(_selectedDate)}',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_reportData != null) ...[
                    _buildMetricCard(
                      'Total Invoices',
                      _reportData!['totalInvoices'].toString(),
                      Icons.receipt,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildMetricCard(
                      'Total Revenue',
                      '₹${_reportData!['totalRevenue'].toStringAsFixed(2)}',
                      Icons.currency_rupee,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'CGST Collected',
                            '₹${_reportData!['totalCGST'].toStringAsFixed(2)}',
                            Icons.account_balance,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard(
                            'SGST Collected',
                            '₹${_reportData!['totalSGST'].toStringAsFixed(2)}',
                            Icons.account_balance,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 