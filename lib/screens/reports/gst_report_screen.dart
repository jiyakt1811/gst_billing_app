import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reports_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class GSTReportScreen extends ConsumerStatefulWidget {
  const GSTReportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GSTReportScreen> createState() => _GSTReportScreenState();
}

class _GSTReportScreenState extends ConsumerState<GSTReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
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
      final startData = await ref.read(reportsProvider).getMonthlySalesReport(_startDate);
      final endData = await ref.read(reportsProvider).getMonthlySalesReport(_endDate);
      
      setState(() {
        _reportData = {
          'totalInvoices': endData['totalInvoices'] - startData['totalInvoices'],
          'totalRevenue': endData['totalRevenue'] - startData['totalRevenue'],
          'totalCGST': endData['totalCGST'] - startData['totalCGST'],
          'totalSGST': endData['totalSGST'] - startData['totalSGST'],
        };
      });
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
        title: const Text('GST Report'),
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
                    const SizedBox(height: 24),
                    const Text(
                      'GST Collection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Colors.orange,
                              value: _reportData!['totalCGST'],
                              title: 'CGST\n₹${_reportData!['totalCGST'].toStringAsFixed(0)}',
                              radius: 100,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.purple,
                              value: _reportData!['totalSGST'],
                              title: 'SGST\n₹${_reportData!['totalSGST'].toStringAsFixed(0)}',
                              radius: 100,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildGSTDetailRow(
                              'CGST Collection',
                              _reportData!['totalCGST'],
                              Colors.orange,
                            ),
                            const Divider(),
                            _buildGSTDetailRow(
                              'SGST Collection',
                              _reportData!['totalSGST'],
                              Colors.purple,
                            ),
                            const Divider(),
                            _buildGSTDetailRow(
                              'Total GST',
                              _reportData!['totalCGST'] + _reportData!['totalSGST'],
                              Colors.blue,
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildGSTDetailRow(String label, double amount, Color color, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 