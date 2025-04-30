import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice.dart';

final reportsProvider = Provider((ref) => ReportsService());

class ReportsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDailySalesReport(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('invoices')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final invoices = snapshot.docs.map((doc) => Invoice.fromMap(doc.data())).toList();

    return _calculateMetrics(invoices);
  }

  Future<Map<String, dynamic>> getMonthlySalesReport(DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 1);

    final snapshot = await _firestore
        .collection('invoices')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThan: Timestamp.fromDate(endOfMonth))
        .get();

    final invoices = snapshot.docs.map((doc) => Invoice.fromMap(doc.data())).toList();

    return _calculateMetrics(invoices);
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts(DateTime startDate, DateTime endDate, {int limit = 5}) async {
    final snapshot = await _firestore
        .collection('invoices')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate))
        .get();

    final invoices = snapshot.docs.map((doc) => Invoice.fromMap(doc.data())).toList();
    final productSales = <String, Map<String, dynamic>>{};

    for (var invoice in invoices) {
      for (var item in invoice.items) {
        final productId = item.product.id;
        if (!productSales.containsKey(productId)) {
          productSales[productId] = {
            'productId': productId,
            'name': item.product.name,
            'quantity': 0,
            'revenue': 0.0,
          };
        }
        productSales[productId]!['quantity'] += item.quantity;
        productSales[productId]!['revenue'] += (item.price * item.quantity) + item.gstAmount;
      }
    }

    final sortedProducts = productSales.values.toList()
      ..sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

    return sortedProducts.take(limit).toList();
  }

  Map<String, dynamic> _calculateMetrics(List<Invoice> invoices) {
    double totalRevenue = 0;
    double totalCGST = 0;
    double totalSGST = 0;
    int totalInvoices = invoices.length;

    for (var invoice in invoices) {
      totalRevenue += invoice.totalPayable;
      totalCGST += invoice.totalGst / 2; // Split GST into CGST and SGST
      totalSGST += invoice.totalGst / 2;
    }

    return {
      'totalInvoices': totalInvoices,
      'totalRevenue': totalRevenue,
      'totalCGST': totalCGST,
      'totalSGST': totalSGST,
    };
  }
} 