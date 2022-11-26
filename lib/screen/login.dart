import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/user.dart';
import 'package:stok_takip/screen/stock_edit.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/validation.dart';

import '../utilities/constants.dart';

class ScreenLogin extends StatefulWidget {
  @override
  State<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> with Validation {
  final _controllerEmail = TextEditingController();
  final _controllerSifre = TextEditingController();
  final FocusNode _loginButtonFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerSifre.dispose();
    _loginButtonFocus.dispose();
    super.dispose();
  }

  // Şifre bölümün gözüküp gözükmemesi belirleyen değişken.
  // Default Gözükmeyen olarak ayarlı.
  bool _obscureValue = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildLogin(context));
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
          child: Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Icon(
                  Icons.dashboard,
                  color: Colors.white,
                  size: 100,
                ),
                /* Image.asset(
                  'images/stock.png',
                  scale: 4,
                ), */
                context.extensionHighSizedBox20(),
                widgetTextLogo(),
                context.extensionHighSizedBox20(),
                widgetSignInContainer(),
              ]))),
    );
  }

  widgetTextLogo() {
    return Text(
      "FİRMA İSMİ",
      style: context.theme.headline4!.copyWith(color: Colors.white),
    );
  }

//E-mail, sifre ve KayıtButton bölümü
  Container widgetSignInContainer() {
    return Container(
        height: 480,
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
              const SizedBox(height: 50),
              widgetTextFieldEmail(),
              const SizedBox(height: 20),
              widgetTextFieldPassword(),
              const SizedBox(height: 50),
              widgetButtonLoginOn(context)
            ])));
  }

  widgetTextHeader() {
    return Text("HOŞGELDİNİZ", style: context.theme.headline4!);
  }

  TextFormField widgetTextFieldEmail() {
    return TextFormField(
      validator: validateEmail,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: _controllerEmail,
      decoration: const InputDecoration(
        labelText: "Email Adresinizi Giriniz",
        suffixIcon: Icon(
          FontAwesomeIcons.envelope,
          size: 20,
        ),
      ),
    );
  }

//Widget Şifre
  TextFormField widgetTextFieldPassword() {
    return TextFormField(
      validator: validatePassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: _obscureValue,
      controller: _controllerSifre,
      decoration: InputDecoration(
        labelText: "Şifrenizi Giriniz",
        suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscureValue = !_obscureValue;
              });
            },
            icon:
                Icon(_obscureValue ? Icons.visibility_off : Icons.visibility)),
      ),
      onFieldSubmitted: (value) {
        _loginButtonFocus.requestFocus();
      },
    );
  }

  //Kayıt Buttonu
  DecoratedBox widgetButtonLoginOn(BuildContext context) {
    return DecoratedBox(
        decoration: context.extensionThemaButton(),
        child: ElevatedButton(
            focusNode: _loginButtonFocus,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            onPressed: () async {
              Kullanici loginKullanici = Kullanici.nameSurnameRole();
              db
                  .singIn(context, _controllerEmail.text, _controllerSifre.text)
                  .then((value) {
                if (value['status'] == 'true') {
                  print("login içinden : ${value['access_token']}");
                  Sabitler.sessionStorageSecurty
                      .write(key: 'security_id', value: value['id']);
                  Sabitler.sessionStorageSecurty
                      .write(key: 'access_token', value: value['access_token']);

                  db.fetchNameSurnameRole(value['id']).then((item) {
                    Sabitler.sessionStorageSecurty
                        .write(key: 'name', value: item?.name);
                    Sabitler.sessionStorageSecurty
                        .write(key: 'lastName', value: item?.lastName);
                    Sabitler.sessionStorageSecurty
                        .write(key: 'role', value: item?.role);
                  });

                  Navigator.of(context).pushNamed('/signUp');
                } else {
                  _controllerSifre.clear();
                }
              });
            },
            child: Container(
              alignment: Alignment.center,
              height: 50,
              child: const Text(
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
                "GİRİŞ",
              ),
            )));
  }
}