import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:storage_management_app/app/widgets/my_drawer.dart';
import 'package:storage_management_app/app/models/product.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key});

  @override
  ProductsListPageState createState() => ProductsListPageState();
}

class ProductsListPageState extends State<ProductsListPage> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    try {
      Dio dio = Dio();
      final response = await dio.get(
        'https://storagemanagementapp.serveo.net/products',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data;
        return jsonResponse.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.productList),
      ),
      drawer: const MyDrawer(),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${localizations.error}: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(localizations.noProductsFound));
          }

          List<Product> products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              Product product = products[index];
              Uint8List imageBytes = Product.decodeImageFromBase64(product.imageBase64);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.memory(imageBytes, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(product.name),
                  subtitle: Text(product.description),
                  trailing: Text('\$${product.price}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
