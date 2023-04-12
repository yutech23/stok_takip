import 'package:flutter/material.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/database_mango.dart';
import 'package:stok_takip/models/user.dart';
import 'package:stok_takip/utilities/custom_dropdown/widget_dropdown_roles.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_widgets.dart';
import 'package:stok_takip/validations/validation.dart';

import '../utilities/widget_appbar_setting.dart';
import 'drawer.dart';

class ScreenSignUp extends StatefulWidget {
  const ScreenSignUp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ScreenSignUpState();
  }
}

class _ScreenSignUpState extends State with Validation {
  /* Buradaki Keyi form atıyoruz. Bu sayede ormKey ismini verdiğimiz anahtarın
   kullanıldığı Form() içerisindeki bütün TextFormField’ların validator özelliği
    tetiklenir.
  */
  final formKey = GlobalKey<FormState>();

  late final TextEditingController _controllerName;
  late final TextEditingController _controllerLastName;
  late final TextEditingController _controllerEmail;
  late final TextEditingController _controllerPassword;
  late final TextEditingController _controllerRePassword;
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

  @override
  void initState() {
    _controllerName = TextEditingController();
    _controllerLastName = TextEditingController();
    _controllerEmail = TextEditingController();
    _controllerPassword = TextEditingController();
    _controllerRePassword = TextEditingController();
    kullanici = Kullanici();

    super.initState();
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerLastName.dispose();
    _controllerName.dispose();
    _controllerPassword.dispose();
    _controllerRePassword.dispose();
    formKey.currentState!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Kullanıcı Oluşturma Ekranı",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          const ShareWidgetAppbarSetting(),
        ],
      ),
      body: buildSignUp(context),
      drawer: const MyDrawer(),
    );
  }

  Widget buildSignUp(BuildContext context) {
    return Form(
      key: formKey,
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
            height: 700,
            width: 400,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              shareWidget.widgetTextFieldInput(
                  controller: _controllerName,
                  etiket: "Adınızı Giriniz",
                  skipTravelFocusValue: false,
                  karakterGostermeDurumu: false,
                  validationFunc: validateFirstAndLastName),
              const SizedBox(height: 20),
              shareWidget.widgetTextFieldInput(
                  controller: _controllerLastName,
                  etiket: "Soyadınız Giriniz",
                  skipTravelFocusValue: false,
                  karakterGostermeDurumu: false,
                  validationFunc: validateFirstAndLastName),
              const SizedBox(height: 20),
              shareWidget.widgetTextFieldInput(
                  controller: _controllerEmail,
                  etiket: "Email Adresinizi Giriniz",
                  skipTravelFocusValue: false,
                  karakterGostermeDurumu: false,
                  validationFunc: validateEmail),
              const SizedBox(height: 20),
              widgetTextFieldPassword(_controllerPassword, "Şifrenizi Giriniz",
                  obscureValue, validatePassword),
              const SizedBox(height: 20),
              widgetTextFieldPasswordConfirm(
                  _controllerRePassword,
                  "Şifrenizi Tekrar Giriniz",
                  confirmObscureValue,
                  validateConfirmPassword),
              const SizedBox(height: 20),
              widgetSwitchButtonPartner(),
              const SizedBox(height: 20),
              WidgetDropdownRoles(_role, _getRole),
              const SizedBox(height: 20),
              buttonSave(context),
            ]),
          ),
        ),
      ),
    );
  }

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

//Kullanıcı oluşturma kayıt buttonu.
  buttonSave(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        /*   print(kullanici.name);
        print(kullanici.lastName);
        print(kullanici.email);
        print(kullanici.password);
        print(kullanici.role); */

        String checkEmail = await db.controllerUserEmail(_controllerEmail.text);
        if (checkEmail == "") {
          if (formKey.currentState!.validate()) {
            //oturm açık olan kullanıcı id alıyor.
            kullanici.isActiveUser = dbHive.getValues('uuid');
            kullanici.name = _controllerName.text;
            kullanici.lastName = _controllerLastName.text;
            kullanici.email = _controllerEmail.text;
            kullanici.password = _controllerPassword.text;
            kullanici.role = _role;
            kullanici.isPartner = _switchPartnerValue;
            db.signUpMy(kullanici).then((value) {
              if (value.isEmpty) {
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
            // ignore: use_build_context_synchronously
            context.noticeBarError("Gerekli Alanları Doldurun.", 2);
          }
        } else {
          // ignore: use_build_context_synchronously
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
}
