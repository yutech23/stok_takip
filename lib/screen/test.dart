import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr/qr.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

String sum = "none";

class _TestState extends State<Test> {
  ValueNotifier<double> valueNotifierProductBuyWithoutTax =
      ValueNotifier<double>(0);
  ValueNotifier<double> valueNotifierPaid = ValueNotifier<double>(0);
  ValueNotifier<double> valueNotifierBalance = ValueNotifier<double>(0);
  ValueNotifier<bool> valueNotifierButtonDateTimeState =
      ValueNotifier<bool>(false);
  TextEditingController controllerProductAmountOfStock =
      TextEditingController();
  TextEditingController controllerCashValue = TextEditingController();
  TextEditingController controllerBankValue = TextEditingController();
  TextEditingController controllerEftHavaleValue = TextEditingController();
  TextEditingController controllerPaymentTotal = TextEditingController();

  double cashValue = 0, bankValue = 0, eftHavaleValue = 0;
  double totalPaymentValue = 0;

  ///KDV seçilip Seçilmediğini kontrol ediyorum.
  late String _selectedCurrencyAbridgment;

  void _getCurrencyAbridment(String value) {
    setState(() {
      _selectedCurrencyAbridgment = value;
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
              color: Colors.amber,
              height: 70,
              child: Image.asset("asset/logo.png"))),
    );
  }
}
