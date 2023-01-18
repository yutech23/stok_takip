import 'package:flutter/cupertino.dart';
import 'package:stok_takip/models/category.dart';

class Product {
  String productCode;
  int currentAmountOfStock;
  int taxRate;
  double? currentBuyingPriceWithoutTax;
  double? currentSallingPriceWithoutTax;
  Category? category;
  double? currentSallingPriceWith;
  int sallingAmount = 1;
  double? total;
  int? index;
/*   TextEditingController controllerSallingAmount = TextEditingController();
  TextEditingController controllerSallingPriceWithTax = TextEditingController(); */

  Product({
    required this.productCode,
    required this.currentAmountOfStock,
    required this.taxRate,
    required this.currentBuyingPriceWithoutTax,
    required this.currentSallingPriceWithoutTax,
    required this.category,
  });

  Product.saleInfo({
    required this.productCode,
    required this.currentAmountOfStock,
    required this.taxRate,
    required this.currentBuyingPriceWithoutTax,
    this.currentSallingPriceWith,
    this.total,
    this.sallingAmount = 1,
    this.index,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          productCode == other.productCode;

  @override
  int get hashCode => productCode.hashCode;
}
