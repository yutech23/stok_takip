import 'package:stok_takip/models/category.dart';

class Product {
  int? product_id;
  String? productCodeAndQrCode;
  int? amountOfStock;
  int? taxRate;
  double? buyingpriceWithoutTax;
  double? sallingPriceWithoutTax;

  Category? category;

  Product(
      {required this.productCodeAndQrCode,
      required this.amountOfStock,
      required this.taxRate,
      required this.buyingpriceWithoutTax,
      required this.sallingPriceWithoutTax,
      required this.category});

  Product.withId(
      {required this.product_id,
      required this.productCodeAndQrCode,
      required this.amountOfStock,
      required this.taxRate,
      required this.buyingpriceWithoutTax,
      required this.sallingPriceWithoutTax,
      required this.category});

  Product.update({
    required productCodeAndQrCode,
    required amountOfStock,
    required goodInStock,
    required taxRate,
    required buyingpriceWithoutTax,
    required sallingPriceWithoutTax,
  });
}
