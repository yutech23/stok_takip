import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/product.dart';
import 'package:stok_takip/models/sale.dart';
import 'package:stok_takip/service/exchange_rate.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';

class BlocSale {
  List<Product> listProduct = <Product>[];
  List<double> listUSD = <double>[];
  List<String> _listProductCode = <String>[];
  int? _invoiceNumber;

  BlocSale() {
    start();
  }

  start() async {
    await getProductCodeList();
  }

  double _balance = 0;
  Map<String, num> totalPriceAndKdv = <String, num>{
    'total_without_tax': 0,
    'kdv': 0,
    'total_with_tax': 0,
  };

  Map<String, String> _paymentSystem = {
    "cash": "0",
    "bankCard": "0",
    "EftHavale": "0"
  };
  int kdv = 0;

  clearValues() {
    listProduct.clear();
    listUSD.clear();
    totalPriceAndKdv = <String, num>{
      'total_without_tax': 0,
      'kdv': 0,
      'total_with_tax': 0,
    };
    kdv = 0;
    _paymentSystem = {"cash": "0", "bankCard": "0", "EftHavale": "0"};

    _streamControllerIndex.add(listProduct);
    _streamControllerPaymentSystem.add(0);
    _streamControllerTotalPriceSection.add(totalPriceAndKdv);
  }

  List<String> get getterProductCodeList => _listProductCode;

  double get getBalanceValue => _balance;
  int? get getInvoiceNumber => _invoiceNumber;

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

/*-------------------------------TARİH BÖLÜMÜ----------------------------- */
  DateTime _startTime =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime _endTime = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, 23, 59, 59);

  DateTime get getterStartDate => _startTime;
  DateTime get getterEndDate => _endTime;
  set setterStartDate(DateTime dateTime) => _startTime = dateTime;
  set setterEndDate(DateTime dateTime) => _endTime = dateTime;

  ///Zaman Aralığı girme bölümü
  setDateRange(DateTimeRange? dateTimeRange) {
    _startTime = dateTimeRange!.start;
    _endTime = dateTimeRange.end
        .add(const Duration(hours: 23, minutes: 59, seconds: 59));
  }

/*----------------------------------------------------------------------- */
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
    _streamControllerIndex.add(listProduct);
  }

/*----------------------BAŞLANGIÇ - ÖDEME SİSTEMİ ------------------------ */
  balance() {
    double araIslem = 0;
    _paymentSystem.forEach((key, value) {
      araIslem += FormatterConvert().commaToPointDouble(value);
    });

    _balance = totalPriceAndKdv['total_with_tax']! - araIslem;
    _streamControllerPaymentSystem.sink.add(_balance);
  }

  double paymentTotalValue() {
    double paymentTotal = 0;
    _paymentSystem.forEach((key, value) {
      paymentTotal += FormatterConvert().commaToPointDouble(value);
    });
    return paymentTotal;
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

  //DataTable daki Toplam Tutar , KDV ve Genel Toplam tekrar dolduruyor.
  void getTotalPriceSection(String? unitOfCurrency) {
    getProductTotalValue();
    if (unitOfCurrency == "₺" || unitOfCurrency == null) {
      totalPriceAndKdv['total_without_tax'] = getProductTotalValue();
      totalPriceAndKdv['kdv'] = kdv;
      totalPriceAndKdv['total_with_tax'] = getProductTotalValueWithTax();
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

/*---------------------------ÜRÜN LİSTESİ------------------------------ */
  getProductCodeList() async {
    _listProductCode = await db.getProductCode();
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
  /*---------------------------BAŞLANGIÇ - KAYIT------------------------- */
  Future<Map<String, dynamic>> save(
      {required String customerType,
      required String customerPhone,
      String? cashPayment,
      String? bankcardPayment,
      String? eftHavalePayment,
      required String unitOfCurrency,
      String? paymentNextDate,
      required String userId,
      required DateTime saleTime}) async {
    final Sale soldProducts = Sale();
    final List<SaleDetail> listDetailProducts = <SaleDetail>[];
    soldProducts.userId = userId;
    soldProducts.customerType = customerType;
    soldProducts.customerPhone = customerPhone;
    soldProducts.unitOfCurrency = unitOfCurrency;
    soldProducts.paymentNextDate = paymentNextDate;
    soldProducts.totalPaymentWithoutTax =
        totalPriceAndKdv['total_without_tax']!.toDouble();

    soldProducts.cashPayment =
        FormatterConvert().commaToPointDouble(cashPayment!);
    soldProducts.bankcardPayment =
        FormatterConvert().commaToPointDouble(bankcardPayment!);
    soldProducts.eftHavalePayment =
        FormatterConvert().commaToPointDouble(eftHavalePayment!);
    soldProducts.kdvRate = kdv;
    soldProducts.paymentNextDate = paymentNextDate;
    soldProducts.saleTime = saleTime;

    ///Satılan Ürünlerin Listesi Ürün kodu, Miktar, Fiyat(KDVsiz)
    for (var element in listProduct) {
      listDetailProducts.add(SaleDetail(
          productCode: element.productCode,
          productAmount: element.sallingAmount,
          productSellingPriceWithoutTax: element.currentSallingPriceWithoutTax!,
          productBuyingPriceWithoutTax: element.currentBuyingPriceWithoutTax!));
    }
    soldProducts.soldProductsList = listDetailProducts;

    Map<String, dynamic> resDataBase =
        await db.saveSale(soldProducts, listProduct);

    _invoiceNumber = resDataBase['invoice_number'];

    return resDataBase;

    ///Test Ekranı

    /*
    print(soldProducts.soldProducts[0].productCode);
     print(customerType);
    print(unitOfCurrency);
    print(paymentNextDate);
    print(soldProducts.totalPaymentWithoutTax);
    print(soldProducts.cashPayment);
    print(soldProducts.bankcardPayment);
    print(soldProducts.eftHavalePayment);
    print(kdv);

    for (var element in listProduct) {
      print(element.productCode);
      print(element.sallingAmount);
      print(element.currentSallingPriceWithoutTax);
      print(element.total);
      print("***********");
    } */
  }
}
