import 'package:flutter/material.dart';

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
            () {
              // TODO: Navigate to daily sales report
            },
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            context,
            'Monthly Sales Report',
            Icons.calendar_month,
            () {
              // TODO: Navigate to monthly sales report
            },
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            context,
            'GST Report',
            Icons.receipt_long,
            () {
              // TODO: Navigate to GST report
            },
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            context,
            'Product Performance',
            Icons.analytics,
            () {
              // TODO: Navigate to product performance report
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
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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