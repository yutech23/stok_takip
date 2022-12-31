import 'package:stok_takip/models/category.dart';

class Product {
  String productCode;
  int currentAmountOfStock;
  int taxRate;
  double? currentBuyingPriceWithoutTax;
  double? currentSallingPriceWithoutTax;
  Category? category;

  Product({
    required this.productCode,
    required this.currentAmountOfStock,
    required this.taxRate,
    required this.currentBuyingPriceWithoutTax,
    required this.currentSallingPriceWithoutTax,
    required this.category,
  });
}
