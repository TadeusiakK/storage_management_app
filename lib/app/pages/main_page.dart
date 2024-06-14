import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storage_management_app/app/models/product.dart';
import 'package:storage_management_app/app/widgets/my_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  Product? _scannedProduct;
  bool _isAddingProduct = false;
  bool _isDeletingProduct = false;
  final _formKey = GlobalKey<FormState>();
  String _barcode = '';
  String _name = '';
  String _description = '';
  double _price = 0;
  int _quantity = 0;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _scanBarcode({bool forAddProduct = false, bool forDeleteProduct = false}) async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', AppLocalizations.of(context)!.cancel, true, ScanMode.BARCODE);
    } catch (e) {
      barcodeScanRes = AppLocalizations.of(context)!.scanFailed;
    }

    if (!mounted) return;

    if (forAddProduct) {
      setState(() {
        _barcode = barcodeScanRes;
        _isAddingProduct = true;
        _isDeletingProduct = false;
      });
    } else if (forDeleteProduct) {
      setState(() {
        _isDeletingProduct = true;
        _isAddingProduct = false;
      });
      await _fetchProductByBarcode(barcodeScanRes, forDeleteProduct: true);
    } else {
      await _fetchProductByBarcode(barcodeScanRes);
    }
  }

  Future<void> _fetchProductByBarcode(String barcode, {bool forDeleteProduct = false}) async {
    try {
      Dio dio = Dio();
      final response = await dio.get(
        'https://storagemanagementapp.serveo.net/product/$barcode',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final productJson = response.data;
        setState(() {
          _scannedProduct = Product.fromJson(productJson);
          if (!forDeleteProduct) _isAddingProduct = false;
        });
      } else {
        throw Exception(AppLocalizations.of(context)!.failedToLoadProduct);
      }
    } catch (e) {
      print('Error fetching product: $e');
      setState(() {
        _scannedProduct = Product(
          productId: null,
          barcode: barcode,
          name: AppLocalizations.of(context)!.productNotFound,
          description: '',
          price: 0.0,
          quantity: 0,
          imageBase64: '',
        );
        if (!forDeleteProduct) _isAddingProduct = false;
      });
    }
  }

  Future<void> _deleteProduct() async {
    if (_scannedProduct != null && _scannedProduct!.barcode.isNotEmpty) {
      try {
        Dio dio = Dio();
        final response = await dio.delete(
          'https://storagemanagementapp.serveo.net/product/${_scannedProduct!.barcode}',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          setState(() {
            _scannedProduct = null;
            _isDeletingProduct = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.productDeletedSuccessfully)),
          );
        } else {
          throw Exception(AppLocalizations.of(context)!.failedToDeleteProduct);
        }
      } catch (e) {
        print('Error deleting product: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
        final savedFile = await File(pickedFile.path).copy('${directory.path}/$fileName');
        setState(() {
          _imageFile = savedFile;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String imageBase64 = '';
      if (_imageFile != null) {
        final imageBytes = await _imageFile!.readAsBytes();
        imageBase64 = base64Encode(imageBytes);
      }

      final newProduct = Product(
        productId: null,
        barcode: _barcode,
        name: _name,
        description: _description,
        price: _price,
        quantity: _quantity,
        imageBase64: imageBase64,
      );

      try {
        Dio dio = Dio();
        final response = await dio.post(
          'https://storagemanagementapp.serveo.net/addProduct',
          data: jsonEncode(newProduct.toJson()),
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          setState(() {
            _scannedProduct = null;
            _isAddingProduct = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.productAddedSuccessfully)),
          );
        } else {
          throw Exception(AppLocalizations.of(context)!.failedToAddProduct);
        }
      } catch (e) {
        print('Error saving product: $e');
      }
    }
  }

  void _startAddProduct() {
    _scanBarcode(forAddProduct: true);
  }

  void _startDeleteProduct() {
    _scanBarcode(forDeleteProduct: true);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.productManagement),
      ),
      drawer: const MyDrawer(),
      body: Center(
        child: _isAddingProduct
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: localizations.barcode),
                          initialValue: _barcode,
                          enabled: false,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: localizations.name),
                          validator: (value) => value!.isEmpty ? localizations.enterName : null,
                          onSaved: (value) => _name = value!,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: localizations.description),
                          validator: (value) => value!.isEmpty ? localizations.enterDescription : null,
                          onSaved: (value) => _description = value!,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: localizations.price),
                          keyboardType: TextInputType.number,
                          validator: (value) => value!.isEmpty ? localizations.enterPrice : null,
                          onSaved: (value) => _price = double.parse(value!),
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: localizations.quantity),
                          keyboardType: TextInputType.number,
                          validator: (value) => value!.isEmpty ? localizations.enterQuantity : null,
                          onSaved: (value) => _quantity = int.parse(value!),
                        ),
                        const SizedBox(height: 20),
                        if (_imageFile != null)
                          Image.file(_imageFile!, height: 100),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: Text(localizations.pickImage),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveProduct,
                          child: Text(localizations.saveProduct),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isAddingProduct = false;
                            });
                          },
                          child: Text(localizations.cancel),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : _isDeletingProduct && _scannedProduct != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_scannedProduct!.imageBase64.isNotEmpty)
                        Image.memory(
                          Uint8List.fromList(base64Decode(_scannedProduct!.imageBase64)),
                          height: 150,
                        ),
                      const SizedBox(height: 16),
                      Text(
                        _scannedProduct!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_scannedProduct!.description),
                      const SizedBox(height: 8),
                      Text(
                        '${localizations.price}: \$${_scannedProduct!.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${localizations.quantity}: ${_scannedProduct!.quantity}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _deleteProduct,
                        child: Text(localizations.deleteProduct),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isDeletingProduct = false;
                            _scannedProduct = null;
                          });
                        },
                        child: Text(localizations.cancel),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (_scannedProduct != null)
                        _scannedProduct!.barcode.isNotEmpty
                            ? Card(
                                margin: const EdgeInsets.all(16.0),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_scannedProduct!.imageBase64.isNotEmpty)
                                        Image.memory(
                                          Uint8List.fromList(base64Decode(_scannedProduct!.imageBase64)),
                                          height: 150,
                                        ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _scannedProduct!.name,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(_scannedProduct!.description),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${localizations.price}: \$${_scannedProduct!.price.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                      Text(
                                        '${localizations.quantity}: ${_scannedProduct!.quantity}',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Text(localizations.productNotFound),
                      ElevatedButton(
                        onPressed: _scanBarcode,
                        child: Text(localizations.scanBarcode),
                      ),
                      ElevatedButton(
                        onPressed: _startAddProduct,
                        child: Text(localizations.addProduct),
                      ),
                      ElevatedButton(
                        onPressed: _startDeleteProduct,
                        child: Text(localizations.deleteProduct),
                      ),
                    ],
                  ),
      ),
    );
  }
}
