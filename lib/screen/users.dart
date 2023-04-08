import 'package:adaptivex/adaptivex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:stok_takip/bloc/bloc_customer_register.dart';
import 'package:stok_takip/bloc/bloc_users.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/format_lower_case_text_format.dart';
import 'package:stok_takip/validations/format_upper_case_text_format.dart';
import 'package:stok_takip/validations/validation.dart';
import '../data/database_mango.dart';
import '../models/user.dart';
import '../modified_lib/datatable_header.dart';
import '../modified_lib/responsive_datatable.dart';
import '../utilities/custom_dropdown/widget_dropdown_roles.dart';
import '../utilities/share_widgets.dart';
import '../utilities/widget_appbar_setting.dart';
import 'drawer.dart';

class ScreenUsers extends StatefulWidget {
  const ScreenUsers({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ScreenCustomerSave();
  }
}

class _ScreenCustomerSave extends State with Validation {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controllerName;
  late final TextEditingController _controllerLastName;
  late final TextEditingController _controllerEmail;
  late final TextEditingController _controllerPassword;
  late final TextEditingController _controllerRePassword;
  late final TextEditingController _controllerSearchCustomerName;
  bool _switchPartnerValue = false;
  final String _labelPartner = "Ortak";

  //Role Seçimini başka stateless Widget Çağırma Callback Func. kullanarak.
  String? _role;
  void _getRole(String value) {
    setState(() {
      _role = value;
    });
  }

  late final Kullanici kullanici;
  bool obscureValue = true, confirmObscureValue = true;

  final String _labelPageHeader = "Kullanıcı Ekranı";
  final double _sectionUserSaveWidth = 360;
  final double _sectionHeight = 800;
  late List<dynamic> listCustomerRegister;
  late BlocUsers _blocUsers;

/*------------------DATATABLE ----------------------------------------*/
  late final List<DatatableHeader> _headers;
  List<Map<String, dynamic>> _selecteds = [];
  final double _dataTableWidth = 830;

  final String _labelSearchHint = 'İsim ile arama yapınız';
  final String _labelAddNewCustomer = "Yeni Müşteri Ekle";

  /*--------------------------ARAMA BÖLÜMÜ------------------------------- */
/*----------------------POPUP BÖLÜMÜ GÜNCELLEME VE SİLME----------------- */
  bool _isNewCustomerSaveButton = true;
  bool _isUpdateButton = false;
  final String _labelUpdate = "Güncelle";
  final String _labelNewCustomerSave = "Yeni Müşteri Kaydet";
  late String _userId;

  bool _isDisableCustomerType = false;

  /*---------------------------Güncelleme ------------------------------- */
  @override
  void initState() {
    _blocUsers = BlocUsers();
    _headers = [];
    listCustomerRegister = <dynamic>[];
    _controllerName = TextEditingController();
    _controllerLastName = TextEditingController();
    _controllerEmail = TextEditingController();
    _controllerPassword = TextEditingController();
    _controllerRePassword = TextEditingController();
    _controllerSearchCustomerName = TextEditingController();
    kullanici = Kullanici();

    _headers.add(DatatableHeader(
        text: "Kullanıcı İsmi",
        value: "name",
        show: true,
        flex: 3,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "E-Mail",
        value: "email",
        show: true,
        sortable: true,
        flex: 3,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Yetki",
        value: "role",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Ortak",
        value: "partner",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Durum",
        value: "status",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Düzenle",
        value: "detail",
        show: true,
        sortable: false,
        flex: 2,
        sourceBuilder: (value, row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                focusNode: FocusNode(skipTraversal: true),
                iconSize: 20,
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                icon: const Icon(Icons.key),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return widgetPopupResetPassword(
                          row, _controllerSearchCustomerName);
                    },
                  );
                },
              ),
              IconButton(
                focusNode: FocusNode(skipTraversal: true),
                iconSize: 20,
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                icon: const Icon(Icons.edit),
                onPressed: () {
                  print(row);
                  _controllerName.text = row['copyName'];
                  _controllerLastName.text = row['last_name'];
                  _controllerEmail.text = row['email'];
                  _switchPartnerValue = row['status'] == 'Evet' ? true : false;
                  _isUpdateButton = true;
                  _isDisableCustomerType = true;
                  _isNewCustomerSaveButton = false;
                  _userId = row['user_uuid'];
                },
              ),
            ],
          );
        },
        textAlign: TextAlign.center));

    super.initState();
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerLastName.dispose();
    _formKey.currentState!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_labelPageHeader),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          const ShareWidgetAppbarSetting(),
        ],
      ),
      body: buildCustomerRegister(),
      drawer: const MyDrawer(),
    );
  }

  ///Widget ların oluşturulduğu builder Fonksiyonu
  buildCustomerRegister() {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: context.extensionThemaGreyContainer(),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: context.extensionWrapSpacing10(),
                runSpacing: context.extensionWrapSpacing10(),
                children: [
                  ///Müşteri Tablosu Bulunduğu yer.
                  Container(
                    width: _dataTableWidth,
                    height: _sectionHeight,
                    padding: context.extensionPadding20(),
                    decoration: context.extensionThemaWhiteContainer(),
                    child: widgetDateTable(),
                  ),

                  ///Müşteri Kayıt Bölümü
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ///Yeni Müşteri Ekle Bölümündeki Header
                      Container(
                        width: _sectionUserSaveWidth,
                        height: 40,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            color: Colors.blueGrey.shade100,
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                  blurRadius: 8)
                            ]),
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isNewCustomerSaveButton = true;
                              _isDisableCustomerType = false;
                              _isUpdateButton = false;
                            });
                          },
                          icon: Icon(Icons.add,
                              color: context.extensionDefaultColor),
                          label: Text(
                            _labelAddNewCustomer,
                            style: context.theme.titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          style: ButtonStyle(overlayColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return Colors.blueGrey.shade700.withOpacity(0.2);
                            }
                            return null;
                          })),
                        ),
                      ),

                      ///kayıt Bölümündeki verilerin girildiği yer
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                  blurRadius: 8)
                            ]),
                        width: _sectionUserSaveWidth,
                        height: _sectionHeight - 40,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              shareWidget.widgetTextFieldInput(
                                  controller: _controllerName,
                                  etiket: "Adınızı Giriniz",
                                  skipTravelFocusValue: false,
                                  karakterGostermeDurumu: false,
                                  validationFunc: validateFirstAndLastName,
                                  inputFormat: [
                                    FormatterUpperCaseTextFormatter()
                                  ]),
                              const SizedBox(height: 20),
                              shareWidget.widgetTextFieldInput(
                                  controller: _controllerLastName,
                                  etiket: "Soyadınız Giriniz",
                                  skipTravelFocusValue: false,
                                  karakterGostermeDurumu: false,
                                  validationFunc: validateFirstAndLastName,
                                  inputFormat: [
                                    FormatterUpperCaseTextFormatter()
                                  ]),
                              const SizedBox(height: 20),
                              shareWidget.widgetTextFieldInput(
                                  controller: _controllerEmail,
                                  etiket: "Email Adresinizi Giriniz",
                                  skipTravelFocusValue: false,
                                  karakterGostermeDurumu: false,
                                  validationFunc: validateEmail,
                                  inputFormat: [
                                    FormatterLowerCaseTextFormatter()
                                  ]),
                              const SizedBox(height: 20),
                              widgetTextFieldPassword(
                                  _controllerPassword,
                                  "Şifrenizi Giriniz",
                                  obscureValue,
                                  validatePassword),
                              const SizedBox(height: 20),
                              widgetTextFieldPasswordConfirm(
                                  _controllerRePassword,
                                  "Şifrenizi Tekrar Giriniz",
                                  confirmObscureValue,
                                  validateConfirmPassword),
                              const SizedBox(height: 20),
                              widgetSwitchButtonPartner(),
                              const SizedBox(height: 20),
                              WidgetDropdownRoles(_getRole),
                              const SizedBox(height: 20),
                              buttonSave(context),

                              /*   Visibility(
                            visible: _isNewCustomerSaveButton,
                            child: ,
                          ),
                          Visibility(
                            visible: _isUpdateButton,
                            child: ,
                          ), */
                            ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  /*--------------Müşteri Gösterme,Düzenleme, Silme Tablosu ---------------- */
  widgetDateTable() {
    return SizedBox(
      width: _dataTableWidth,
      child: Card(
        margin: const EdgeInsets.only(top: 5),
        elevation: 5,
        shadowColor: Colors.black,
        clipBehavior: Clip.none,
        child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _blocUsers.getStremAllUsers,
            builder: (context, snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {}

              return ResponsiveDatatable(
                reponseScreenSizes: const [ScreenSize.xs],
                headers: _headers,
                source: snapshot.data,
                selecteds: _selecteds,
                expanded: _blocUsers.getterDatatableExpanded,
                autoHeight: false,
                skipFocusNode: true,
                actions: [
                  Expanded(
                      child: TextField(
                    controller: _controllerSearchCustomerName,
                    onChanged: (value) {
                      _blocUsers.searchList(value);
                    },
                    decoration: InputDecoration(
                      hintText: _labelSearchHint,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ))
                ],
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

/*-------------------------------------------------------------------------- */
//Müşteri bilgilerin girildiği input listesini içerir.

  // Şifre Widget
  TextFormField widgetTextFieldPassword(
      TextEditingController controller,
      String etiket,
      bool obscureValue,
      String? Function(String?) validationFunc) {
    return TextFormField(
      validator: validationFunc,
      obscureText: obscureValue,
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: "Şifrenizi Giriniz",
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
            focusNode: FocusNode(skipTraversal: true),
            onPressed: () {
              setState(() {
                this.obscureValue = !this.obscureValue;
              });
            },
            icon: Icon(obscureValue ? Icons.visibility_off : Icons.visibility)),
      ),
    );
  }

// Password Confirm  Widget
  TextFormField widgetTextFieldPasswordConfirm(
      TextEditingController controller,
      String etiket,
      bool confirmObscureValue,
      String? Function(String?) validationFunc) {
    return TextFormField(
      validator: validationFunc,
      obscureText: confirmObscureValue,
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: "Tekrar Şifrenizi Giriniz",
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
            focusNode: FocusNode(skipTraversal: true),
            onPressed: () {
              setState(() {
                this.confirmObscureValue = !this.confirmObscureValue;
              });
            },
            icon: Icon(
                confirmObscureValue ? Icons.visibility_off : Icons.visibility)),
      ),
    );
  }

  widgetSwitchButtonPartner() {
    return Container(
      width: 360,
      height: 40,
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(color: context.extensionDisableColor))),
      child: Row(
        children: [
          Expanded(
              child: Text(_labelPartner,
                  style: context.theme.titleMedium!.copyWith(
                    color: context.extensionDisableColor,
                  ))),
          Switch(
            value: _switchPartnerValue,
            onChanged: (value) {
              setState(() {
                _switchPartnerValue = value;
              });
            },
            activeTrackColor: Colors.amberAccent,
            activeColor: context.extensionDefaultColor,
          ),
        ],
      ),
    );
  }

  //Kullanıcı oluşturma kayıt buttonu.
  buttonSave(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: () async {
          /*   print(kullanici.name);
          print(kullanici.lastName);
          print(kullanici.email);
          print(kullanici.password);
          print(kullanici.role); */

          String checkEmail =
              await db.controllerUserEmail(_controllerEmail.text);
          if (checkEmail == "") {
            if (_formKey.currentState!.validate()) {
              //oturm açık olan kullanıcı id alıyor.
              kullanici.activeUser = dbHive.getValues('uuid');
              kullanici.name = _controllerName.text;
              kullanici.lastName = _controllerLastName.text;
              kullanici.email = _controllerEmail.text;
              kullanici.password = _controllerPassword.text;
              kullanici.role = _role;
              kullanici.isPartner = _switchPartnerValue;
              db.signUpMy(kullanici).then((value) {
                if (value.isEmpty) {
                  ///Tabloyu güncelleniyor.
                  _blocUsers.getAllUsers();

                  ///Eğer search bölümü dolu ise sıfırlanıyor.
                  _controllerSearchCustomerName.clear();
                  setState(() {
                    _controllerEmail.clear();
                    _controllerName.clear();
                    _controllerLastName.clear();
                    _controllerPassword.clear();
                    _controllerRePassword.clear();
                  });
                  context.noticeBarTrue("Kayıt Başarılı", 1);
                } else {
                  context.noticeBarError("Hata gerçekleşti : $value", 2);
                }
              });
            } else {
              context.noticeBarError("Gerekli Alanları Doldurun.", 2);
            }
          } else {
            context.noticeBarError("Kullanıcı adı kayıtlı.", 3);
          }
        },
        child: Container(
          alignment: Alignment.center,
          height: 50,
          // ignore: prefer_const_constructors
          child: Text(
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
            "KAYIT",
          ),
        ),
      ),
    );
  }

  String _header = "UYARI";
  String _yesText = "Uygula";

  TextEditingController controllerPassword = TextEditingController();

  ///Silme popup bölümü
  widgetPopupResetPassword(
      Map<String?, dynamic> userInfo, TextEditingController) {
    return AlertDialog(
      title: Text('UYARI',
          textAlign: TextAlign.center,
          style:
              context.theme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
      alignment: Alignment.center,
      content: Container(
        width: 360,
        height: 400,
        child: Column(
          children: [
            shareWidget.widgetTextFieldInput(
                controller: controllerPassword, etiket: "Şifre")
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: <Widget>[
        SizedBox(
          width: 100,
          height: 30,
          child: ElevatedButton(
              onPressed: () async {
                ///Stok bitmeden silmeyi engelliyor.

                String res = await _blocUsers.resetPassword(
                    userInfo['user_uuid'],
                    userInfo['email'],
                    controllerPassword.text);
                if (res.isEmpty) {
                  //  controllerSearch.clear();
                  // ignore: use_build_context_synchronously
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
}
