import 'package:adaptivex/adaptivex.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:stok_takip/bloc/bloc_expense.dart';
import 'package:stok_takip/models/expense.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/custom_dropdown/basic_dropdown_string_type.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_widgets.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import 'package:stok_takip/validations/format_decimal_3by3_financial.dart';
import 'package:stok_takip/validations/validation.dart';
import '../modified_lib/datatable_header.dart';
import '../modified_lib/responsive_datatable.dart';
import '../utilities/share_func.dart';
import '../utilities/widget_appbar_setting.dart';
import 'drawer.dart';

class ScreenExpenses extends StatefulWidget {
  const ScreenExpenses({super.key});

  @override
  State<ScreenExpenses> createState() => _ScreenExpensesState();
}

class _ScreenExpensesState extends State<ScreenExpenses> with Validation {
  final GlobalKey<FormState> _formKeyService = GlobalKey();

  late double _widthScreen;
  late Expense _service;
  final String _labelHeading = "Gider Ekranı";
  late BlocExpense _blocExpense;

  /*-------------------BAŞLANGIÇ TARİH ARALIĞI SEÇİMİ ----------------------*/

  final double _shareServiceWidth = 315;

  ///Hizmet ekleme bölümündeki tarih.
  DateTime? _selectedDateTime = DateTime.now();

  /*----------------------------------------------------------------------- */
  /*-------------------------------Popup Bölümü -----------------------------*/
  final String _labelService = "Hizmet Ekle";
  final String _labelServiceTotal = "Hizmet Tutarı";
  final String _labelServiceDescription = "Açıklama";
  final String _labelHeaderServiceSection = "Hizmet Ekleme Bölümü";
  final List<String> _paymentTypeItems = ['Nakit', 'Banka'];

  /*----------------------------------------------------------------------- */

  /*---------------------------Dropdown Menü ------------------------------- */
  String _paymentType = "Nakit";
  final TextEditingController _controllerDescription = TextEditingController();
  final TextEditingController _controllerServiceTotal = TextEditingController();

  String? _serviceTypeSave;
  void _saveServiceType(String value) {
    setState(() {
      _serviceTypeSave = value;
    });
  }

/*------------------------------------------------------------------------ */

  /*------------------DATATABLE ----------------------------------------*/
  late final List<DatatableHeader> _headers;
  List<Map<String, dynamic>> _selecteds = [];
  final double _dataTableHeightDesktop = 600;
  final double _dataTableHeightMobil = 510;
  final String _labelDescription = "Açıklama: ";
  final String _labelServiceSelect = "Hizmet Seçiniz";
  /*--------------------------ARAMA BÖLÜMÜ------------------------------- */

  ///Tarih bölümü
  DateTimeRange? _selectDateTimeRange;
  String _labelSelectedDateTime = "Tarih seçiniz";

  final String _labelGet = "Getir";

  void _getServiceType(String value) {
    _blocExpense.selectedServiceDropdown = true;
    setState(() {
      _blocExpense.selectedGetServiceDropdownValue = value;
    });
  }

  /*----------------------------------------------------------------------- */
  /*----------------------POPUP BÖLÜMÜ GÜNCELLEME VE SİLME----------------- */
  final String _labelPopupUpdateHeader = "Güncelleme";
  final GlobalKey<FormState> _formKeyUpdate = GlobalKey<FormState>();

  ///Silme İşlemi
  final String _header = "Hizmeti silmek istediğinizden emin misiniz?";
  final String _yesText = "Evet";

  /*---------------------------Güncelleme ------------------------------- */
  DateTime? _selectedPopupDateTime;
  String? _popupServiceType;
  void _getServiceTypePopup(String value) {
    setState(() {
      _popupServiceType = value;
    });
  }

  final TextEditingController _controllerPopupDescription =
      TextEditingController();
  final TextEditingController _controllerPopupServiceTotal =
      TextEditingController();

  String _popupPaymentType = "Nakit";

/*------------------------------------------------------------------------ */
  /*----------------------------------------------------------------------- */
  @override
  void initState() {
    _blocExpense = BlocExpense();
    _service = Expense();
    _headers = [];
    _headers.add(DatatableHeader(
        text: "Tarih - Saat",
        value: "saveTime",
        show: true,
        sortable: true,
        flex: 3,
        textAlign: TextAlign.start));
    _headers.add(DatatableHeader(
        text: "Hizmet",
        value: "name",
        show: true,
        flex: 3,
        sortable: true,
        textAlign: TextAlign.start));
    _headers.add(DatatableHeader(
        text: "Açıklama",
        value: "description",
        show: true,
        flex: 3,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Ödeme Türü",
        value: "paymentType",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Tutar",
        value: "total",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Sil ve Güncelle",
        value: "detail",
        show: true,
        sortable: false,
        flex: 2,
        sourceBuilder: (value, row) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ///Silme Buttonu
              IconButton(
                iconSize: 20,
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return popupDelete(row['id']);
                    },
                  );
                },
              ),

              ///Güncelleme Buttonu
              IconButton(
                iconSize: 20,
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  popupServiceEdit(row);
                },
              )
            ],
          );
        },
        textAlign: TextAlign.center));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
    ///ekran büyüklüğü tesbiti
    _widthScreen = MediaQuery.of(context).size.width;
    getResponseWidth();
    return Form(
        key: _formKeyService,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
              child: Wrap(
            alignment: WrapAlignment.center,
            spacing: context.extensionWrapSpacing10(),
            runSpacing: context.extensionWrapSpacing10(),
            children: [
              ///Ana Bölüm Tablonun Olduğu yer
              _widthScreen <= 500
                  ? widgetMainSectionTableMobil()
                  : widgetMainSectionTableDesktop(),

              ///Hizmet Ekleme Bölümü
              SizedBox(
                width: dimension.widthSideSectionAndMobil,
                height: dimension.heightSection,
                child: Column(
                  children: [
                    widgetTextHeaderService(
                        _labelHeaderServiceSection, Colors.grey),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15)),
                            boxShadow: context.extensionBoxShadow()),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              context.extensionHighSizedBox20(),
                              shareWidgetDateTimeTextFormField(),
                              context.extensionHighSizedBox10(),
                              widgetDropdownSaveServiceType(),
                              context.extensionHighSizedBox10(),
                              widgetTextFieldDescription(
                                  _controllerDescription),
                              context.extensionHighSizedBox10(),
                              widgetRadioButtonPaymentType(),
                              context.extensionHighSizedBox10(),
                              widgetTextFieldTotal(_controllerServiceTotal),
                              context.extensionHighSizedBox10(),
                              SizedBox(
                                width: double.infinity,
                                child: widgetButtonAddService(),
                              ),
                            ]),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
        ));
  }

  Container widgetMainSectionTableDesktop() {
    return Container(
      width: dimension.widthMainSection,
      height: dimension.heightSection,
      alignment: Alignment.center,
      padding: context.extensionPadding20(),
      decoration: context.extensionThemaWhiteContainer(),
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.vertical,
        spacing: 10,
        children: [
          Row(mainAxisSize: MainAxisSize.max, children: [
            widgetDropdownGetServiceType(),
            context.extensionWidhSizedBox20(),
            widgetRangeSelectDateTime(),
            context.extensionWidhSizedBox20(),
            widgetButtonGetService(),
          ]),
          widgetDateTable()
        ],
      ),
    );
  }

  Container widgetMainSectionTableMobil() {
    return Container(
      width: dimension.widthMainSection,
      height: dimension.heightSection,
      padding: context.extensionPadding20(),
      decoration: context.extensionThemaWhiteContainer(),
      child: Wrap(
          alignment: WrapAlignment.center,
          spacing: context.extensionWrapSpacing20(),
          runSpacing: context.extensionWrapSpacing10(),
          direction: Axis.horizontal,
          children: [
            widgetDropdownGetServiceType(),
            widgetRangeSelectDateTime(),
            widgetButtonGetService(),
            widgetDateTable()
          ]),
    );
  }

  ///Verileri Getiren Button
  widgetButtonGetService() {
    return SizedBox(
      width: getResponseWidth(),
      height: dimension.heightInputTextAnDropdown40,
      child: shareWidget.widgetElevatedButton(
          onPressedDoSomething: () async {
            await _blocExpense.getServiceButton();
          },
          label: _labelGet),
    );
  }

  widgetDropdownGetServiceType() {
    return Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(vertical: 2),
        width: _widthScreen <= 500
            ? dimension.widthMobilButtonAndTextfield
            : _shareServiceWidth,
        height: dimension.heightInputTextAnDropdown40,
        child: BasicDropdown(
          hint: _labelServiceSelect,
          selectValue: _blocExpense.selectedGetServiceDropdownValue,
          itemList: sabitler.listDropdownService,
          getShareDropdownCallbackFunc: _getServiceType,
          borderColor: context.extensionDefaultColor,
        ));
  }

  /*----------------------------Hizmet Tablosu ------------------------------ */
  widgetDateTable() {
    return SizedBox(
      width: dimension.widthTable,
      height:
          _widthScreen <= 500 ? _dataTableHeightMobil : _dataTableHeightDesktop,
      child: Card(
        margin: const EdgeInsets.only(top: 5),
        elevation: 5,
        shadowColor: Colors.black,
        clipBehavior: Clip.none,
        child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _blocExpense.getStreamListService,
            builder: (context, snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {}

              return ResponsiveDatatable(
                reponseScreenSizes: const [ScreenSize.xs],
                headers: _headers,
                source: snapshot.data,
                selecteds: _selecteds,
                expanded: _blocExpense.getterListExpanded,
                autoHeight: false,
                dropContainer: (value) {
                  return Padding(
                      padding: const EdgeInsets.all(12),
                      child: RichText(
                          text: TextSpan(
                              text: _labelDescription,
                              style: context.theme.titleSmall!.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                              children: [
                            TextSpan(
                                style: context.theme.titleSmall,
                                text: value['description'])
                          ])));
                },
                sortAscending: true,
                headerDecoration: BoxDecoration(
                    color: Colors.blueGrey.shade900,
                    border: const Border(
                        bottom: BorderSide(color: Colors.red, width: 1))),
                selectedDecoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.red, width: 1)),
                  color: Colors.green,
                ),
                headerTextStyle:
                    context.theme.titleMedium!.copyWith(color: Colors.white),
                rowTextStyle: context.theme.titleSmall,
                selectedTextStyle: const TextStyle(color: Colors.grey),
              );
            }),
      ),
    );
  }

  /*-------------------------TARİH BÖLÜMÜ ARAMA BÖLÜMÜ --------------------- */

  ///Zaman Aralı Seçildiği yer
  widgetRangeSelectDateTime() {
    return Container(
        width: _widthScreen <= 500
            ? dimension.widthMobilButtonAndTextfield
            : _shareServiceWidth,
        height: dimension.heightInputTextAnDropdown40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: context.extensionDefaultColor),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: TextButton.icon(
            onPressed: () async {
              await pickDateRange();
            },
            icon: Icon(
              Icons.date_range,
              color: context.extensionDefaultColor,
            ),
            label: Text(
              _labelSelectedDateTime,
              style: context.theme.titleSmall,
            )));
  }

  ///Tarihin seçilip geldiği yer.
  pickDateRange() async {
    _selectDateTimeRange = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(
            start: _blocExpense.getterStartDate,
            end: _blocExpense.getterEndDate),
        firstDate: DateTime(2010),
        lastDate: DateTime(2035),
        helpText: "Zaman Aralığı Seçiniz",
        saveText: "Tamam",
        builder: (context, child) {
          return Column(
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
          );
        });

    if (_selectDateTimeRange != null) {
      //tarih seçildiğini belirtiyor. ve buna göre getir Buttonunu ona göre çağırıyor.
      _blocExpense.selectedDateTime = true;

      ///seçilen tarih ataması yapılıyor.
      _blocExpense.setDateRange(_selectDateTimeRange!);

      ///Ekrana tarihi basıyor.
      setState(() {
        _labelSelectedDateTime =
            "${shareFunc.dateTimeConvertFormatStringWithoutTime(_selectDateTimeRange!.start)} - ${shareFunc.dateTimeConvertFormatStringWithoutTime(_selectDateTimeRange!.end)}";
      });
    }
  }

  /*----------------------------------------------------------------------- */

/*-----------------------Hizmet Ekleme Bölümü-------------------------------- */

  //Dropdown popup içinde
  widgetDropdownSaveServiceType() {
    return Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(vertical: 2),
        width: _shareServiceWidth,
        height: 70,
        child: BasicDropdown(
          validator: validateNotEmpty,
          hint: _labelService,
          itemList: sabitler.listDropdownService,
          getShareDropdownCallbackFunc: _saveServiceType,
          selectValue: _serviceTypeSave,
          borderColor: context.extensionDisableColor,
        ));
  }

  widgetTextFieldDescription(TextEditingController controller) {
    return SizedBox(
      width: _shareServiceWidth,
      child: TextField(
        decoration: InputDecoration(
            hintText: _labelServiceDescription,
            border: OutlineInputBorder(
                borderSide: BorderSide(color: context.extensionDisableColor))),
        controller: controller,
        maxLines: 4,
        style: context.theme.titleSmall,
      ),
    );
  }

  widgetRadioButtonPaymentType() {
    return SizedBox(
      width: _shareServiceWidth,
      child: RadioGroup<String>.builder(
        activeColor: context.extensionDefaultColor,
        direction: Axis.horizontal,
        groupValue: _paymentType,
        onChanged: (p0) {
          setState(() {
            _paymentType = p0!;
          });
        },
        items: _paymentTypeItems,
        itemBuilder: (value) => RadioButtonBuilder(value,
            textPosition: RadioButtonTextPosition.right),
      ),
    );
  }

  widgetTextFieldTotal(TextEditingController controller) {
    return SizedBox(
      width: _shareServiceWidth,
      height: dimension.heightInputTextAnDropdown40,
      child: TextFormField(
        decoration: InputDecoration(
            hintText: _labelServiceTotal,
            border: OutlineInputBorder(
                borderSide: BorderSide(color: context.extensionDisableColor))),
        controller: controller,
        inputFormatters: [FormatterDecimalThreeByThreeFinancial()],
      ),
    );
  }

  ///Hizmet Ekleme Buttonu
  widgetButtonAddService() {
    return ElevatedButton.icon(
        onPressed: () {
          if (_formKeyService.currentState!.validate()) {
            _service.name = _serviceTypeSave!;
            _service.saveTime = _selectedDateTime!;
            _service.description = _controllerDescription.text;
            _service.paymentType = _paymentType;
            _service.total = FormatterConvert()
                .commaToPointDouble(_controllerServiceTotal.text);
            _service.currentUserId = shareFunc.getCurrentUserId();
            _blocExpense.serviceAdd(_service).then((value) {
              if (value.isEmpty) {
                _blocExpense.getServiceWithRangeDate();
                context.noticeBarTrue("İşlem Başarılı", 2);
                setState(() {
                  _selectedDateTime = DateTime.now();
                  // _serviceTypeSave = 'Hizmet Ekle';
                  _paymentType = 'Nakit';
                  _controllerDescription.clear();
                  _controllerServiceTotal.clear();
                });
              } else {
                context.noticeBarError("Hata \n $value", 3);
              }
            });
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_labelService));
  }

/*------------------------------------------------------------------------- */
/*-------------------------TARİH BÖLÜMÜ  Hizmet Ekleme----------------------- */
  ///Zaman Text
  shareWidgetDateTimeTextFormField() {
    return Container(
        width: _shareServiceWidth,
        height: dimension.heightInputTextAnDropdown40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: TextButton.icon(
            onPressed: () async {
              _selectedDateTime = await pickDate() ?? DateTime.now();
              TimeOfDay? timeRes = await pickTime();

              setState(() {
                if (timeRes != null) {
                  _selectedDateTime = _selectedDateTime!.add(
                      Duration(hours: timeRes.hour, minutes: timeRes.minute));
                }
              });
            },
            icon: Icon(
              Icons.date_range,
              color: context.extensionDefaultColor,
            ),
            label: Text(
              shareFunc.dateTimeConvertFormatString(_selectedDateTime!),
              style: context.theme.titleSmall,
            )));
  }

  ///Tarih seçildiği yer.
  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime(2050),
      );

  ///Saat seçildiği yer.
  Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

  widgetTextHeaderService(String label, Color backgroundColor) {
    TextStyle styleHeader =
        context.theme.titleLarge!.copyWith(color: Colors.white);
    return Container(
      alignment: Alignment.center,
      width: dimension.widthSideSectionAndMobil,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          color: backgroundColor, boxShadow: context.extensionBoxShadow()),
      child: Text(
        label,
        style: styleHeader,
      ),
    );
  }

  /*----------------------------------------------------------------------- */

  ///Ekran büyüklüğüne göre ayarlama
  double getResponseWidth() {
    double resWidth = MediaQuery.of(context).size.width >= 500
        ? 160
        : dimension.widthMobilButtonAndTextfield;
    return resWidth;
  }

  /*------------------------Popup Widgetları--------------------------- */
  //Dropdown popup içinde
  widgetPopupDropdownService(
      String? selectedValue, Function(String)? getShareDropdownCallbackFunc) {
    return Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(vertical: 2),
        width: _shareServiceWidth,
        height: 70,
        child: BasicDropdown(
          validator: validateNotEmpty,
          hint: _labelService,
          itemList: sabitler.listDropdownService,
          getShareDropdownCallbackFunc: getShareDropdownCallbackFunc,
          selectValue: selectedValue,
          borderColor: context.extensionDisableColor,
        ));
  }

  ///Popup zaman aralığı
  widgetPopupDateTimeTextFormField(Function(void Function()) setState) {
    return Container(
        width: _shareServiceWidth,
        height: dimension.heightInputTextAnDropdown40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: TextButton.icon(
            onPressed: () async {
              _selectedPopupDateTime = await pickDate() ?? DateTime.now();
              TimeOfDay? timeRes = await pickTime();

              setState(() {
                if (timeRes != null) {
                  _selectedPopupDateTime = _selectedPopupDateTime!.add(
                      Duration(hours: timeRes.hour, minutes: timeRes.minute));
                }
              });
            },
            icon: Icon(
              Icons.date_range,
              color: context.extensionDefaultColor,
            ),
            label: Text(
              shareFunc.dateTimeConvertFormatString(_selectedPopupDateTime!),
              style: context.theme.titleSmall,
            )));
  }

  widgetPopupRadioButtonPaymentType(Function(void Function()) setState) {
    return SizedBox(
      width: _shareServiceWidth,
      child: RadioGroup<String>.builder(
        activeColor: context.extensionDefaultColor,
        direction: Axis.horizontal,
        groupValue: _popupPaymentType,
        onChanged: (p0) {
          setState(() {
            _popupPaymentType = p0!;
          });
        },
        items: _paymentTypeItems,
        itemBuilder: (value) => RadioButtonBuilder(value,
            textPosition: RadioButtonTextPosition.right),
      ),
    );
  }

  /*----------------------------------------------------------------------- */
  /*-------------------POPUP SİLME ve GÜNCELLEME------------------------- */
  popupServiceEdit(Map<String?, dynamic> selectedService) {
    _controllerPopupDescription.text = selectedService['description'];
    _controllerPopupServiceTotal.text = FormatterConvert()
        .commaToPointDouble(selectedService['total'])
        .toString();
    _popupPaymentType = selectedService['paymentType'];
    _popupServiceType = selectedService['name'];
    _selectedPopupDateTime =
        shareFunc.dateTimeStringConvertToDateTime(selectedService['saveTime']);

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(_labelPopupUpdateHeader,
                textAlign: TextAlign.center,
                style: context.theme.titleLarge!
                    .copyWith(fontWeight: FontWeight.bold)),
            alignment: Alignment.center,
            content: SingleChildScrollView(
              child: Form(
                key: _formKeyUpdate,
                child: Container(
                  width: 360,
                  padding: context.extensionPadding10(),
                  alignment: Alignment.center,
                  child: Wrap(
                      alignment: WrapAlignment.center,
                      direction: Axis.vertical,
                      spacing: 10,
                      children: [
                        widgetPopupDateTimeTextFormField(setState),
                        widgetPopupDropdownService(
                            _popupServiceType, _getServiceTypePopup),
                        widgetTextFieldDescription(_controllerPopupDescription),
                        widgetPopupRadioButtonPaymentType(setState),
                        widgetTextFieldTotal(_controllerPopupServiceTotal)
                      ]),
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: <Widget>[
              SizedBox(
                width: 120,
                height: 40,
                child: ElevatedButton(
                    onPressed: () async {
                      Expense updateService = Expense();
                      updateService.saveTime = _selectedPopupDateTime!;
                      updateService.id = selectedService['id'];
                      updateService.name = _popupServiceType!;
                      updateService.description =
                          _controllerPopupDescription.text;
                      updateService.paymentType = _popupPaymentType;
                      updateService.total = FormatterConvert()
                          .commaToPointDouble(
                              _controllerPopupServiceTotal.text);
                      updateService.currentUserId =
                          shareFunc.getCurrentUserId();

                      String res =
                          await _blocExpense.updateService(updateService);
                      if (res.isEmpty) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                        // ignore: use_build_context_synchronously
                        await context.noticeBarTrue("İşlem Başarılı", 2);
                      } else {
                        // ignore: use_build_context_synchronously
                        context.noticeBarError("Hata : $res", 3);
                      }
                    },
                    child: Text("Yes",
                        style: context.theme.titleSmall!
                            .copyWith(color: Colors.white))),
              ),
              SizedBox(
                width: 120,
                height: 40,
                child: ElevatedButton(
                  child: Text("İptal",
                      style: context.theme.titleSmall!
                          .copyWith(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ///Silme popup bölümü
  popupDelete(int serviceId) {
    return AlertDialog(
      title: Text('UYARI',
          textAlign: TextAlign.center,
          style:
              context.theme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
      alignment: Alignment.center,
      content: Text(_header,
          style:
              context.theme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: <Widget>[
        SizedBox(
          width: 100,
          height: 30,
          child: ElevatedButton(
              onPressed: () async {
                ///Stok bitmeden silmeyi engelliyor.

                String res = await _blocExpense.deleteService(serviceId);
                if (res.isEmpty) {
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  await context.noticeBarTrue("İşlem başarılı.", 2);

                  // ignore: use_build_context_synchronously
                } else {
                  // ignore: use_build_context_synchronously
                  context.noticeBarError("Hata $res", 3);
                }
              },
              child: Text(_yesText,
                  style:
                      context.theme.titleSmall!.copyWith(color: Colors.white))),
        ),
        SizedBox(
          width: 100,
          height: 30,
          child: ElevatedButton(
            child: Text("İptal",
                style: context.theme.titleSmall!.copyWith(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  ///True demek Mobil Ekran false ise Masaüstü
  bool getResponseScreen() {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth <= 500 ? true : false;
  }
}
