// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:mobilhw4/product_dialog.dart';
import 'package:mobilhw4/product_list_item.dart';import 'package:provider/provider.dart';
import 'product_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(BuildContext context) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final barcode = _searchController.text.trim();

    if (barcode.isEmpty) {
      provider.clearSearch(); // Clear search and show all products
      return;
    }

    final bool found = await provider.searchProductByBarcode(barcode);

    if (!found && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Product Not Found'),
          content: const Text(
              'No product with this barcode was found. Would you like to add it?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the alert
                showDialog(
                  context: context,
                  builder: (_) => ProductDialog(
                    // Prefill barcode for convenience
                    initialBarcode: barcode,
                  ),
                );
              },
              child: const Text('Add New'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- SEARCH BAR ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Enter Barcode',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<ProductProvider>(context, listen: false)
                              .fetchProducts();
                        },
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(context),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _performSearch(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- PRODUCT LIST ---
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  final products = provider.products;
                  final searchedProduct = provider.searchedProduct;

                  if (products.isEmpty) {
                    return const Center(
                      child: Text(
                        'No products found. Add one to get started!',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  // If a search is active, you can choose to show only that one
                  // or highlight it in the full list. We will highlight it.
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      // Highlight the searched product
                      final isHighlighted = searchedProduct != null &&
                          product.barcodeNo == searchedProduct.barcodeNo;

                      return ProductListItem(
                        product: product,
                        isHighlighted: isHighlighted,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // --- ADD PRODUCT BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const ProductDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
