import 'dart:async';
import 'package:stok_takip/models/product.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';

class BlocSale {
  List<Product> listProduct = <Product>[];
  Map<String, num> totalPriceAndKdv = <String, num>{};
  Map<String, String> _paymentSystem = {
    "cash": "0",
    "bankCard": "0",
    "EftHavale": "0"
  };

  final StreamController<List<Product>> _streamControllerIndex =
      StreamController<List<Product>>.broadcast();

  final StreamController<Map<String, num>> _streamControllerTotalPrice =
      StreamController.broadcast();

  final StreamController<double> _streamControllerPaymentSystem =
      StreamController.broadcast();

  Stream<List<Product>> get getStreamListProduct =>
      _streamControllerIndex.stream;
  Stream<Map<String, num>> get getStreamTotalPrice =>
      _streamControllerTotalPrice.stream;
  Stream<double> get getStreamPaymentSystem =>
      _streamControllerPaymentSystem.stream;

  ///Listeye ürün ekliyor
  void addProduct(Product selectedProduct) {
    if (!listProduct.contains(selectedProduct)) {
      listProduct.add(selectedProduct);
      _streamControllerIndex.sink.add(listProduct);
    }
  }

  //Listeden ürün siliyor
  void removeFromListProduct(String productCode) {
    listProduct.removeWhere((element) => element.productCode == productCode);
    _streamControllerIndex.sink.add(listProduct);
  }

  //DataTable Toplam Tutar , KDV ve Genel Toplam tekrar dolduruyor.
  void getTotalPriceSection() {
    totalPriceAndKdv.addAll({
      'total_without_tax': getProductTotalWithoutPrice(),
      'kdv': getProductKDV(),
      'total_with_tax': getProductTotalValue()
    });

    _streamControllerTotalPrice.sink.add(totalPriceAndKdv);
  }

/*----------------------BAŞLANGIÇ - ÖDEME SİSTEMİ ------------------------ */
  balance() {
    double balance = 0;
    _paymentSystem.forEach((key, value) {
      balance += FormatterConvert().commaToPointDouble(value);
    });
    double? araIslem;
    araIslem = totalPriceAndKdv['total_with_tax']! - balance;
    _streamControllerPaymentSystem.sink.add(araIslem);
  }

  setPaymentCashValue(String cashValue) {
    _paymentSystem['cash'] = cashValue;
    balance();
  }

  setPaymentBankCardValue(String bankCardValue) {
    _paymentSystem['bankCard'] = bankCardValue;
    balance();
  }

  setPaymentEftHavaleValue(String eftHavaleValue) {
    _paymentSystem['eftHavale'] = eftHavaleValue;
    balance();
  }

/*--------------------------------------------------------------------- */
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

  // KDV
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

}

final blocSale = BlocSale();
