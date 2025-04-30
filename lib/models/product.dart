class Product {
  final String id;
  final String name;
  final double price;
  final double gstRate;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.gstRate,
    this.imageUrl,
  });

  double get cgst => (price * gstRate) / 200; // Divided by 200 because gstRate is in percentage
  double get sgst => (price * gstRate) / 200;
  double get total => price + cgst + sgst;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'gstRate': gstRate,
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      gstRate: (map['gstRate'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
    );
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? gstRate,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      gstRate: gstRate ?? this.gstRate,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
} 