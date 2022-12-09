import 'package:flutter/material.dart';
import 'package:stok_takip/data/database_helper.dart';
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Kullanıcı Oluşturma Ekranı",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        actions: [
          ShareWidgetAppbarSetting(),
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
                boxShadow: [
                  BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 8)
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
                  focusValue: false,
                  karakterGostermeDurumu: false,
                  validationFunc: validateFirstAndLastName),
              const SizedBox(height: 20),
              shareWidget.widgetTextFieldInput(
                  controller: _controllerLastName,
                  etiket: "Soyadınız Giriniz",
                  focusValue: false,
                  karakterGostermeDurumu: false,
                  validationFunc: validateFirstAndLastName),
              const SizedBox(height: 20),
              shareWidget.widgetTextFieldInput(
                  controller: _controllerEmail,
                  etiket: "Email Adresinizi Giriniz",
                  focusValue: false,
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
              WidgetDropdownRoles(_getRole),
              const SizedBox(height: 40),
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
        labelText: "Şifrenizi Giriniz",
        border: OutlineInputBorder(),
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
        setState(() {
          kullanici.name = _controllerName.text;
          kullanici.lastName = _controllerLastName.text;
          kullanici.email = _controllerEmail.text;
          kullanici.password = _controllerPassword.text;
          kullanici.role = _role;
        });
        print(kullanici.name);
        print(kullanici.lastName);
        print(kullanici.email);
        print(kullanici.password);
        print(kullanici.role);

        db.signUp(context, formKey, kullanici).then((value) {
          if (value == true) {
            setState(() {
              _controllerEmail.clear();
              _controllerName.clear();
              _controllerLastName.clear();
              _controllerPassword.clear();
              _controllerRePassword.clear();
            });
          }
        });
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
}
