class Sale {
  late String customerType;
  late double totalPaymentWithoutTax;
  late int kdvRate;
  double? cashPayment;
  double? bankcardPayment;
  double? eftHavalePayment;
  late String unitOfCurrency;
  DateTime? saleDate;
  DateTime? paymentNextDate;
  late List<SaleDetail> soldProducts;
}

class SaleDetail {
  late String productCode;
  late int productAmount;
  late double productPriceWithoutTax;
}
