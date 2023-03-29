import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/bloc/bloc_expense.dart';
import 'package:stok_takip/models/expense.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/custom_dropdown/basic_dropdown_string_type.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import 'package:stok_takip/validations/format_decimal_3by3_financial.dart';
import 'package:stok_takip/validations/validation.dart';
import 'package:stok_takip/widget_share/expense_table/expense_table.dart';
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

  late Expense _service;
  final String _labelHeading = "Gider Ekranı";
  final double _firstContainerMaxWidth = 1000;
  final double _firstContainerMinWidth = 340;
  late BlocExpense _blocExpense;
  final double _shareHeight = 40;
  /*-------------------BAŞLANGIÇ TARİH ARALIĞI SEÇİMİ ----------------------*/

  final double _shareServiceWidth = 300;
  String _selectedDateTime =
      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  /*----------------------------------------------------------------------- */
  /*-------------------------------Popup Bölümü -----------------------------*/
  final String _labelService = "Hizmet Ekle";
  final String _labelHeaderService = "Hizmet Ekle";
  final String _labelServiceTotal = "Hizmet Tutarı";
  final String _labelServiceDescription = "Açıklama";
  final String _labelHeaderServiceSection = "Hizmet Ekleme Bölümü";
  String _selectedGroupPaymentTypeValue = "Nakit";
  final List<String> _paymentTypeItems = ['Nakit', 'Banka'];
  final TextEditingController _controllerDescription = TextEditingController();
  final TextEditingController _controllerServiceTotal = TextEditingController();
  /*----------------------------------------------------------------------- */

  /*---------------------------Dropdown Menü ------------------------------- */
  String? _selectedServiceName;

  void _getExprense(String value) {
    setState(() {
      _selectedServiceName = value;
    });
  }
/*------------------------------------------------------------------------ */

  @override
  void initState() {
    _blocExpense = BlocExpense();
    _service = Expense();
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
    return Form(
        key: _formKeyService,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
              child: Wrap(
            spacing: 10,
            children: [
              Container(
                constraints: BoxConstraints(
                    minWidth: _firstContainerMinWidth,
                    maxWidth: _firstContainerMaxWidth),
                padding: context.extensionPadding20(),
                decoration: context.extensionThemaWhiteContainer(),
                child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: context.extensionWrapSpacing20(),
                    runSpacing: context.extensionWrapSpacing10(),
                    children: [
                      WidgetExpansesTable(
                          blocExprenses: _blocExpense,
                          listProduct: [],
                          selectUnitOfCurrencySymbol: "₺"),
                    ]),
              ),
              Container(
                width: 340,
                height: 600,
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                decoration: context.extensionThemaWhiteContainer(),
                child: Column(children: [
                  widgetTextHeaderService(
                      _labelHeaderServiceSection, Colors.grey),
                  context.extensionHighSizedBox20(),
                  shareWidgetDateTimeTextFormField(setState),
                  context.extensionHighSizedBox10(),
                  widgetDropdownService(),
                  context.extensionHighSizedBox10(),
                  widgetTextFieldDescription(),
                  context.extensionHighSizedBox10(),
                  widgetRadioButtonPaymentType(setState),
                  context.extensionHighSizedBox10(),
                  widgetTextFieldTotal(),
                  context.extensionHighSizedBox10(),
                  widgetButtonAddService()
                ]),
              )
            ],
          )),
        ));
  }

/*-----------------------Hizmet Ekleme Bölümü-------------------------------- */

  //Dropdown popup içinde
  widgetDropdownService() {
    return Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(vertical: 2),
        width: _shareServiceWidth,
        height: 70,
        child: BasicDropdown(
          validator: validateNotEmpty,
          hint: _labelService,
          itemList: sabitler.listDropdownService,
          getShareDropdownCallbackFunc: _getExprense,
        ));
  }

  /* popupServiceAdd() {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(_labelHeaderService,
                textAlign: TextAlign.center,
                style: context.theme.titleLarge!
                    .copyWith(fontWeight: FontWeight.bold)),
            alignment: Alignment.center,
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  width: 400,
                  padding: context.extensionPadding10(),
                  alignment: Alignment.center,
                  child: Wrap(
                      alignment: WrapAlignment.center,
                      direction: Axis.vertical,
                      spacing: 10,
                      children: [
                        shareWidgetDateTimeTextFormField(setState),
                        widgetDropdownService(),
                        widgetTextFieldDescription(),
                        widgetRadioButtonPaymentType(setState),
                        widgetTextFieldTotal()
                      ]),
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: <Widget>[
              SizedBox(
                width: 100,
                height: 30,
                child: ElevatedButton(
                    onPressed: () async {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    },
                    child: Text("Yes",
                        style: context.theme.titleSmall!
                            .copyWith(color: Colors.white))),
              ),
              SizedBox(
                width: 100,
                height: 30,
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
  } */

  widgetTextFieldDescription() {
    return SizedBox(
      width: _shareServiceWidth,
      child: TextField(
        decoration: InputDecoration(
            hintText: _labelServiceDescription,
            border: OutlineInputBorder(
                borderSide: BorderSide(color: context.extensionDisableColor))),
        controller: _controllerDescription,
        maxLines: 4,
        style: context.theme.titleSmall,
      ),
    );
  }

  widgetRadioButtonPaymentType(Function(void Function()) setState) {
    return SizedBox(
      width: _shareServiceWidth,
      child: RadioGroup<String>.builder(
        activeColor: context.extensionDefaultColor,
        direction: Axis.horizontal,
        groupValue: _selectedGroupPaymentTypeValue,
        onChanged: (p0) {
          setState(() {
            _selectedGroupPaymentTypeValue = p0!;
          });
        },
        items: _paymentTypeItems,
        itemBuilder: (value) => RadioButtonBuilder(value,
            textPosition: RadioButtonTextPosition.right),
      ),
    );
  }

  widgetTextFieldTotal() {
    return SizedBox(
      width: _shareServiceWidth,
      height: _shareHeight,
      child: TextFormField(
        decoration: InputDecoration(
            hintText: _labelServiceTotal,
            border: OutlineInputBorder(
                borderSide: BorderSide(color: context.extensionDisableColor))),
        controller: _controllerServiceTotal,
        inputFormatters: [FormatterDecimalThreeByThreeFinancial()],
      ),
    );
  }

  ///Hizmet Ekleme Buttonu
  widgetButtonAddService() {
    return ElevatedButton.icon(
        onPressed: () {
          if (_formKeyService.currentState!.validate()) {
            _service.name = _selectedServiceName!;
            _service.saveTime =
                shareFunc.dateTimeStringConvertToDateTime(_selectedDateTime);
            _service.description = _controllerDescription.text;
            _service.paymentType = _selectedGroupPaymentTypeValue;
            _service.total = FormatterConvert()
                .commaToPointDouble(_controllerServiceTotal.text);

            _blocExpense.serviceAdd(_service).then((value) {
              if (value.isEmpty) {
                context.noticeBarTrue("İşlem Başarılı", 2);
              } else {
                context.noticeBarError("Hata \n $value", 3);
              }
            });
          }
        },
        icon: Icon(Icons.add),
        label: Text(_labelService));
  }

/*------------------------------------------------------------------------- */
/*-----------------------------TARİH BÖLÜMÜ-------------------------------- */
  ///Zaman Text
  shareWidgetDateTimeTextFormField(Function(void Function()) setState) {
    return Container(
        width: _shareServiceWidth,
        height: _shareHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: TextButton.icon(
            onPressed: () async {
              DateTime? dateRes = await pickDate();
              TimeOfDay? timeRes = await pickTime();

              setState(() {
                if (dateRes != null) {
                  if (timeRes != null) {
                    dateRes = dateRes!.add(
                        Duration(hours: timeRes.hour, minutes: timeRes.minute));
                  }
                  _selectedDateTime =
                      shareFunc.dateTimeConvertFormatString(dateRes!);
                }
              });
            },
            icon: Icon(
              Icons.date_range,
              color: context.extensionDefaultColor,
            ),
            label: Text(
              _selectedDateTime,
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
        context.theme.headline6!.copyWith(color: Colors.white);
    return Container(
      alignment: Alignment.center,
      width: _shareServiceWidth,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Text(
        label,
        style: styleHeader,
      ),
    );
  }

  /*----------------------------------------------------------------------- */
}
