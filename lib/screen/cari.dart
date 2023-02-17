import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/bloc/bloc_cari.dart';
import 'package:stok_takip/modified_lib/searchfield.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_widgets.dart';

import '../utilities/widget_appbar_setting.dart';
import '../validations/format_date_time.dart';
import 'drawer.dart';

class ScreenCari extends StatefulWidget {
  const ScreenCari({super.key});

  @override
  State<ScreenCari> createState() => _ScreenCariState();
}

class _ScreenCariState extends State<ScreenCari> {
  final _formKeyCari = GlobalKey<FormState>();
  final double _shareMinWidth = 360;
  final double _shareMaxWidth = 1000;
  final double _shareHeightInputTextField = 40;
  final String _labelHeading = "Cari Hesaplar";
  final String _labelInvoice = "Fatura No";
  final String _labelSearchInvoice = "Ara";
  late BlocCari _blocCari = BlocCari();
  /*-------------------BAŞLANGIÇ TARİH ARALIĞI SEÇİMİ ----------------------*/

  DateTimeRange? selectDateTimeRange;
  final String _labelStartDate = "Başlangıç Tarihi";
  final String _labelEndDate = "Bitiş Tarihi";
  final String _labelSelectedTime = "Tarih Seç";

  final TextEditingController _controllerStartDate = TextEditingController();
  final TextEditingController _controllerEndDate = TextEditingController();
  /*----------------------------------------------------------------------- */

  /*-------------------BAŞLANGIÇ MÜŞTERİ ADI İLE ARAMA---------------------*/
  final TextEditingController _controllerSearchByName = TextEditingController();
  final String _labelGetCari = "Cari Getir";
  final String _labelSearchCustomerName = "Müşteri Adı";
  final double _searchByNameItemHeight = 30;

  /*--------------------------------------------------------------------- */

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_labelHeading),

        actionsIconTheme: IconThemeData(color: Colors.blueGrey.shade100),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          const ShareWidgetAppbarSetting(),
        ],
      ),
      body: buildCari(),
      drawer: const MyDrawer(),
    );
  }

  Widget buildCari() {
    return Form(
        key: _formKeyCari,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
              child: Container(
            constraints: BoxConstraints(
                minWidth: _shareMinWidth, maxWidth: _shareMaxWidth),
            padding: context.extensionPadding20(),
            decoration: context.extensionThemaWhiteContainer(),
            child: Wrap(
                alignment: WrapAlignment.center,
                runSpacing: context.extensionWrapSpacing10(),
                spacing: context.extensionWrapSpacing20(),
                children: [
                  Wrap(
                    direction: Axis.vertical,
                    verticalDirection: VerticalDirection.down,
                    alignment: WrapAlignment.center,
                    spacing: context.extensionWrapSpacing20(),
                    runSpacing: context.extensionWrapSpacing10(),
                    children: [
                      widgetSearchFieldInvoice(),
                      widgetRangeSelectDateTime(),
                      widgetGetCariByName()
                    ],
                  ),
                  Wrap(
                      direction: Axis.vertical,
                      alignment: WrapAlignment.center,
                      runSpacing: context.extensionWrapSpacing10(),
                      spacing: context.extensionWrapSpacing20(),
                      children: []),
                ]),
          )),
        ));
  }

  widgetSearchFieldInvoice() {
    return SizedBox(
      width: _shareMinWidth,
      height: _shareHeightInputTextField,
      child: Row(children: [
        Expanded(
            child: shareWidget.widgetTextFieldInput(etiket: _labelInvoice)),
        context.extensionWidhSizedBox10(),
        SizedBox(
          width: 100,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search),
            onPressed: () {},
            label: Text(_labelSearchInvoice),
          ),
        ),
      ]),
    );
  }

  widgetRangeSelectDateTime() {
    return SizedBox(
        width: _shareMinWidth,
        child: Column(
          children: [
            SizedBox(
                width: _shareMinWidth,
                height: _shareHeightInputTextField,
                child: ElevatedButton.icon(
                    onPressed: () => pickDateRange(),
                    icon: const Icon(Icons.date_range),
                    label: Text(_labelSelectedTime))),
            context.extensionHighSizedBox10(),
            SizedBox(
              height: _shareHeightInputTextField,
              child: Row(
                children: [
                  Expanded(
                    child: shareWidget.widgetTextFieldInput(
                        inputFormat: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))
                        ],
                        controller: _controllerStartDate,
                        etiket: _labelStartDate),
                  ),
                  context.extensionWidhSizedBox10(),
                  Expanded(
                    child: shareWidget.widgetTextFieldInput(inputFormat: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))
                    ], controller: _controllerEndDate, etiket: _labelEndDate),
                  )
                ],
              ),
            ),
          ],
        ));
  }

  ///tarihin seçilip geldiği yer.
  Future<DateTimeRange?> pickDateRange() async {
    DateTimeRange? selectDateTimeRange;

    selectDateTimeRange = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7))),
        firstDate: DateTime(2010),
        lastDate: DateTime(2035),
        builder: (context, child) => Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: SizedBox(
                    height: 500,
                    width: 450,
                    child: child,
                  ),
                ),
              ],
            ));
//seçilen tarihler inputlara aktarılıyor.
    _controllerStartDate.text =
        dateTimeConvertFormatString(selectDateTimeRange!.start);

    _controllerEndDate.text =
        dateTimeConvertFormatString(selectDateTimeRange.end);
  }

  String dateTimeConvertFormatString(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  widgetGetCariByName() {
    return SizedBox(
        width: _shareMinWidth,
        height: _shareHeightInputTextField,
        child: Row(
          children: [
            FutureBuilder<List<Map<String, String>>>(
                future: _blocCari.getAllCustomerAndSuppliers(),
                builder: (context, snapshot) {
                  List<SearchFieldListItem<String>> listSearch =
                      <SearchFieldListItem<String>>[];
                  listSearch.add(SearchFieldListItem("Veriler Yükleniyor"));

                  if (snapshot.hasData && !snapshot.hasError) {
                    listSearch.clear();
                    for (var element in snapshot.data!) {
                      listSearch.add(SearchFieldListItem(element['name']!,
                          item: element['type']));
                    }
                  }
                  return Flexible(
                    flex: 3,
                    child: SearchField(
                      searchHeight: _shareHeightInputTextField,
                      itemHeight: _searchByNameItemHeight,
                      searchInputDecoration: InputDecoration(
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                          label: Text(_labelSearchCustomerName),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.black),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(),
                          )),
                      controller: _controllerSearchByName,
                      suggestions: listSearch,
                      maxSuggestionsInViewPort: 6,
                    ),
                  );
                }),
            context.extensionWidhSizedBox10(),
            Flexible(
              flex: 2,
              child: shareWidget.widgetElevatedButton(
                  onPressedDoSomething: () async {
                    await blocCari.getAllCustomerAndSuppliers();
                  },
                  label: _labelGetCari),
            ),
          ],
        ));
  }

  ///Müşteri adı ile arama
/*   widgetSearchFieldCustomer() {
    return StreamBuilder(
      builder: (context, snapshot) {
        if (snapshot.snapshot.hasData) {
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
            listSearch.add(
                SearchFieldListItem(element['name']!, item: element['type']));
            listSearch.add(
                SearchFieldListItem(element['phone']!, item: element['type']));
          }
          return SearchField(
            searchHeight: _shareheight,
            controller: _controllerSearchCustomer,
            searchInputDecoration: InputDecoration(
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
                label: Text(_labelSearchCustomer),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(),
                )),
            suggestions: listSearch,
            focusNode: _focusSearchCustomer,
            onSuggestionTap: (selectedValue) {
              _selectCustomerType = selectedValue.item!;

              ///Burası müşterinin id sini öğrenmek için yapılıyor. Telefon numarsı üzerinden id buluncak. telefon numarası unique. Müşteri seçer iken id çekmiyoruz güvenlik için.
              //Bunun ilk olmasının sebebi telefon numarası seçilirse diye.
              _customerPhone = selectedValue.searchKey;
              for (var element in listCustomer) {
                if (element['name'] == selectedValue.searchKey) {
                  _customerPhone = element['phone']!;
                  break;
                }
              }

              _focusSearchCustomer.unfocus();
            },
            maxSuggestionsInViewPort: 6,
          );
        }
        return Container();
      },
      streams: StreamTuple2(db.fetchSoloCustomerAndPhoneStream(),
          db.fetchCompanyCustomerAndPhoneStream()),
    );
  } */

}
