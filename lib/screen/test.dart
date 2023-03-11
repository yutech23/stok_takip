import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr/qr.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/database_mango.dart';
import 'package:stok_takip/data/user_security_storage.dart';
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
  String? _selectedDropdown;
  List<DropdownMenuItem<String>> _listDropdownMenu = [];

  ///KDV seçilip Seçilmediğini kontrol ediyorum.
  late String _selectedCurrencyAbridgment;

  void _getCurrencyAbridment(String value) {
    setState(() {
      _selectedCurrencyAbridgment = value;
      print(value);
    });
  }

  @override
  void initState() {
    _listDropdownMenu.add(DropdownMenuItem(
        value: "12",
        child: Container(alignment: Alignment.center, child: Text("Yusuf"))));

    _listDropdownMenu.add(DropdownMenuItem(
        value: "13",
        child: Container(alignment: Alignment.center, child: Text("Ahmet"))));

    _listDropdownMenu.add(DropdownMenuItem(
        value: "14",
        child: Container(alignment: Alignment.center, child: Text("Mustafa"))));

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
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blue)),
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                      isCollapsed: true,
                      fillColor: Colors.green,
                      iconColor: Colors.blue,
                      contentPadding: EdgeInsets.fromLTRB(5, 10, 0, 0)),
                  iconSize: 30,
                  itemHeight: 50,
                  value: _selectedDropdown,
                  items: _listDropdownMenu,
                  alignment: Alignment.center,
                  onChanged: (value) {
                    setState(() {
                      _selectedDropdown = value;
                    });
                  },
                  hint: Container(
                      height: 30,
                      padding: EdgeInsets.zero,
                      color: Colors.red,
                      alignment: Alignment.center,
                      child: Center(child: Text("Seçiniz"))),
                ))),
        SizedBox(
          width: 300,
          height: 50,
          child: ElevatedButton(
              onPressed: () async {
                print(await db.supabase.auth.currentSession!.user.id);
              },
              child: Text("session Getir")),
        )
      ],
    ));
  }
}
