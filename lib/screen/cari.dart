import 'package:adaptivex/adaptivex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/bloc/bloc_cari.dart';
import 'package:stok_takip/modified_lib/searchfield.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_widgets.dart';

import '../modified_lib/datatable_header.dart';
import '../modified_lib/responsive_datatable.dart';
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
  final double _shareMaxWidth = 1200;
  final double _shareHeightInputTextField = 40;
  final String _labelHeading = "Cari Hesaplar";
  final String _labelInvoice = "Fatura No";
  final String _labelSearchInvoice = "Fatura No ile";
  late final BlocCari _blocCari;
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
  /*------------------DATATABLE ----------------------------------------*/
  late final List<DatatableHeader> _headers;
  late List<Map<String, dynamic>> _sourceList;
  final List<Map<String, dynamic>> _selected = [];
  late List<bool>? _expanded;
  final double _dataTableWidth = 730;
  final double _dataTableHeight = 500;
  @override
  void initState() {
    _blocCari = BlocCari();

    /*-------------------DATATABLE--------------------------------------- */
    _sourceList = [];
    _headers = [];

    _headers.add(DatatableHeader(
        text: "Tarih - Saat",
        value: "dateTime",
        show: true,
        sortable: true,
        flex: 3,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Tür",
        value: "type",
        show: true,
        flex: 2,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Müşteri İsmi",
        value: "customerName",
        show: true,
        flex: 3,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Fatura No",
        value: "invoiceNumber",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Toplam Tutar",
        value: "totalPrice",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Ödenen Tutar",
        value: "payment",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Kalan Tutar",
        value: "balance",
        show: true,
        sortable: false,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Detay",
        value: "detail",
        show: true,
        sortable: false,
        flex: 2,
        sourceBuilder: (value, row) {
          return Container(
            alignment: Alignment.topRight,
            child: IconButton(
              padding: const EdgeInsets.only(bottom: 20),
              alignment: Alignment.center,
              icon: const Icon(Icons.list),
              onPressed: () {},
            ),
          );
        },
        textAlign: TextAlign.center));
    _sourceList.add({
      //  'productId': item['product_id'],
      'dateTime': "02/12/2023 14:30",
      'type': 'Holding',
      'customerName': 'YUSUF COŞKKUN Karahan',
      'invoiceNumber': 23,
      'totalPrice': 200000.56,
      'payment': 100000002,
      'balance': 50000
    });
    _expanded = List.generate(_sourceList[0].length, (index) => false);

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
                alignment: WrapAlignment.start,
                runSpacing: context.extensionWrapSpacing10(),
                spacing: context.extensionWrapSpacing20(),
                direction: Axis.horizontal,
                children: [
                  Column(children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      runSpacing: context.extensionWrapSpacing10(),
                      spacing: context.extensionWrapSpacing10(),
                      children: [
                        //Tarih Bölümü Seçme
                        widgetRangeSelectDateTime(),
                        //Fatura Kodu ile Arama Bölümü
                        Wrap(
                          direction: Axis.vertical,
                          verticalDirection: VerticalDirection.down,
                          alignment: WrapAlignment.center,
                          spacing: context.extensionWrapSpacing10(),
                          runSpacing: context.extensionWrapSpacing10(),
                          children: [
                            widgetSearchFieldInvoice(),
                          ],
                        ),
                      ],
                    ),
                    context.extensionHighSizedBox10(),
                    widgetGetCariByName(),
                    widgetDateTable(),
                  ]),
                  Container(
                    width: 360,
                    height: 800,
                    color: Colors.amber,
                  )
                ]),
          )),
        ));
  }

  ///Fatura no ile arama
  widgetSearchFieldInvoice() {
    return SizedBox(
      width: _shareMinWidth,
      height: _shareHeightInputTextField,
      child: Row(children: [
        Expanded(
            child: shareWidget.widgetTextFieldInput(etiket: _labelInvoice)),
        context.extensionWidhSizedBox10(),
        SizedBox(
          width: 180,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search),
            onPressed: () {},
            label: Text(_labelSearchInvoice),
          ),
        ),
      ]),
    );
  }

  ///Zaman Aralı Seçildiği yer
  widgetRangeSelectDateTime() {
    return SizedBox(
      width: _shareMinWidth,
      height: _shareHeightInputTextField,
      child: Row(
        children: [
          shareWidgetDateTimeTextFormField(
              _controllerStartDate, _labelStartDate),
          context.extensionWidhSizedBox10(),
          shareWidgetDateTimeTextFormField(_controllerEndDate, _labelEndDate),
        ],
      ),
    );
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
                )) ??
        DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7)));

//seçilen tarihler inputlara aktarılıyor.
    _controllerStartDate.text =
        dateTimeConvertFormatString(selectDateTimeRange.start);

    _controllerEndDate.text =
        dateTimeConvertFormatString(selectDateTimeRange.end);
  }

  ///Textfield ekranına basmak için DateTime verisini String çeviriyor.
  String dateTimeConvertFormatString(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  ///isim ile cari getirme
  widgetGetCariByName() {
    return SizedBox(
        width: _dataTableWidth,
        height: _shareHeightInputTextField,
        child: Row(
          children: [
            StreamBuilder<List<Map<String, String>>>(
                stream: _blocCari.getStreamAllCustomer,
                builder: (context, snapshot) {
                  List<SearchFieldListItem<String>> listSearch =
                      <SearchFieldListItem<String>>[];
                  listSearch.add(SearchFieldListItem("Veriler Yükleniyor"));

                  if (snapshot.hasData && !snapshot.hasError) {
                    listSearch.clear();

                    for (var element in snapshot.data!) {
                      listSearch.add(SearchFieldListItem(
                          "${element['type']} - ${element['name']!}",
                          item: element['type']));
                    }
                  }
                  return Expanded(
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
                      onSuggestionTap: (p0) {
                        print(p0.searchKey);
                        List<String> convertMap = p0.searchKey.split(' - ');

                        if (convertMap[0] == 'Şahıs') {
                          _blocCari.setterSelectedCustomer = {
                            'type': convertMap[0],
                            'name': convertMap[1],
                            'phone': convertMap[2]
                          };
                        } else {
                          _blocCari.setterSelectedCustomer = {
                            'type': convertMap[0],
                            'name': convertMap[1]
                          };
                        }
                      },
                      maxSuggestionsInViewPort: 6,
                    ),
                  );
                }),
            context.extensionWidhSizedBox10(),
            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                  icon: Icon(Icons.format_list_bulleted_sharp),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () async {
                    print(await _blocCari
                        .getCustomerId(_blocCari.getterSelectedCustomer));
                  },
                  label: Text(_labelGetCari)),
            ),
          ],
        ));
  }

  ///cari Liste tablosu
  widgetDateTable() {
    return SizedBox(
      width: _dataTableWidth,
      height: _dataTableHeight,
      child: ResponsiveDatatable(
        reponseScreenSizes: [ScreenSize.xs],

        ///Search kısmını oluşturuyoruz.
        actions: [
          /* Expanded(
                          child: TextField(
                        controller: _controllerTextProductCode,
                        onChanged: (value) {
                          _selectedSearchValue = value;

                          searchTextFieldFiltre(value);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Ürün Kodu ile Arama Yapınız',
                          prefixIcon: Icon(Icons.search),
                        ),
                      )) */
        ],
        headers: _headers,
        source: _sourceList,
        selecteds: _selected,
        expanded: _expanded,
        autoHeight: false,
        /* commonMobileView: true,
                    dropContainer: (value) {
                      return Text(value['productCode'] +
                          value['amountOfStock'].toString());
                    }, */
        sortColumn: 'dataTime',
        footers: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.amber),
              height: 50, //Fotter kısmın yüksekliği bozulmasın diye belirtim
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: RichText(
                text: TextSpan(
                    text: "Toplam ürün sayısı : ",
                    style: context.theme.headline6,
                    children: [
                      TextSpan(
                          text: "200",
                          style: context.theme.headline6!.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.red)),
                    ]),
              ),
            ),
          ),
        ],
        headerDecoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            border:
                const Border(bottom: BorderSide(color: Colors.red, width: 1))),
        selectedDecoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Colors.green[300]!, width: 1)),
          color: Colors.green,
        ),
        headerTextStyle:
            context.theme.titleMedium!.copyWith(color: Colors.white),
        rowTextStyle: context.theme.titleSmall,
        selectedTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  ///Zaman Aralık için textformfiled
  Expanded shareWidgetDateTimeTextFormField(
      TextEditingController controller, String label) {
    return Expanded(
        child: TextFormField(
      textAlign: TextAlign.start,
      controller: controller,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(top: 40),
          prefixIcon: IconButton(
            color: context.extensionDefaultColor,
            icon: const Icon(Icons.date_range),
            onPressed: () async => await pickDateRange(),
          ),
          counterText: "",
          labelText: label,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          )),
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))
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
