import 'dart:async';
import 'package:stok_takip/models/product.dart';

class BlocSale {
  List<Product> listProduct = <Product>[];

  StreamController<List<Product>> streamControllerIndex =
      StreamController<List<Product>>.broadcast();

  Stream<List<Product>> get getStream => streamControllerIndex.stream;

  ///Listeye ürün ekliyor
  addProduct(Product selectedProduct) {
    if (!listProduct.contains(selectedProduct)) {
      listProduct.add(selectedProduct);
    }
  }

  //Listeden ürün siliyor
  void removeFromListProduct(String productCode) {
    listProduct.removeWhere((element) => element.productCode == productCode);
    print("Eleman Silindi");
  }

/*------------------Total Fiyatların Hesaplandığı yer ------------------ */
  double getProductTotalValue() {
    double totalPrice = 0;
    if (listProduct.isNotEmpty) {
      listProduct.forEach((element) {
        totalPrice = totalPrice + element.total!;
      });
    }
    return totalPrice;
  }

  int getProductKDV() {
    int kdv = 0;
    if (listProduct.isNotEmpty) {
      kdv = listProduct[0].taxRate;
    }
    return kdv;
  }

  double getProductTotalWithoutPrice() {
    double totalPriceWithoutTax = 0;
    if (listProduct.isNotEmpty) {
      totalPriceWithoutTax =
          getProductTotalValue() / ((100 + getProductKDV()) / 100);
    }
    return totalPriceWithoutTax;
  }
  /*--------------------------------------------------------------------- */

  streamAddProduct(Product selecedAddProduct) {
    addProduct(selecedAddProduct);
    streamControllerIndex.sink.add(listProduct);
  }
}

final blocSale = BlocSale();
