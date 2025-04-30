import 'package:flutter/material.dart';
import 'daily_sales_report_screen.dart';
import 'monthly_sales_report_screen.dart';
import 'gst_report_screen.dart';
import 'product_performance_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildReportCard(
            context,
            'Daily Sales Report',
            Icons.calendar_today,
            'View today\'s sales analytics',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailySalesReportScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            context,
            'Monthly Sales Report',
            Icons.calendar_month,
            'View monthly sales performance',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MonthlySalesReportScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            context,
            'GST Report',
            Icons.receipt_long,
            'Track GST collections',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GSTReportScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            context,
            'Product Performance',
            Icons.analytics,
            'Analyze product sales metrics',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductPerformanceScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: const Color(0xFF1E88E5),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF1E88E5),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 