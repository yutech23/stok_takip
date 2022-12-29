class Customer {
  late String type;
  late int? id;
  late String? soleTraderName;
  late String? soleTraderLastName;
  late String? companyName;
  late String phone;
  late String? city;
  late String? district;
  late String? adress;
  late String? taxOffice;
  late String? taxNumber;
  late String? cargoName;
  late String? cargoNumber;
  late String? bankName;
  late String? iban;
  late String? supplierName;

  Customer.soleTrader(
      {this.type = "Şahıs Firma",
      this.soleTraderName,
      this.soleTraderLastName,
      required this.phone,
      this.city,
      this.district,
      this.adress,
      this.taxOffice,
      this.taxNumber,
      this.cargoName,
      this.cargoNumber});
  Customer.company({
    this.type = "Kurumsal Firma",
    required this.companyName,
    required this.phone,
    required this.city,
    required this.district,
    required this.adress,
    required this.taxOffice,
    required this.taxNumber,
    this.cargoName,
    this.cargoNumber,
  });
  Customer.supplier({
    this.type = "Tedarikçi",
    required this.supplierName,
    required this.phone,
    required this.city,
    required this.district,
    required this.adress,
    required this.taxOffice,
    required this.taxNumber,
    this.cargoName,
    this.cargoNumber,
    this.bankName,
    this.iban,
  });
}
