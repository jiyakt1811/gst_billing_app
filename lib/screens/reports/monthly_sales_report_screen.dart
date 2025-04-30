import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reports_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlySalesReportScreen extends ConsumerStatefulWidget {
  const MonthlySalesReportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MonthlySalesReportScreen> createState() => _MonthlySalesReportScreenState();
}

class _MonthlySalesReportScreenState extends ConsumerState<MonthlySalesReportScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic>? _reportData;
  List<Map<String, dynamic>>? _topProducts;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final data = await ref.read(reportsProvider).getMonthlySalesReport(_selectedDate);
      final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      final topProducts = await ref.read(reportsProvider).getTopSellingProducts(startOfMonth, endOfMonth);
      
      setState(() {
        _reportData = data;
        _topProducts = topProducts;
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

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, 1);
      });
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Sales Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectMonth(context),
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
                    'Report for ${DateFormat('MMMM yyyy').format(_selectedDate)}',
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
                    if (_topProducts != null && _topProducts!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Top Selling Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _topProducts!
                                .map((p) => p['revenue'] as double)
                                .reduce((a, b) => a > b ? a : b),
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value < 0 || value >= _topProducts!.length) {
                                      return const SizedBox();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        _topProducts![value.toInt()]['name'].toString().split(' ')[0],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 60,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '₹${value.toInt()}',
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: _topProducts!.asMap().entries.map((entry) {
                              return BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value['revenue'],
                                    color: Colors.blue,
                                    width: 20,
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
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