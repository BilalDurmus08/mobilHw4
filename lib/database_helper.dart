// lib/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'product_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'product_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ProductTable (
        barcodeNo TEXT PRIMARY KEY,
        productName TEXT NOT NULL,
        category TEXT NOT NULL,
        unitPrice REAL NOT NULL,
        taxRate INTEGER NOT NULL,
        price REAL NOT NULL,
        stockInfo INTEGER
      )
    ''');
  }

  // Create (Insert) a new product
  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert(
      'ProductTable',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Prevents duplicate barcodes
    );
  }

  // Read all products
  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ProductTable');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Read a single product by barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ProductTable',
      where: 'barcodeNo = ?',
      whereArgs: [barcode],
    );
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  // Update a product
  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'ProductTable',
      product.toMap(),
      where: 'barcodeNo = ?',
      whereArgs: [product.barcodeNo],
    );
  }

  // Delete a product
  Future<void> deleteProduct(String barcodeNo) async {
    final db = await database;
    await db.delete(
      'ProductTable',
      where: 'barcodeNo = ?',
      whereArgs: [barcodeNo],
    );
  }
}
