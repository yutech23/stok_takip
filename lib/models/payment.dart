// ignore_for_file: public_member_api_docs, sort_constructors_first
class Payment {
  int? paymentId;
  String suppliersFk;
  String productFk;
  String? invoiceCode;
  String unitOfCurrency;
  double total;
  double? cash;
  double? bankcard;
  double? eftHavale;
  double buyingPriceWithoutTax;
  double sallingPriceWithoutTax;
  DateTime? recordDateTime;
  int amountOfStock;
  String? repaymentDateTime;

  Payment({
    this.paymentId,
    required this.suppliersFk,
    required this.productFk,
    this.invoiceCode,
    required this.unitOfCurrency,
    required this.total,
    this.cash,
    this.bankcard,
    this.eftHavale,
    required this.buyingPriceWithoutTax,
    required this.sallingPriceWithoutTax,
    this.recordDateTime,
    required this.amountOfStock,
    this.repaymentDateTime,
  });

  Payment.withId({
    required this.paymentId,
    required this.suppliersFk,
    required this.productFk,
    required this.unitOfCurrency,
    required this.amountOfStock,
    required this.total,
    required this.buyingPriceWithoutTax,
    required this.sallingPriceWithoutTax,
    this.invoiceCode,
    this.bankcard,
    this.cash,
    this.eftHavale,
    this.recordDateTime,
    this.repaymentDateTime,
  });
}
