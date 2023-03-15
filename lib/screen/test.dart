import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr/qr.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/database_mango.dart';
import 'package:stok_takip/data/user_security_storage.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
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
  TextEditingController controllerTest = TextEditingController();
  TextEditingController controllerBankValue = TextEditingController();
  TextEditingController controllerEftHavaleValue = TextEditingController();
  TextEditingController controllerPaymentTotal = TextEditingController();

  double cashValue = 0, bankValue = 0, eftHavaleValue = 0;
  double totalPaymentValue = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Center(
          child: Container(
              width: 300,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
              child: TextFormField(
                controller: controllerTest,
              )),
        ),
        ElevatedButton(
            onPressed: () {
              String valueString =
                  controllerTest.text.replaceAll(RegExp(r'[₺$€.]'), '');

              print(double.parse(valueString.replaceAll(RegExp(r','), ".")));
            },
            child: Text("dene"))
      ],
    ));
  }
}
