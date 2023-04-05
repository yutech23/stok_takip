class Customer {
  late String type;
  late int? id;
  late String? soleTraderName;
  late String? soleTraderLastName;
  late String? companyName;
  late String? countryCode;
  late String phone;
  late String? city;
  late String? district;
  late String? address;
  late String? taxOffice;
  late String? taxNumber;
  late String? cargoName;
  late String? cargoNumber;
  late String? bankName;
  late String? iban;
  late String? supplierName;
  // ignore: non_constant_identifier_names
  late String? TCno;

  Customer.soleTrader({
    this.type = "Şahıs",
    this.soleTraderName,
    this.soleTraderLastName,
    this.countryCode,
    required this.phone,
    this.city,
    this.district,
    this.address,
    // ignore: non_constant_identifier_names
    this.TCno,
  });
  Customer.company({
    this.type = "Firma",
    required this.companyName,
    this.countryCode,
    required this.phone,
    required this.city,
    required this.district,
    required this.address,
    required this.taxOffice,
    required this.taxNumber,
    this.cargoName,
    this.cargoNumber,
  });
  Customer.supplier({
    this.type = "Tedarikçi",
    required this.supplierName,
    this.countryCode,
    required this.phone,
    required this.city,
    required this.district,
    required this.address,
    required this.taxOffice,
    required this.taxNumber,
    this.cargoName,
    this.cargoNumber,
    this.bankName,
    this.iban,
  });
}
