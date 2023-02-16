import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/modified_lib/searchfield.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_widgets.dart';

import '../utilities/widget_appbar_setting.dart';
import 'drawer.dart';

class ScreenCari extends StatefulWidget {
  const ScreenCari({super.key});

  @override
  State<ScreenCari> createState() => _ScreenCariState();
}

class _ScreenCariState extends State<ScreenCari> {
  final double _shareMinWidth = 360;
  final double _shareMaxWidth = 1000;
  final String _labelHeading = "Cari Hesaplar";
  final String _labelInvoice = "Fatura No";
  final _formKeyCari = GlobalKey<FormState>();

  /*-------------------BAŞLANGIÇ TARİH ARALIĞI SEÇİMİ ----------------------*/
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  TextEditingController _controllerStartDate = TextEditingController();
  TextEditingController _controllerEndDate = TextEditingController();
  /*----------------------------------------------------------------------- */
  @override
  void initState() {
    _startDateTime = DateTime.now();
    _endDateTime = DateTime.now().add(const Duration(days: 7));

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
                      widgetRangeSelectDateTime()
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
    ;
  }

  widgetSearchFieldInvoice() {
    return Container(
      width: _shareMinWidth,
      child: Row(children: [
        Expanded(
            child: shareWidget.widgetTextFieldInput(etiket: _labelInvoice)),
        context.extensionWidhSizedBox10(),
        SizedBox(
          width: 100,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search),
            onPressed: () {
              double labe = 10;
            },
            label: Text("Ara"),
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
                child: ElevatedButton.icon(
                    onPressed: () => pickDateRange(),
                    icon: Icon(Icons.date_range),
                    label: Text("Tarih Seç"))),
            context.extensionHighSizedBox10(),
            Row(
              children: [
                Expanded(
                    child: shareWidget.widgetTextFieldInput(
                        controller: _controllerStartDate,
                        etiket: "Başlangıç Tarihi")),
                context.extensionWidhSizedBox10(),
                Expanded(
                    child: shareWidget.widgetTextFieldInput(
                        controller: _controllerStartDate,
                        etiket: "Başlangıç Tarihi"))
              ],
            ),
          ],
        ));
  }

  Future<DateTimeRange?> pickDateRange() async {
    DateTimeRange? _selectDateTimeRange = DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 7)));

    return _selectDateTimeRange = await showDateRangePicker(
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
  }

  String dateTimeConvertFormatString(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  ///Müşteri Search Listesi
  /* widgetSearchFieldCustomer() {
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
            validator: validateNotEmpty,
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
