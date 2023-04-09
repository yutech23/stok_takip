import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/validation.dart';

class ScreenResetPassword extends StatefulWidget {
  const ScreenResetPassword({super.key});

  @override
  State<ScreenResetPassword> createState() => _ScreenResetPasswordState();
}

class _ScreenResetPasswordState extends State<ScreenResetPassword>
    with Validation {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controllerNewPassword;
  late final TextEditingController _controllerReNewPassword;

  final AutovalidateMode _autovalidateMode = AutovalidateMode.onUserInteraction;

  final String _labelNewPassword = "Yeni şifrenizi giriniz";
  final String _labelReNewPassword = "Yeni şifrenizi doğrulayın";
  final String _labelHeaderPassword = "Parolayı Değiştir";
  final String _labelSaveButton = "Uygula";

  bool obscureValue = true,
      confirmObscureValue = true,
      nowPassordObscureValue = true;

  @override
  void initState() {
    _controllerNewPassword = TextEditingController();
    _controllerReNewPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controllerReNewPassword.dispose();
    _controllerNewPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: true, body: buildLogin(context));
  }

  buildLogin(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
            Color(0xFF8A2387),
            Color(0xFFE94057),
            Color(0XFFF27121),
          ])),
      child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            widgetSignInContainer(),
          ])),
    );
  }

//Şifre Değiştirrme ve KayıtButton bölümü
  Container widgetSignInContainer() {
    return Container(
        height: 300,
        width: 360,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              widgetTextHeader(),
              const SizedBox(height: 20),
              widgetTextFieldPassword(_controllerNewPassword, _labelNewPassword,
                  obscureValue, validatePassword),
              const SizedBox(height: 20),
              widgetTextFieldPasswordConfirm(
                  _controllerReNewPassword,
                  _labelReNewPassword,
                  confirmObscureValue,
                  validateConfirmPassword),
              const SizedBox(height: 20),
              widgetButtonSaveNewPassword(context)
            ])));
  }

  ///Başlık
  widgetTextHeader() {
    return Text(_labelHeaderPassword,
        style: context.theme.headlineSmall!
            .copyWith(fontWeight: FontWeight.bold, letterSpacing: 1));
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
        labelText: "Yeni Şifrenizi Giriniz",
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

// Şifre Doğrulama
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
        labelText: "Yeni şifrenizi doğrulayın",
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

  //Kayıt Buttonu
  DecoratedBox widgetButtonSaveNewPassword(BuildContext context) {
    return DecoratedBox(
        decoration: context.extensionThemaButton(),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            onPressed: () async {
              ///girilen şifrelerin bir biri ile eşleşmesini kontrol ediyor.
              if (_controllerNewPassword.text ==
                      _controllerReNewPassword.text &&
                  _formKey.currentState!.validate()) {
                /* 
                   
                      ///password güncelliyor ama sadece supabase user içinde yapıyor.
                      ///şifreyi kullanıcılar tablosunda tutuluyor. göstermek için.
                      db
                          .updateUserInformation(_controllerReNewPassword.text)
                          .then((resValue) {
                        if (resValue.isEmpty) {
                          context.noticeBarTrue("İşlem başarılı.", 1);
                        } else {
                          context.noticeBarError("İşlem Başarısız", 1);
                        }
                      });
 */
              } else {
                context.noticeBarError(
                    'Düzgün giriş gerçekliştirilmemiştir.', 2);
              }
            },
            child: Container(
              alignment: Alignment.center,
              height: 50,
              child: Text(
                textAlign: TextAlign.center,
                style:
                    context.theme.headlineSmall!.copyWith(color: Colors.white),
                _labelSaveButton,
              ),
            )));
  }
}
