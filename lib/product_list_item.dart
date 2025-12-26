// lib/product_list_item.dart

import 'package:flutter/material.dart';
import 'package:mobilhw4/product_dialog.dart';
import 'package:provider/provider.dart';
import 'product_model.dart';
import 'product_provider.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final bool isHighlighted;

  const ProductListItem({
    super.key,
    required this.product,
    this.isHighlighted = false,
  });

  void _deleteProduct(BuildContext context, String barcode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false)
                  .deleteProduct(barcode);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted successfully!')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use a Card for a clean layout
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isHighlighted ? Colors.teal.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isHighlighted
            ? const BorderSide(color: Colors.teal, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.productName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Barcode: ${product.barcodeNo}',
                style: const TextStyle(color: Colors.grey)),
            Text('Category: ${product.category}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price: \$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Stock: ${product.stockInfo ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // --- EDIT BUTTON ---
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ProductDialog(product: product),
                    );
                  },
                ),
                // --- DELETE BUTTON ---
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteProduct(context, product.barcodeNo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
