class Product {
  final String id;
  final String name;
  final double basePrice;
  final double gstRate;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.gstRate,
    this.imageUrl,
  });

  double get cgst => (basePrice * gstRate) / 200; // Divided by 200 because gstRate is in percentage
  double get sgst => (basePrice * gstRate) / 200;
  double get total => basePrice + cgst + sgst;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'basePrice': basePrice,
      'gstRate': gstRate,
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      basePrice: (map['basePrice'] ?? 0.0).toDouble(),
      gstRate: (map['gstRate'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
    );
  }

  Product copyWith({
    String? id,
    String? name,
    double? basePrice,
    double? gstRate,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      gstRate: gstRate ?? this.gstRate,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
} 