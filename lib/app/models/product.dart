import 'dart:convert';
import 'package:flutter/services.dart';

class Product {
  int? productId;
  String barcode;
  String name;
  String description;
  double price;
  int quantity;
  String imageBase64;

  Product({
    this.productId,
    required this.barcode,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imageBase64,
  });


  Product.fromJson(Map<String, dynamic> json)
      : productId = json['productId'],
        barcode = json['barcode'],
        name = json['name'],
        description = json['description'],
        price = json['price'],
        quantity = json['quantity'],
        imageBase64 = json['imageBase64'];

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'barcode': barcode,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'imageBase64': imageBase64,
    };
  }

  static Future<String> loadImageAsBase64(String assetPath) async {
    ByteData bytes = await rootBundle.load(assetPath);
    Uint8List imageBytes = bytes.buffer.asUint8List();
    return base64Encode(imageBytes);
  }

  static Uint8List decodeImageFromBase64(String base64String) {
    return base64Decode(base64String);
  }
}
