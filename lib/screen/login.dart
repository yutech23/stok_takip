import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stok_takip/auth/auth_controller.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/database_mango.dart';
import 'package:stok_takip/data/user_security_storage.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/validation.dart';
import '../bloc/bloc_login.dart';

@RoutePage()
class ScreenLogin extends StatefulWidget {
  const ScreenLogin({super.key});

  @override
  State<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> with Validation {
  late BlocLogin _blocLogin;
  final _controllerEmail = TextEditingController();
  final _controllerSifre = TextEditingController();
  final FocusNode _focusLoginButton = FocusNode();
  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusPassword = FocusNode();

  bool _switchLoginToForgetPassword = false;
  final String _labelHeaderLogin = "HOŞGELDİNİZ";
  final String _labelHeaderResetPassword = "ŞİFREMİ UNUTTUM";
  final String _labelResetEmail = "Email Adresinizi Giriniz";
  final String _labelButtonLogin = "GİRİŞ";
  final String _labelButtonResetPassword = "GÖNDER";
  final String _labelLinkResetPassword = "Giriş yapmak mı istiyorsunuz?";
  final String _labelLinkLogin = "Şifrenizi mi unuttunuz?";
  final String _labelNoticeResetPassword = "E-Mail Gönderildi.";

  @override
  void initState() {
    _blocLogin = BlocLogin();
    super.initState();
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerSifre.dispose();
    _focusLoginButton.dispose();
    super.dispose();
  }

  // Şifre bölümün gözüküp gözükmemesi belirleyen değişken.
  // Default Gözükmeyen olarak ayarlı.
  bool _obscureValue = true;
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
            widgetCustomerLogo(),
            context.extensionHighSizedBox20(),
            widgetSignInContainer(),
          ])),
    );
  }

  /*  //Mehmed Abi
  widgetCustomerLogo() {
    return Image.asset(
      fit: BoxFit.fitWidth,
      'assets/logo_transparent.png',
      width: 300,
      height: 100,
    );
  } */

  ///Toplu Site için
  widgetCustomerLogo() {
    return const Icon(
      Icons.dashboard,
      color: Colors.white,
      size: 120,
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
            child: !_switchLoginToForgetPassword
                ?

                /// Giriş Ekranı
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    widgetTextHeader(_labelHeaderLogin),
                    const SizedBox(height: 50),
                    widgetTextFieldEmail(),
                    const SizedBox(height: 20),
                    widgetTextFieldPassword(),
                    const SizedBox(height: 50),
                    widgetButtonLogin(context, _labelButtonLogin),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _switchLoginToForgetPassword = true;
                              });
                            },
                            child: Text(
                              _labelLinkLogin,
                            )),
                      ],
                    )
                  ])

                ///Şifre Ekranı
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        widgetTextHeader(_labelHeaderResetPassword),
                        const SizedBox(height: 50),
                        widgetTextFieldEmail(),
                        const SizedBox(height: 30),
                        widgetButtonResetPassword(
                            context, _labelButtonResetPassword),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _switchLoginToForgetPassword = false;
                                  });
                                },
                                child: Text(_labelLinkResetPassword)),
                          ],
                        )
                      ])));
  }

  widgetTextHeader(String header) {
    return Text(header,
        style: context.theme.headlineSmall!.copyWith(
          // color: Color.fromARGB(255, 218, 90, 81),
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ));
  }

  ///Email adresi giriş
  TextFormField widgetTextFieldEmail() {
    return TextFormField(
      validator: validateEmail,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      focusNode: _focusEmail,
      controller: _controllerEmail,
      decoration: InputDecoration(
        labelText: _labelResetEmail,
        suffixIcon: const Icon(
          FontAwesomeIcons.envelope,
          size: 20,
        ),
      ),
      onFieldSubmitted: (value) =>
          _fieldFocusChange(context, _focusEmail, _focusPassword),
    );
  }

//Widget Şifre
  TextFormField widgetTextFieldPassword() {
    return TextFormField(
      validator: validatePassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: _obscureValue,
      controller: _controllerSifre,
      focusNode: _focusPassword,
      decoration: InputDecoration(
        labelText: "Şifrenizi Giriniz",
        suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscureValue = !_obscureValue;
              });
            },
            icon: Icon(_obscureValue ? Icons.visibility_off : Icons.visibility),
            focusNode: FocusNode(skipTraversal: true)),
      ),
      //Enter bastıktan sonra imleçin gideceği yeri söylendi.
      onFieldSubmitted: (value) {
        _fieldFocusChange(context, _focusPassword, _focusLoginButton);
      },
    );
  }

  //GİRİŞ Buttonu
  DecoratedBox widgetButtonLogin(BuildContext context, String label) {
    return DecoratedBox(
        decoration: context.extensionThemaButton(),
        child: ElevatedButton(
            focusNode: _focusLoginButton,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            onPressed: () async {
              ///giriş Kontrol ediliyor databasede.
              final userInfo =
                  await db.singIn(_controllerEmail.text, _controllerSifre.text);

              ///kontrol sonrası dönen değerin içinde status baklıyor.
              /// true ise giriş başarılı ve veriler Storage yazılıyor.
              if (userInfo['id'] != "") {
                // ignore: use_build_context_synchronously

                //isAuth = true yaparak s ayfa yönlenmesine auth_guard izin veriyor.
                authController.setAuthTrue();
                /*  SecurityStorageUser.setUserId(userInfo['id'].toString());
                print("ana veri tipi: ${userInfo['id'].runtimeType}");
              

                print("store : ${await SecurityStorageUser.getUserId()}"); */
                //id hive database kaydediliyor.
                dbHive.putToBox('uuid', userInfo['id']);

                SecurityStorageUser.setUserAccessToken(
                    userInfo['accessToken']!);
                SecurityStorageUser.setUserRefleshToken(
                    userInfo['refreshToken']!);

                /// User tablosundan verileri almada async yüzünden sorun yaşıyor.
                /// Verilerin çekilebilmesi için ilk önce loggin olunması gerekiyor.
                /// bu yüzden yavaşlatmak için Timer kullanıldı.
                Timer(
                  const Duration(milliseconds: 200),
                  () async {
                    final userNameSurnameRole =
                        await db.fetchNameSurnameRole(userInfo['id']);

                    ///Role Cache tutulduğu için String olmak zorunda oluyor. Ama Veritabından
                    ///int değer olarak tutuluyor.
                    authController.role =
                        userNameSurnameRole['role'].toString();
                    //Kullanı rolüne göre izinli olduğu sayfaların listesi geliyor.
                    final roleList =
                        await db.fetchPageInfoByRole(authController.role);
                    await SecurityStorageUser.setPageList(roleList);

                    SecurityStorageUser.setUserName(
                        userNameSurnameRole['name']);
                    SecurityStorageUser.setUserLastName(
                        userNameSurnameRole['last_name']);
                    SecurityStorageUser.setUserRole(
                        userNameSurnameRole['role'].toString());

                    // ignore: use_build_context_synchronously
                    await context.noticeBarTrue("Giriş başarılı.", 1);
                    if (authController.role == '1') {
                      // ignore: use_build_context_synchronously
                      context.router.pushNamed(ConstRoute.caseSnapshot);
                    } else if (authController.role == '2') {
                      // ignore: use_build_context_synchronously
                      context.router.pushNamed(ConstRoute.sale);
                    }
                  },
                );
              } else {
                // ignore: use_build_context_synchronously
                context.noticeBarError("Giriş başarısız.", 1);

                ///giriş başarılı değil ise şifre bölmünü sıfırlıyor.
                _controllerSifre.clear();
              }
            },
            child: Container(
              alignment: Alignment.center,
              height: 50,
              child: Text(
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
                label,
              ),
            )));
  }

  //Şifre Sıfırlama Buttonu
  DecoratedBox widgetButtonResetPassword(BuildContext context, String label) {
    return DecoratedBox(
        decoration: context.extensionThemaButton(),
        child: ElevatedButton(
            focusNode: _focusLoginButton,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            onPressed: () async {
              String res =
                  await _blocLogin.resetPassword(_controllerEmail.text);

              if (res.isEmpty) {
                _controllerEmail.clear();
                // ignore: use_build_context_synchronously
                await context.noticeBarTrue(_labelNoticeResetPassword, 2);

                setState(() {
                  _switchLoginToForgetPassword = false;
                });
              } else {
                // ignore: use_build_context_synchronously
                context.noticeBarError("HATA \n $res", 3);
              }
            },
            child: Container(
              alignment: Alignment.center,
              height: 50,
              child: Text(
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
                label,
              ),
            )));
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
