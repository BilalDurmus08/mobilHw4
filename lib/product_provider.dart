// lib/product_provider.dart

import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'product_model.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Product> _products = [];
  Product? _searchedProduct;

  List<Product> get products => _products;
  Product? get searchedProduct => _searchedProduct;

  ProductProvider() {
    // Load products when the provider is initialized
    fetchProducts();
  }

  // Fetch all products from the database
  Future<void> fetchProducts() async {
    _products = await _dbHelper.getProducts();
    _searchedProduct = null; // Clear any previous search
    notifyListeners();
  }

  // Add a new product
  Future<void> addProduct(Product product) async {
    await _dbHelper.insertProduct(product);
    await fetchProducts(); // Refresh the list
  }

  // Update an existing product
  Future<void> updateProduct(Product product) async {
    await _dbHelper.updateProduct(product);
    await fetchProducts(); // Refresh the list
  }

  // Delete a product
  Future<void> deleteProduct(String barcodeNo) async {
    await _dbHelper.deleteProduct(barcodeNo);
    await fetchProducts(); // Refresh the list
  }

  // Search for a single product by barcode
  Future<bool> searchProductByBarcode(String barcode) async {
    _searchedProduct = await _dbHelper.getProductByBarcode(barcode);
    if (_searchedProduct != null) {
      // If found, update the main list to re-order or highlight if needed
      // For now, we just fetch all to keep it simple and highlight in the UI
      _products = await _dbHelper.getProducts();
    }
    notifyListeners();
    return _searchedProduct != null;
  }

  // Clear the current search result
  void clearSearch() {
    _searchedProduct = null;
    notifyListeners();
  }
}
