import 'dart:async';
import 'package:stok_takip/models/product.dart';
import 'package:stok_takip/service/exchange_rate.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';

class BlocSale {
  List<Product> listProduct = <Product>[];
  List<double> listUSD = <double>[];
  Map<String, num> totalPriceAndKdv = <String, num>{
    'total_without_tax': 0,
    'kdv': 8,
    'total_with_tax': 0,
  };

  final Map<String, String> _paymentSystem = {
    "cash": "0",
    "bankCard": "0",
    "EftHavale": "0"
  };
  int kdv = 8;

  final StreamController<List<Product>> _streamControllerIndex =
      StreamController<List<Product>>.broadcast();

  final StreamController<Map<String, num>> _streamControllerTotalPriceSection =
      StreamController.broadcast();

  final StreamController<double> _streamControllerPaymentSystem =
      StreamController.broadcast();

  Stream<List<Product>> get getStreamListProduct =>
      _streamControllerIndex.stream;

  Stream<Map<String, num>> get getStreamTotalPriceSection =>
      _streamControllerTotalPriceSection.stream;

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

  //DataTable Toplam Tutar , KDV ve Genel Toplam tekrar dolduruyor.
  void getTotalPriceSection(String? unitOfCurrency) {
    getProductTotalValue();
    if (unitOfCurrency == "₺" || unitOfCurrency == null) {
      totalPriceAndKdv['total_without_tax'] = getProductTotalValue();
      totalPriceAndKdv['kdv'] = kdv;
      totalPriceAndKdv['total_with_tax'] = getProductTotalValueWithTax();

      print("girdi ");
    } else if (unitOfCurrency == "\$") {
      totalPriceAndKdv['total_without_tax'] =
          getProductTotalValue() / exchangeRateService.exchangeRate['USD']!;
      totalPriceAndKdv['kdv'] = kdv;
      totalPriceAndKdv['total_with_tax'] = getProductTotalValueWithTax() /
          exchangeRateService.exchangeRate['USD']!;
    } else if (unitOfCurrency == "€") {
      totalPriceAndKdv['total_without_tax'] =
          getProductTotalValue() / exchangeRateService.exchangeRate['EUR']!;
      totalPriceAndKdv['kdv'] = kdv;
      totalPriceAndKdv['total_with_tax'] = getProductTotalValueWithTax() /
          exchangeRateService.exchangeRate['EUR']!;
    }

    ///Satıl Ekranındaki Kalan Tutarı güncelliyor
    balance();

    _streamControllerTotalPriceSection.sink.add(totalPriceAndKdv);
  }

/*------------------Total Fiyatların Hesaplandığı yer ------------------ */

  double getProductTotalValue() {
    double totalPrice = 0;

    if (listProduct.isNotEmpty) {
      for (var element in listProduct) {
        totalPrice = totalPrice + element.total!;
      }
    }
    return totalPrice;
  }

  ///Ürünlerin KDV değerini okuyor ve ona göre kdv işlem yapıyor. Müşteri anlok olarak KDV değerini Değiştirmek istediği için TextFormField çevrildi.
/*   // KDV
  int getProductKDV(String? newKDV) {
    if (listProduct.isNotEmpty) {
      kdv = listProduct[0].taxRate;
    }

    return kdv;
  }
 */
  //Yeni KDV Eklendiği Yer
  set setKdv(String newKDV) => kdv = int.parse(newKDV);

  double getProductTotalValueWithTax() {
    double totalPriceWithoutTax = 0;
    if (listProduct.isNotEmpty) {
      totalPriceWithoutTax = getProductTotalValue() * ((100 + kdv) / 100);
    }
    return totalPriceWithoutTax;
  }

  /*--------------------------------------------------------------------- */
  /*----------------- Başlangıç Fiyat Birimini Değiştirme---------------- */
  changeUnitOfCurrencyRate(double currencyValue) {
    totalPriceAndKdv['USD'] =
        totalPriceAndKdv['total_without_tax']! / currencyValue;

    totalPriceAndKdv['total_with_tax'] =
        totalPriceAndKdv['total_with_tax']! / currencyValue;
  }
  /*--------------------------------------------------------------------- */
}

final blocSale = BlocSale();
