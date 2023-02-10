// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/invoice.dart';

class BlocInvoice {
  Invoice? _invoice;

  getCompanyInformation() async {
    List<dynamic> companyInformation = await db.fetchMyCompanyInformation();

    _invoice = Invoice(
        name: companyInformation[0]['name'],
        address: companyInformation[0]['address'],
        phone: companyInformation[0]['phone'],
        logoPath: companyInformation[0]['logo_path']);
  }

  Invoice? get getInvoice => _invoice;
}

BlocInvoice blocInvoice = BlocInvoice();
