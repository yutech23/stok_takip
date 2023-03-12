import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:stok_takip/bloc/bloc_capital.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import 'package:stok_takip/validations/format_decimal_3by3_financial.dart';
import '../utilities/share_widgets.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/format_upper_case_text_format.dart';
import 'drawer.dart';

class ScreenCapital extends StatefulWidget {
  const ScreenCapital({super.key});

  @override
  State<ScreenCapital> createState() => _ScreenCapitalState();
}

class _ScreenCapitalState extends State<ScreenCapital> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeySupplier = GlobalKey<FormState>();
  late BlocCapital _blocCapital;

  final String _labelCapitalHeader = "Satış Ekranı";
  /*--------------------------KASA--------------------------- */
  final String _labelCashBoxHeader = "KASA";
  final String _labelCash = "Nakit";
  final String _labelBank = "Banka";
  final String _labelCashBoxTotal = "Toplam";
  /*--------------------------------------------------------- */

/*--------------------------FLOAT BUTTON--------------------------- */
  final String _labelAddbalance = "Sermaye Kasa";
  final String _labelCapitalInflow = "Sermaye Girişi";
  final String _labelCapitalOutflow = "Sermaye Çıkışı";
  /*--------------------------------------------------------- */
  /*--------------------------FLOAT BUTTON--------------------------- */
  final String _labelOpenBalanceCash = "Açılış Bakiyesi Nakit";
  final String _labelOpenBalanceBank = "Açılış Bakiyesi Banka";
  final String _labelPositiveBalance = "(+) Bakiye";
  final String _labelNegativeBalance = "(-) Bakiye";
  final TextEditingController _controllerOpenCashBox = TextEditingController();
  final TextEditingController _controllerOpenBankBox = TextEditingController();

  final String _labelSave = "Kaydet";
  /*--------------------------------------------------------- */

  @override
  void initState() {
    _blocCapital = BlocCapital();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: widgetFloatButtonMenu(context),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _labelCapitalHeader,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          const ShareWidgetAppbarSetting(),
        ],
      ),
      body: buildCapital(context),
      drawer: const MyDrawer(),
    );
  }

  Widget buildCapital(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        decoration: context.extensionThemaGreyContainer(),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                // ignore: prefer_const_literals_to_create_immutables
                boxShadow: [
                  const BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 8)
                ]),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(top: 20, bottom: 20),
            height: 800,
            width: 1200,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [widgetTableCashBox()]),
          ),
        ),
      ),
    );
  }

  ///Kasa Tablosu
  widgetTableCashBox() {
    return Container(
      width: 360,
      alignment: Alignment.centerRight,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey.shade600,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
            child: Text(
              _labelCashBoxHeader,
              style: context.theme.headline6!.copyWith(color: Colors.white),
            ),
          ),
          StreamBuilder<Map<String, dynamic>>(
              stream: _blocCapital.getStreamCashBox,
              //  initialData: {'cash': '0', 'bank': '0', 'total': '0'},
              builder: (context, snapshot) {
                if (snapshot.hasData && !snapshot.hasError) {
                  return Table(
                    columnWidths: const {
                      0: FixedColumnWidth(120),
                      1: FixedColumnWidth(120),
                      2: FixedColumnWidth(120),
                    },
                    border: TableBorder.symmetric(
                        inside: const BorderSide(color: Colors.white)),
                    children: [
                      buildRowHeader(
                          [_labelCash, _labelBank, _labelCashBoxTotal]),
                      buildRowHeader([
                        snapshot.data!['cash'],
                        snapshot.data!['bank'],
                        snapshot.data!['total'],
                      ]),
                    ],
                  );
                }
                return CircularProgressIndicator();
              }),
        ],
      ),
    );
  }

/*-----------------------------Tablo Satır Yardımcı Widgetlar--------------- */
  TableRow buildRowRight(String header, String value) => TableRow(children: [
        TableCell(
            child: Container(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(4),
                alignment: Alignment.centerRight,
                child: Text(
                  header,
                  style:
                      context.theme.titleSmall!.copyWith(color: Colors.black),
                ))),
        TableCell(
            child: Container(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.fromLTRB(15, 4, 0, 4),
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style:
                      context.theme.titleSmall!.copyWith(color: Colors.black),
                ))),
      ]);

  TableRow buildRowHeader(List<String> headers) => TableRow(
          decoration: BoxDecoration(
            color: context.extensionDisableColor,
          ),
          children: [
            for (String header in headers)
              TableCell(
                  child: Container(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      child: Text(
                        header,
                        style: context.theme.titleMedium!
                            .copyWith(color: Colors.white),
                      ))),
          ]);

/*------------------------------------------------------------------------- */
  ///Menu Buttonu
  SpeedDial widgetFloatButtonMenu(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.list_view,
      children: [
        ///Menu Button Bakiye Ekle (Kasaya)
        SpeedDialChild(
          backgroundColor: context.extensionDefaultColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: _labelAddbalance,
          onTap: () {
            widgetPopupCashBoxAddValue(context);
          },
        ),

        ///Sermaye Girişi
        SpeedDialChild(
            backgroundColor: context.extensionDefaultColor,
            child: const Icon(Icons.add, color: Colors.white),
            label: _labelCapitalInflow),

        ///Sermaye Çıkışı
        SpeedDialChild(
          backgroundColor: context.extensionDefaultColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: _labelCapitalOutflow,
        )
      ],
    );
  }

  ///Bakiye Giriş POPUP
  Future<dynamic> widgetPopupCashBoxAddValue(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              textAlign: TextAlign.center,
              _labelAddbalance,
              style: context.theme.headline5!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKeySupplier,
                // autovalidateMode: _autovalidateMode,
                child: Container(
                  padding: context.extensionPadding20(),
                  alignment: Alignment.center,
                  width: 600,
                  child: Column(children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widgetShareTextFieldFinancial(
                            _controllerOpenCashBox, _labelOpenBalanceCash),
                        context.extensionWidhSizedBox10(),
                        widgetDropdownButtonCashBalance(
                          context,
                        )
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widgetShareTextFieldFinancial(
                            _controllerOpenBankBox, _labelOpenBalanceBank),
                        context.extensionWidhSizedBox10(),
                        widgetDropdownButtonBankBalance(context),
                      ],
                    ),
                    context.extensionHighSizedBox10(),
                    widgetSaveButton()
                  ]),
                ),
              ),
            ),
          );
        });
  }

  SizedBox widgetDropdownButtonCashBalance(BuildContext context) {
    return SizedBox(
      width: context.extensionTextFieldWidth,
      height: context.extensionTextFieldHeight,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: _blocCapital.getterSelectCashBalance,
        items: [
          DropdownMenuItem(
            value: "+",
            child: Container(
              height: 30,
              alignment: Alignment.center,
              width: context.extensionTextFieldWidth,
              child: Text(_labelPositiveBalance),
            ),
          ),
          DropdownMenuItem(
            value: "-",
            child: Container(
              height: 30,
              alignment: Alignment.center,
              width: context.extensionTextFieldWidth,
              child: Text(_labelNegativeBalance),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _blocCapital.selectCashBalance = value!;
          });
        },
        hint: Container(
          alignment: Alignment.center,
          child: Text(
            "Bakiye Durumu",
            style: context.theme.titleMedium,
          ),
        ),
        decoration: const InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10)),
      ),
    );
  }

  SizedBox widgetDropdownButtonBankBalance(BuildContext context) {
    return SizedBox(
      width: context.extensionTextFieldWidth,
      height: context.extensionTextFieldHeight,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: _blocCapital.getterSelectBankBalance,
        items: [
          DropdownMenuItem(
            value: "+",
            child: Container(
              height: 30,
              alignment: Alignment.center,
              width: context.extensionTextFieldWidth,
              child: Text(_labelPositiveBalance),
            ),
          ),
          DropdownMenuItem(
            value: "-",
            child: Container(
              height: 30,
              alignment: Alignment.center,
              width: context.extensionTextFieldWidth,
              child: Text(_labelNegativeBalance),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _blocCapital.selectBankBalance = value!;
          });
        },
        hint: Container(
          alignment: Alignment.center,
          child: Text(
            "Bakiye Durumu",
            style: context.theme.titleMedium,
          ),
        ),
        decoration: const InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10)),
      ),
    );
  }

  widgetTextFieldOpenBalanceCash() {
    return shareWidget.widgetTextFieldInput(
        inputFormat: [FormatterDecimalThreeByThreeFinancial()],
        controller: _controllerOpenCashBox,
        etiket: _labelOpenBalanceCash,
        focusValue: false,
        karakterGostermeDurumu: false,
        keyboardInputType: TextInputType.number,
        style: context.theme.titleMedium);
  }

  widgetTextFieldOpenBalanceBank() {
    return shareWidget.widgetTextFieldInput(
        inputFormat: [FormatterDecimalThreeByThreeFinancial()],
        controller: _controllerOpenBankBox,
        etiket: _labelOpenBalanceBank,
        focusValue: false,
        karakterGostermeDurumu: false,
        keyboardInputType: TextInputType.number,
        style: context.theme.titleMedium);
  }

  widgetShareTextFieldFinancial(
    TextEditingController controller,
    String etiket,
  ) {
    return SizedBox(
      width: context.extensionTextFieldWidth,
      child: TextFormField(
        controller: controller,
        // validator: validationFunc,
        style: context.theme.titleMedium,

        // autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 10),
            counterText: "",
            labelText: etiket,
            /*   focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))), */
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            )),
        // focusNode: FocusNode(skipTraversal: focusValue!),
        keyboardType: TextInputType.number,
        inputFormatters: [FormatterDecimalThreeByThreeFinancial()],
      ),
    );
  }

  widgetSaveButton() {
    return SizedBox(
      width: context.extensionTextFieldWidth,
      child: shareWidget.widgetElevatedButton(
          onPressedDoSomething: () {
            _blocCapital.saveCashBox(
                _controllerOpenCashBox.text, _controllerOpenBankBox.text);
          },
          label: _labelSave),
    );
  }
}
