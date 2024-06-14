import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:mysql_client/mysql_client.dart';

class Product {
  int? productId;
  String barcode;
  String name;
  String description;
  double price;
  int quantity;

  Product({
    this.productId,
    required this.barcode,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      barcode: json['barcode'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'barcode': barcode,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
    };
  }
}

class ImageStore {
  static final Map<String, String> _images = {};

  static void addImage(String barcode, String base64Image) {
    _images[barcode] = base64Image;
  }

  static String? getImage(String barcode) {
    return _images[barcode];
  }

  static void removeImage(String barcode) {
    _images.remove(barcode);
  }
}

Future<void> main() async {
  final app = Router();

  final conn = await MySQLConnection.createConnection(
    host: "localhost",
    port: 3306,
    userName: "root",
    password: "root",
    databaseName: "storage",
  );

  await conn.connect();

  app.get('/', (Request request) {
    return Response.ok("Server is running");
  });

  app.get('/products', (Request request) async {
    try {
      List<Product> products = await fetchProductsFromDB(conn);
      final List<Map<String, dynamic>> productsJsonList =
          products.map((product) => product.toJson()).toList();
      return Response.ok(jsonEncode(productsJsonList), headers: {'content-type': 'application/json'});
    } catch (e, stackTrace) {
      print('Error fetching products: $e');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(body: 'Error fetching products: $e');
    }
  });

  app.get('/product/<barcode>', (Request request, String barcode) async {
    try {
      final product = await fetchProductByBarcodeFromDB(conn, barcode);
      if (product != null) {
        final imageBase64 = ImageStore.getImage(barcode);
        final productWithImage = product.toJson();
        productWithImage['imageBase64'] = imageBase64;
        //print(ImageStore.getImage(barcode));
        return Response.ok(jsonEncode(productWithImage), headers: {'content-type': 'application/json'});
      } else {
        return Response.notFound('Product not found');
      }
    } catch (e, stackTrace) {
      print('Error fetching product: $e');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(body: 'Error fetching product: $e');
    }
  });

  app.post('/addProduct', (Request request) async {
    try {
      final requestBody = await request.readAsString();
      final jsonData = jsonDecode(requestBody);
      final imageBase64 = jsonData.remove('imageBase64');
      final newProduct = Product.fromJson(jsonData);
      await addProductToDB(conn, newProduct);
      ImageStore.addImage(newProduct.barcode, imageBase64);
      return Response.ok('Product added successfully');
    } catch (e, stackTrace) {
      print('Error adding product: $e');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(body: 'Error adding product: $e');
    }
  });

  app.delete('/product/<barcode>', (Request request, String barcode) async {
    try {
      final success = await deleteProductFromDB(conn, barcode);
      if (success) {
        ImageStore.removeImage(barcode);
        return Response.ok('Product deleted successfully');
      } else {
        return Response.notFound('Product not found');
      }
    } catch (e, stackTrace) {
      print('Error deleting product: $e');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(body: 'Error deleting product: $e');
    }
  });

  final server = await io.serve(app, 'localhost', 5555);
  print('Server is running on http://${server.address.host}:${server.port}');
}

Future<List<Product>> fetchProductsFromDB(MySQLConnection conn) async {
  List<Product> products = [];
  var results = await conn.execute('SELECT * FROM products');

  for (var row in results.rows) {
    products.add(Product(
      productId: int.tryParse(row.colByName('productId') ?? '0'),
      barcode: row.colByName('barcode') ?? '',
      name: row.colByName('name') ?? '',
      description: row.colByName('description') ?? '',
      price: double.tryParse(row.colByName('price') ?? '0.0') ?? 0.0,
      quantity: int.tryParse(row.colByName('quantity') ?? '0') ?? 0,
    ));
  }
  return products;
}

Future<Product?> fetchProductByBarcodeFromDB(MySQLConnection conn, String barcode) async {
  var result = await conn.execute(
    'SELECT * FROM products WHERE barcode = "$barcode"',
  );

  if (result.rows.isNotEmpty) {
    var row = result.rows.first;
    return Product(
      productId: int.tryParse(row.colByName('productId') ?? '0'),
      barcode: row.colByName('barcode') ?? '',
      name: row.colByName('name') ?? '',
      description: row.colByName('description') ?? '',
      price: double.tryParse(row.colByName('price') ?? '0.0') ?? 0.0,
      quantity: int.tryParse(row.colByName('quantity') ?? '0') ?? 0,
    );
  }
  return null;
}

Future<void> addProductToDB(MySQLConnection conn, Product product) async {
  await conn.execute(
    'INSERT INTO products (barcode, name, description, price, quantity) VALUES ("${product.barcode}", "${product.name}", "${product.description}", ${product.price}, ${product.quantity})'
  );
}

Future<bool> deleteProductFromDB(MySQLConnection conn, String barcode) async {
  var result = await conn.execute(
    'DELETE FROM products WHERE barcode = "$barcode"',
  );
  return result.affectedRows.toInt() > 0;
}
