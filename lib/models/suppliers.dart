// ignore_for_file: public_member_api_docs, sort_constructors_first
class Supplier {
  String name;
  String phone;
  String adress;
  String city;
  String district;
  String taxNumber;
  String taxOffice;
  String? cargoNumber;
  String? cargoCompany;
  String? bankName;
  String? iban;

  Supplier({
    required this.name,
    required this.phone,
    required this.adress,
    required this.city,
    required this.district,
    required this.taxNumber,
    required this.taxOffice,
    this.cargoNumber,
    this.cargoCompany,
    this.bankName,
    this.iban,
  });
}
