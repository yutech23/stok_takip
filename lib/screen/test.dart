import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:searchfield/searchfield.dart';

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
  TextEditingController controllerSearch = TextEditingController();

  double cashValue = 0, bankValue = 0, eftHavaleValue = 0;
  double totalPaymentValue = 0;

  String? _selectCustomerType;
  String? _customerPhone;

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
            child: SizedBox(
          width: 300,
          child: SearchField<String>(
            suggestions: ['yusuf', 'deneme']
                .map(
                  (e) => SearchFieldListItem(
                    e,
                    item: e,
                    // Use child to show Custom Widgets in the suggestions
                    // defaults to Text widget
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(e),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(e),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        )),
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
