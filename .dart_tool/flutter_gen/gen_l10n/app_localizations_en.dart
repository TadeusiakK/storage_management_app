import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language_english => 'Language: English';

  @override
  String get language_polish => 'Language: Polish';

  @override
  String get english => 'English';

  @override
  String get polish => 'Polish';

  @override
  String get home => 'Home';

  @override
  String get productList => 'Product List';

  @override
  String get settings => 'Settings';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get error => 'Error';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get productManagement => 'Product Management';

  @override
  String get barcode => 'Barcode';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get price => 'Price';

  @override
  String get quantity => 'Quantity';

  @override
  String get pickImage => 'Pick Image';

  @override
  String get saveProduct => 'Save Product';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get addProduct => 'Add Product';

  @override
  String get productAddedSuccessfully => 'Product added successfully';

  @override
  String get productDeletedSuccessfully => 'Product deleted successfully';

  @override
  String get enterName => 'Enter a name';

  @override
  String get enterDescription => 'Enter a description';

  @override
  String get enterPrice => 'Enter a price';

  @override
  String get enterQuantity => 'Enter a quantity';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get failedToLoadProduct => 'Failed to load product';

  @override
  String get failedToAddProduct => 'Failed to add product';

  @override
  String get failedToDeleteProduct => 'Failed to delete product';

  @override
  String get scanFailed => 'Failed to scan barcode';
}
