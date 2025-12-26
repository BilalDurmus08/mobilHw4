// lib/product_dialog.dart

import 'package:flutter/material.dart';
import 'package:mobilhw4/product_provider.dart';
import 'package:provider/provider.dart';
import 'product_model.dart';

class ProductDialog extends StatefulWidget {
  final Product? product;
  final String? initialBarcode;

  const ProductDialog({super.key, this.product, this.initialBarcode});

  @override
  _ProductDialogState createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _barcodeNo, _productName, _category;
  late double _unitPrice, _price;
  late int _taxRate;
  int? _stockInfo;

  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.product != null;

    _barcodeNo = widget.product?.barcodeNo ?? widget.initialBarcode ?? '';
    _productName = widget.product?.productName ?? '';
    _category = widget.product?.category ?? '';
    _unitPrice = widget.product?.unitPrice ?? 0.0;
    _taxRate = widget.product?.taxRate ?? 0;
    _price = widget.product?.price ?? 0.0;
    _stockInfo = widget.product?.stockInfo;
  }

  void _calculatePrice() {
    if (_unitPrice > 0 && _taxRate >= 0) {
      setState(() {
        _price = _unitPrice * (1 + _taxRate / 100);
      });
    }
  }

  void _saveForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    _formKey.currentState?.save();

    final productProvider =
    Provider.of<ProductProvider>(context, listen: false);

    final newProduct = Product(
      barcodeNo: _barcodeNo,
      productName: _productName,
      category: _category,
      unitPrice: _unitPrice,
      taxRate: _taxRate,
      price: _price,
      stockInfo: _stockInfo,
    );

    if (_isEditing) {
      productProvider.updateProduct(newProduct);
    } else {
      productProvider.addProduct(newProduct);
    }

    Navigator.of(context).pop(); // Close the dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Product ${_isEditing ? 'updated' : 'added'} successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Product' : 'Add New Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: _barcodeNo,
                decoration: const InputDecoration(labelText: 'Barcode No'),
                enabled: !_isEditing, // Barcode is primary key, cannot be edited
                validator: (value) =>
                value!.isEmpty ? 'Please enter a barcode' : null,
                onSaved: (value) => _barcodeNo = value!,
              ),
              TextFormField(
                initialValue: _productName,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a product name' : null,
                onSaved: (value) => _productName = value!,
              ),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a category' : null,
                onSaved: (value) => _category = value!,
              ),
              TextFormField(
                initialValue: _unitPrice.toString(),
                decoration: const InputDecoration(labelText: 'Unit Price'),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (double.tryParse(value!) == null ||
                    double.parse(value) <= 0)
                    ? 'Please enter a valid price'
                    : null,
                onSaved: (value) => _unitPrice = double.parse(value!),
                onChanged: (value) {
                  _unitPrice = double.tryParse(value) ?? 0.0;
                  _calculatePrice();
                },
              ),
              TextFormField(
                initialValue: _taxRate.toString(),
                decoration: const InputDecoration(labelText: 'Tax Rate (%)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                (int.tryParse(value!) == null || int.parse(value) < 0)
                    ? 'Please enter a valid tax rate'
                    : null,
                onSaved: (value) => _taxRate = int.parse(value!),
                onChanged: (value) {
                  _taxRate = int.tryParse(value) ?? 0;
                  _calculatePrice();
                },
              ),
              TextFormField(
                key: ValueKey(_price), // Ensure it rebuilds when price changes
                initialValue: _price.toStringAsFixed(2),
                decoration: const InputDecoration(
                    labelText: 'Price (with Tax)',
                    filled: true,
                    fillColor: Colors.black12),
                readOnly: true, // This field is calculated automatically
              ),
              TextFormField(
                initialValue: _stockInfo?.toString() ?? '',
                decoration:
                const InputDecoration(labelText: 'Stock Info (Optional)'),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                _stockInfo = (value!.isEmpty) ? null : int.parse(value),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: _saveForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
