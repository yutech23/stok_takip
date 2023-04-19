import 'package:adaptivex/adaptivex.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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

@RoutePage()
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
  late List<dynamic> listCustomerRegister;
  late BlocUsers _blocUsers;

/*------------------DATATABLE ----------------------------------------*/
  late final List<DatatableHeader> _headers;
  final List<Map<String, dynamic>> _selecteds = [];
  final String _labelSearchHint = 'İsim ile arama yapınız';
  final String _labelAddNewCustomer = "Yeni Kullanıcı Ekle";

  /*--------------------------ARAMA BÖLÜMÜ------------------------------- */
/*----------------------POPUP BÖLÜMÜ ŞİFRE SIFIRLAMA ----------------- */
  TextEditingController controllerPassword = TextEditingController();
  bool _isSelectedAddNewUserOrUpdate = true;
  final String _labelStatus = "Aktif";
  late String _userId;
  bool _switchStatusValue = true;
  bool _isDisableUserRoleType = false;
  final double _passwordHeight = 50;

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
          return IconButton(
            focusNode: FocusNode(skipTraversal: true),
            iconSize: 20,
            padding: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.center,
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isSelectedAddNewUserOrUpdate = false;
                _userId = row['id'];
                _controllerName.text = row['copyName'];
                _controllerLastName.text = row['last_name'];

                _switchPartnerValue = row['partner'] == 'Evet' ? true : false;
                _switchStatusValue = row['status'] == 'Aktif' ? true : false;
                _role = row['role'];
              });
            },
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
      body: buildUser(),
      drawer: const MyDrawer(),
    );
  }

  ///Widget ların oluşturulduğu builder Fonksiyonu
  buildUser() {
    return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  width: dimension.widthMainSection,
                  height: dimension.heightSection,
                  padding: context.extensionPadding20(),
                  decoration: context.extensionThemaWhiteContainer(),
                  child: widgetDateTable(),
                ),

                ///Müşteri Kayıt Bölümü
                SizedBox(
                  width: dimension.widthSideSectionAndMobil,
                  height: dimension.heightSection,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ///Yeni Müşteri Ekle Bölümündeki Header
                      widgetTextButtonNewUser(),

                      ///kayıt Bölümündeki verilerin girildiği yer
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                                Visibility(
                                  visible: _isSelectedAddNewUserOrUpdate,
                                  child: Column(
                                    children: [
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
                                    ],
                                  ),
                                ),
                                widgetSwitchButtonStatus(),
                                const SizedBox(height: 20),
                                widgetSwitchButtonPartner(),
                                const SizedBox(height: 20),
                                WidgetDropdownRoles(_role, _getRole),
                                const SizedBox(height: 20),
                                Visibility(
                                  visible: _isSelectedAddNewUserOrUpdate,
                                  child: widgetButtonSave(context),
                                ),
                                Visibility(
                                    visible: !_isSelectedAddNewUserOrUpdate,
                                    child: widgetButtonUpdate(context))
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  ///Yeni kayıt textButton Bölümü
  Container widgetTextButtonNewUser() {
    return Container(
      width: dimension.widthSideSectionAndMobil,
      height: 40,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: Colors.blueGrey.shade100,
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 8)
          ]),
      child: TextButton.icon(
        onPressed: () {
          setState(() {
            _controllerName.clear();
            _controllerLastName.clear();
            _switchPartnerValue = false;
            _isSelectedAddNewUserOrUpdate = true;
            _isDisableUserRoleType = false;
          });
        },
        icon: Icon(Icons.add, color: context.extensionDefaultColor),
        label: Text(
          _labelAddNewCustomer,
          style:
              context.theme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        style: ButtonStyle(
            overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return Colors.blueGrey.shade700.withOpacity(0.2);
          }
          return null;
        })),
      ),
    );
  }

  /*--------------Müşteri Gösterme,Düzenleme, Silme Tablosu ---------------- */
  widgetDateTable() {
    return Card(
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
                border: Border(bottom: BorderSide(color: Colors.red, width: 1)),
                color: Colors.green,
              ),
              headerTextStyle:
                  context.theme.titleMedium!.copyWith(color: Colors.white),
              rowTextStyle: context.theme.titleSmall,
              selectedTextStyle: const TextStyle(color: Colors.grey),
            );
          }),
    );
  }

/*-------------------------------------------------------------------------- */
//Müşteri bilgilerin girildiği input listesini içerir.

  // Şifre Widget
  widgetTextFieldPassword(TextEditingController controller, String etiket,
      bool obscureValue, String? Function(String?) validationFunc) {
    return SizedBox(
      height: _passwordHeight,
      child: TextFormField(
        validator: validationFunc,
        obscureText: obscureValue,
        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          isDense: true,
          labelText: "Şifrenizi Giriniz",
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
              focusNode: FocusNode(skipTraversal: true),
              onPressed: () {
                setState(() {
                  this.obscureValue = !this.obscureValue;
                });
              },
              icon:
                  Icon(obscureValue ? Icons.visibility_off : Icons.visibility)),
        ),
      ),
    );
  }

// Password Confirm  Widget
  widgetTextFieldPasswordConfirm(
      TextEditingController controller,
      String etiket,
      bool confirmObscureValue,
      String? Function(String?) validationFunc) {
    return SizedBox(
      height: _passwordHeight,
      child: TextFormField(
        validator: validationFunc,
        obscureText: confirmObscureValue,
        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          isDense: true,
          labelText: "Tekrar Şifrenizi Giriniz",
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
              focusNode: FocusNode(skipTraversal: true),
              onPressed: () {
                setState(() {
                  this.confirmObscureValue = !this.confirmObscureValue;
                });
              },
              icon: Icon(confirmObscureValue
                  ? Icons.visibility_off
                  : Icons.visibility)),
        ),
      ),
    );
  }

  widgetSwitchButtonPartner() {
    return Container(
      width: 360,
      height: 40,
      padding: const EdgeInsets.only(left: 10),
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

  widgetSwitchButtonStatus() {
    return Container(
      width: 360,
      height: 40,
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(color: context.extensionDisableColor))),
      child: Row(
        children: [
          Expanded(
              child: Text(_labelStatus,
                  style: context.theme.titleMedium!.copyWith(
                    color: context.extensionDisableColor,
                  ))),
          Switch(
            value: _switchStatusValue,
            onChanged: (value) {
              setState(() {
                _switchStatusValue = value;
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
  widgetButtonSave(BuildContext context) {
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
              kullanici.isActiveUser = dbHive.getValues('uuid');
              kullanici.name = _controllerName.text;
              kullanici.lastName = _controllerLastName.text;
              kullanici.email = _controllerEmail.text;
              kullanici.password = _controllerPassword.text;
              kullanici.role = _role;
              kullanici.isPartner = _switchPartnerValue;
              kullanici.status = _switchStatusValue;
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
            context.noticeBarError("Email Adresi kayıtlı.", 3);
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

  //Kullanıcı GÜNCELLEME buttonu.
  widgetButtonUpdate(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            kullanici.id = _userId;
            //oturm açık olan kullanıcı id alıyor.
            kullanici.isActiveUser = dbHive.getValues('uuid');
            kullanici.name = _controllerName.text;
            kullanici.lastName = _controllerLastName.text;
            kullanici.isPartner = _switchPartnerValue;
            kullanici.status = _switchStatusValue;
            kullanici.role = _role;
            String res = await _blocUsers.updateUser(kullanici);
            if (res.isEmpty) {
              setState(() {
                _controllerName.clear();
                _controllerLastName.clear();
                _switchPartnerValue = false;
                _switchStatusValue = false;
                _role = null;
              });
              context.noticeBarTrue("İşlem başarılı.", 2);
            } else {
              context.noticeBarError("HATA \n $res", 3);
            }
          } else {
            // ignore: use_build_context_synchronously
            context.noticeBarError("Gerekli Alanları Doldurun.", 2);
          }
        },
        child: Container(
          alignment: Alignment.center,
          height: 50,
          // ignore: prefer_const_constructors
          child: Text(
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
            "GÜNCELLE",
          ),
        ),
      ),
    );
  }
}
