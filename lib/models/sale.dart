// ignore_for_file: public_member_api_docs, sort_constructors_first
class Sale {
  late String customerType;
  late String customerPhone;
  late num totalPaymentWithoutTax;
  late int kdvRate;
  double? cashPayment;
  double? bankcardPayment;
  double? eftHavalePayment;
  late String unitOfCurrency;
  DateTime? forwardSaleDate;
  late DateTime saleTime;
  String? paymentNextDate;
  late List<SaleDetail> soldProductsList;
  late String userId;
}

class SaleDetail {
  late String productCode;
  late int productAmount;
  late num productSellingPriceWithoutTax;
  late num productBuyingPriceWithoutTax;

  SaleDetail(
      {required this.productCode,
      required this.productAmount,
      required this.productBuyingPriceWithoutTax,
      required this.productSellingPriceWithoutTax});
}
