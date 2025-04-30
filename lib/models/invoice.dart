import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class Invoice {
  final String id;
  final DateTime date;
  final List<InvoiceItem> items;
  final double subtotal;
  final double totalGst;
  final double totalPayable;
  final String? customerName;
  final String? customerPhone;

  Invoice({
    required this.id,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.totalGst,
    required this.totalPayable,
    this.customerName,
    this.customerPhone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'totalGst': totalGst,
      'totalPayable': totalPayable,
      'customerName': customerName,
      'customerPhone': customerPhone,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      date: (map['date'] as Timestamp).toDate(),
      items: (map['items'] as List)
          .map((item) => InvoiceItem.fromMap(item))
          .toList(),
      subtotal: map['subtotal'],
      totalGst: map['totalGst'],
      totalPayable: map['totalPayable'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
    );
  }
}

class InvoiceItem {
  final Product product;
  final int quantity;
  final double price;
  final double gstAmount;

  InvoiceItem({
    required this.product,
    required this.quantity,
    required this.price,
    required this.gstAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'quantity': quantity,
      'price': price,
      'gstAmount': gstAmount,
      'gstRate': product.gstRate,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      product: Product(
        id: map['productId'],
        name: map['productName'],
        price: map['price'],
        gstRate: map['gstRate'],
      ),
      quantity: map['quantity'],
      price: map['price'],
      gstAmount: map['gstAmount'],
    );
  }
} 