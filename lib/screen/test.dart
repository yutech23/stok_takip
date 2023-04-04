import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/modified_lib/searchfield.dart';

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
          child: StreamBuilder2(
            builder: (context, snapshot) {
              if (snapshot.snapshot1.hasData && snapshot.snapshot2.hasData) {
                final listCustomer = <Map<String, String>>[];
                listCustomer.clear();

                for (var item in snapshot.snapshot1.data) {
                  listCustomer.add({
                    'type': item['type'],
                    'name': "${item['name']} ${item['last_name']}",
                    'phone': item['phone']
                  });
                }
                for (var item in snapshot.snapshot2.data) {
                  listCustomer.add({
                    'type': item['type'],
                    'name': item['name'],
                    'phone': item['phone']
                  });
                }

                List<SearchFieldListItem<String>> listSearch =
                    <SearchFieldListItem<String>>[];

                for (var element in listCustomer) {
                  ///item müşterinin type atıyorum.
                  listSearch.add(SearchFieldListItem(
                      "${element['type']} - ${element['name']!} - ${element['phone']}",
                      item: element['type']));
                }
                return SearchField(
                  controller: controllerSearch,
                  searchInputDecoration: InputDecoration(
                      isDense: true,
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      label: Text("_labelSearchCustomer"),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      )),
                  suggestions: listSearch,
                  searchStyle: const TextStyle(
                    fontSize: 14,
                    //  overflow: TextOverflow.fade,
                  ),
                  onSuggestionTap: (selectedValue) {
                    ///seçilen search tümleşik olarak type-isim-numara geliyor.Burada ayırıyoruz.
                    var _customerInfoList =
                        selectedValue.searchKey.split(' - ');
                    //  print(_customerInfoList);
                    _selectCustomerType = _customerInfoList[0];

                    ///Burası müşterinin id sini öğrenmek için yapılıyor. Telefon
                    /// numarsı üzerinden id buluncak. telefon numarası unique.
                    ///  Müşteri seçer iken id çekmiyoruz güvenlik için.
                    //Bunun ilk olmasının sebebi telefon numarası seçilirse diye.

                    _customerPhone = _customerInfoList[2];
                    // print(_customerPhone);
                    /* for (var element in listCustomer) {
                  if (element['name'] == selectedValue.searchKey) {
                    _customerPhone = element['phone']!;
                    break;
                  }
                } */

                    //   _focusSearchCustomer.unfocus();
                  },
                  maxSuggestionsInViewPort: 6,
                );
              }
              return Container();
            },
            streams: StreamTuple2(db.fetchSoloCustomerAndPhoneStream(),
                db.fetchCompanyCustomerAndPhoneStream()),
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
