import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoice.dart';

final invoiceProvider = StateNotifierProvider<InvoiceNotifier, AsyncValue<List<Invoice>>>((ref) {
  return InvoiceNotifier();
});

class InvoiceNotifier extends StateNotifier<AsyncValue<List<Invoice>>> {
  InvoiceNotifier() : super(const AsyncValue.loading()) {
    loadInvoices();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadInvoices() async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .orderBy('date', descending: true)
          .get();

      final invoices = snapshot.docs
          .map((doc) => Invoice.fromMap(doc.data()))
          .toList();

      state = AsyncValue.data(invoices);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      await _firestore
          .collection('invoices')
          .doc(invoice.id)
          .set(invoice.toMap());
      
      await loadInvoices();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Invoice?> getInvoice(String id) async {
    try {
      final doc = await _firestore.collection('invoices').doc(id).get();
      if (doc.exists) {
        return Invoice.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Invoice>> getRecentInvoices({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Invoice.fromMap(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
} 