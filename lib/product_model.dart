// lib/product_model.dart

class Product {
  String barcodeNo;
  String productName;
  String category;
  double unitPrice;
  int taxRate;
  double price;
  int? stockInfo; // Can be null

  Product({
    required this.barcodeNo,
    required this.productName,
    required this.category,
    required this.unitPrice,
    required this.taxRate,
    required this.price,
    this.stockInfo,
  });

  // Convert a Product object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'barcodeNo': barcodeNo,
      'productName': productName,
      'category': category,
      'unitPrice': unitPrice,
      'taxRate': taxRate,
      'price': price,
      'stockInfo': stockInfo,
    };
  }

  // Extract a Product object from a Map object
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      barcodeNo: map['barcodeNo'],
      productName: map['productName'],
      category: map['category'],
      unitPrice: map['unitPrice'],
      taxRate: map['taxRate'],
      price: map['price'],
      stockInfo: map['stockInfo'],
    );
  }
}
