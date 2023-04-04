// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/customer.dart';
import 'package:stok_takip/models/invoice.dart';

class BlocInvoice {
  Invoice? _invoice;
  late Customer _customerInfo;
  Invoice? get getInvoice => _invoice;
  Customer get getCustomerInfo => _customerInfo;

  getCompanyInformation() async {
    List<dynamic> companyInformation = await db.fetchMyCompanyInformation();

    _invoice = Invoice(
        name: companyInformation[0]['name'],
        address: companyInformation[0]['address'],
        phone: companyInformation[0]['phone'],
        logoPath: companyInformation[0]['logo_path'],
        instgramAddress: companyInformation[0]['instagram']);
  }

  Future<Customer> getCustomerInformation(
      String customerType, String customerPhone) async {
    final List<dynamic> resDataCustomerInfo =
        await db.fetchSelectCustomerInformation(customerType, customerPhone);

    if (customerType == "Şahıs") {
      _customerInfo = Customer.soleTrader(
        soleTraderName: resDataCustomerInfo[0]['name'],
        soleTraderLastName: resDataCustomerInfo[0]['last_name'],
        address: resDataCustomerInfo[0]['address'],
        city: resDataCustomerInfo[0]['city'],
        district: resDataCustomerInfo[0]['district'],
        phone: resDataCustomerInfo[0]['phone'],
        TCno: resDataCustomerInfo[0]['tc_no'],
        type: resDataCustomerInfo[0]['type'],
      );
    } else if (customerType == "Firma") {
      _customerInfo = Customer.company(
          companyName: resDataCustomerInfo[0]['name'],
          phone: resDataCustomerInfo[0]['phone'],
          city: resDataCustomerInfo[0]['city'],
          district: resDataCustomerInfo[0]['district'],
          address: resDataCustomerInfo[0]['address'],
          taxOffice: resDataCustomerInfo[0]['tax_office'],
          taxNumber: resDataCustomerInfo[0]['tax_number']);
    }

    return _customerInfo;
  }

  double calculatorKdvValue(int kdvRate, double totalPriceWithoutTax) {
    return totalPriceWithoutTax * (kdvRate / 100);
  }
}

BlocInvoice blocInvoice = BlocInvoice();
