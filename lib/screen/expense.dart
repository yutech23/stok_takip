import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/bloc/bloc_expense.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/custom_dropdown/basic_dropdown_string_type.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_widgets.dart';
import 'package:stok_takip/validations/validation.dart';
import 'package:stok_takip/widget_share/expense_table/expense_table.dart';

import '../utilities/custom_dropdown/widget_share_dropdown_string_type.dart';
import '../utilities/widget_appbar_setting.dart';
import 'drawer.dart';

class ScreenExpenses extends StatefulWidget {
  const ScreenExpenses({super.key});

  @override
  State<ScreenExpenses> createState() => _ScreenExpensesState();
}

class _ScreenExpensesState extends State<ScreenExpenses> with Validation {
  final GlobalKey<FormState> _formKeySale = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String _labelHeading = "Gider Ekranı";
  final double _firstContainerMaxWidth = 1000;
  final double _firstContainerMinWidth = 340;
  late BlocExpense _blocExpense;
  final double _shareHeight = 40;
  /*-------------------BAŞLANGIÇ TARİH ARALIĞI SEÇİMİ ----------------------*/

  final double _dateTimeWidth = 200;
  String selectedDateTime =
      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  /*----------------------------------------------------------------------- */
  /*-------------------------------Popup Bölümü -----------------------------*/
  final String _labelService = "Hizmet Ekle";
  final String _labelHeaderService = "Hizmet Ekle";
  final TextEditingController _controllerDescription = TextEditingController();
  /*----------------------------------------------------------------------- */

  /*---------------------------Dropdown Menü ------------------------------- */
  bool _selectedService = false;

  void _getExprense(String value) {
    setState(() {
      print(value);
    });
    _selectedService = true;
  }
/*------------------------------------------------------------------------ */

  @override
  void initState() {
    _blocExpense = BlocExpense();
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
        key: _formKeySale,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
              child: Container(
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
                  widgetButtonAddService(),
                  WidgetExpansesTable(
                      blocExprenses: _blocExpense,
                      listProduct: [],
                      selectUnitOfCurrencySymbol: "₺"),
                ]),
          )),
        ));
  }

/*-----------------------Hizmet Ekleme Bölümü-------------------------------- */
  ///Hizmet Ekleme Buttonu
  widgetButtonAddService() {
    return shareWidget.widgetElevatedButton(
      label: _labelService,
      onPressedDoSomething: () {
        popupServiceAdd();
      },
    );
  }

  //Dropdown popup içinde
  widgetDropdownService() {
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 2),
        width: _dateTimeWidth,
        height: 40,
        child: BasicDropdown(
          validator: validateNotEmpty,
          hint: _labelService,
          itemList: sabitler.listDropdownService,
          getShareDropdownCallbackFunc: _getExprense,
        ));
  }

  popupServiceAdd() {
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
                        widgetRadioButtonPaymentType(),
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
  }

  widgetTextFieldDescription() {
    return SizedBox(
      width: _dateTimeWidth,
      child: TextField(
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderSide: BorderSide(color: context.extensionDisableColor))),
        controller: _controllerDescription,
        maxLines: 4,
        style: context.theme.titleSmall,
      ),
    );
  }

  widgetRadioButtonPaymentType() {
    return Row(
      children: [
        Radio(
          value: 1,
          groupValue: 1,
          onChanged: (value) {},
        ),
        Radio(
          value: 0,
          groupValue: 1,
          onChanged: (value) {},
        ),
      ],
    );
  }

/*------------------------------------------------------------------------- */
/*-----------------------------TARİH BÖLÜMÜ-------------------------------- */
  ///Zaman Text
  shareWidgetDateTimeTextFormField(Function(void Function()) setState) {
    return Container(
        width: _dateTimeWidth,
        height: _shareHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: TextButton.icon(
            onPressed: () async {
              DateTime? dateRes = await pickDate();

              setState(() {
                if (dateRes != null) {
                  selectedDateTime = dateTimeConvertFormatString(dateRes);
                }
              });
            },
            icon: Icon(
              Icons.date_range,
              color: context.extensionDefaultColor,
            ),
            label: Text(
              selectedDateTime,
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

  ///-----Textfield ekranına basmak için DateTime verisini String çeviriyor.
  String dateTimeConvertFormatString(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /*----------------------------------------------------------------------- */
}
