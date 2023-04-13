import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:searchfield/searchfield.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ScreenTest extends StatefulWidget {
  const ScreenTest({super.key});

  @override
  State<ScreenTest> createState() => _ScreenTestState();
}

String sum = "none";

class _ScreenTestState extends State<ScreenTest> {
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

  PhoneController _controllerPhone = PhoneController(null);
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
                          const SizedBox(
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
            onPressed: () async {
              final res = await db.supabase.from('auth').select();
              print(res);
            },
            child: Text("dene")),
        SizedBox(
          height: 40,
        ),
        SizedBox(
          width: 300,
          child: PhoneFormField(
              defaultCountry: IsoCode.TR,
              isCountryChipPersistent: true,
              countrySelectorNavigator: CountrySelectorNavigator.bottomSheet(),
              controller: _controllerPhone,
              decoration: const InputDecoration(
                  labelText: 'Telefon Numarısı Giriniz',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ))),
        ),
        ElevatedButton(
            onPressed: () {
              print(_controllerPhone.value!.countryCode);
              print(_controllerPhone.value!.nsn);
            },
            child: Text("dene")),
      ],
    ));
  }
}
