import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stok_takip/auth/auth_controller.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/user_security_storage.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/validation.dart';

class ScreenLogin extends StatefulWidget {
  const ScreenLogin({super.key});

  @override
  State<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> with Validation {
  final _controllerEmail = TextEditingController();
  final _controllerSifre = TextEditingController();
  final FocusNode _focusLoginButton = FocusNode();
  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusPassword = FocusNode();

  @override
  void initState() {
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const Icon(
              Icons.dashboard,
              color: Colors.white,
              size: 100,
            ),
            context.extensionHighSizedBox20(),
            widgetTextLogo(),
            context.extensionHighSizedBox20(),
            widgetSignInContainer(),
          ])),
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
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      focusNode: _focusEmail,
      controller: _controllerEmail,
      decoration: const InputDecoration(
        labelText: "Email Adresinizi Giriniz",
        suffixIcon: Icon(
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

  //Kayıt Buttonu
  DecoratedBox widgetButtonLoginOn(BuildContext context) {
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
              if (userInfo['status'] == true) {
                // ignore: use_build_context_synchronously
                context.noticeBarTrue("Giriş başarılı.", 1);
                authController.setAuthTrue();
                SecurityStorageUser.setUserId(userInfo['id']!);
                SecurityStorageUser.setUserAccessToken(
                    userInfo['accessToken']!);
                SecurityStorageUser.setUserRefleshToken(
                    userInfo['refreshToken']!);

                ///SingIn fonksiyonu supabase farklı bir table olduğu için
                ///Bu fonksiyona ihtiyaç var.
                final userNameSurnameRole =
                    await db.fetchNameSurnameRole(userInfo['id']);

                authController.role = userNameSurnameRole.role!;
                //Kullanı rolüne göre izinli olduğu sayfaların listesi geliyor.
                final roleList =
                    await db.fetchPageInfoByRole(authController.role);
                await SecurityStorageUser.setPageList(roleList);

                SecurityStorageUser.setUserName(userNameSurnameRole.name!);
                SecurityStorageUser.setUserLastName(
                    userNameSurnameRole.lastName!);
                SecurityStorageUser.setUserRole(userNameSurnameRole.role!);
                context.router.pushNamed(ConstRoute.stockEdit);
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
              child: const Text(
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
                "GİRİŞ",
              ),
            )));
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
