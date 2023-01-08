import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/service/exchange_rate.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/validation.dart';
import 'drawer.dart';

class ScreenSale extends StatefulWidget {
  const ScreenSale({super.key});

  @override
  State<ScreenSale> createState() => _ScreenSallingState();
}

class _ScreenSallingState extends State<ScreenSale> with Validation {
  final double _saleMinWidth = 360, _saleMaxWidth = 810;
  final GlobalKey<FormState> _formKeySale = GlobalKey();
  final _controllerSearchCustomer = TextEditingController();
  final _focusSearchCustomer = FocusNode();

  final String _labelHeading = "Satış Ekranı";
  final String _labelNewCustomer = "Yeni Müşteri Ekle";
  final String _labelSearchCustomer =
      "Müşteri İsmini Veya Telefon Numarası Giriniz";

  final double _widthSearch = 400;

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
      body: buildSale(),
      drawer: const MyDrawer(),
    );
  }

  buildSale() {
    return Form(
        key: _formKeySale,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
              child: Container(
            constraints: BoxConstraints(
                minWidth: _saleMinWidth, maxWidth: _saleMaxWidth),
            padding: context.extensionPadding20(),
            decoration: context.extensionThemaWhiteContainer(),
            child: Wrap(spacing: context.extensionWrapSpacing20(), children: [
              Column(children: [
                Wrap(
                  spacing: context.extensionWrapSpacing20(),
                  children: [
                    widgetSearchFieldCustomer(),
                    widgetButtonNewCustomer()
                  ],
                ),
              ]),
              SizedBox(
                width: 210,
                child: Table(
                  columnWidths: {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
                  border: TableBorder.all(),
                  children: [
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            style: context.theme.headline6!
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            "USD : "),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            textAlign: TextAlign.start,
                            style: context.theme.headline6!
                                .copyWith(fontWeight: FontWeight.bold),
                            "_usdValue"),
                      )
                    ]),
                    TableRow(children: [Text("USD :"), Text("EURO")])
                  ],
                ),
              )
            ]),
          )),
        ));
  }

  buildRow(List<String> cells) =>
      TableRow(children: [Text("USB"), Text("EURO")]);

  ///Yeni Müşteri Ekleme
  ElevatedButton widgetButtonNewCustomer() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(minimumSize: const Size(220, 60)),
      icon: const Icon(Icons.person_add),
      onPressed: () {
        exchangeRateService.getExchangeRate();
        db.fetchCustomerAndPhone();
      },
      label: Text(_labelNewCustomer),
    );
  }

  ///Müşteri Search Listesi
  widgetSearchFieldCustomer() {
    return SizedBox(
      width: _widthSearch,
      child: FutureBuilder<List<String>>(
        builder: (context, snapshot) {
          if (!snapshot.hasError && snapshot.hasData) {
            return SearchField(
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
              suggestions: snapshot.data!.map((e) {
                return SearchFieldListItem(e);
              }).toList(),
              focusNode: _focusSearchCustomer,
              onSuggestionTap: (selectedValue) {
                _focusSearchCustomer.unfocus();
              },
              maxSuggestionsInViewPort: 6,
            );
          }
          return Container();
        },
        future: db.fetchCustomerAndPhone(),
      ),
    );
  }

  Divider widgetDivider() {
    return const Divider(color: Colors.blueGrey, thickness: 2.5, height: 40);
  }
}
