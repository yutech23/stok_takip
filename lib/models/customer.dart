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
  late String? CargoName;
  late String? CargoNumber;

  Customer.soleTrader(
      {required this.type,
      this.soleTraderName,
      this.soleTraderLastName,
      required this.phone,
      this.city,
      this.district,
      this.adress,
      this.taxOffice,
      this.taxNumber,
      this.CargoName,
      this.CargoNumber});
  Customer.company(
      {required this.type,
      required this.companyName,
      required this.phone,
      required this.city,
      required this.district,
      required this.adress,
      required this.taxOffice,
      required this.taxNumber,
      this.CargoName,
      this.CargoNumber});
}
