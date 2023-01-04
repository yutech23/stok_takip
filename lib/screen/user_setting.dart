import 'package:flutter/material.dart';
import 'package:stok_takip/screen/drawer.dart';
import 'package:stok_takip/validations/validation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/database_helper.dart';
import '../utilities/dimension_font.dart';
import '../utilities/widget_appbar_setting.dart';

class ScreenUserSetting extends StatefulWidget {
  ScreenUserSetting({Key? key}) : super(key: key);

  @override
  State<ScreenUserSetting> createState() => _ScreenUserSettingState();
}

class _ScreenUserSettingState extends State<ScreenUserSetting> with Validation {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controllerNewPassword;
  late final TextEditingController _controllerReNewPassword;
  late final TextEditingController _controllerCurrentPassword;
  AutovalidateMode _autovalidateMode = AutovalidateMode.onUserInteraction;

  bool obscureValue = true,
      confirmObscureValue = true,
      nowPassordObscureValue = true;

  @override
  void initState() {
    _controllerNewPassword = TextEditingController();
    _controllerReNewPassword = TextEditingController();
    _controllerCurrentPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controllerReNewPassword.dispose();
    _controllerCurrentPassword.dispose();
    _controllerNewPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ayarlar"),
        actionsIconTheme: IconThemeData(color: Colors.blueGrey.shade100),
        actions: [
          ShareWidgetAppbarSetting(),
        ],
      ),
      drawer: MyDrawer(),
      body: buildUserSetting(context),
    );
  }

  buildUserSetting(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode,
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
            height: 500,
            width: 350,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Şifre Değiştirme", style: context.theme.headline4),
              const SizedBox(height: 40),
              widgetTextFieldCurrentPassword(
                  _controllerCurrentPassword,
                  "Şu anki şifrenizi giriniz",
                  nowPassordObscureValue,
                  validatePassword),
              const SizedBox(height: 20),
              widgetTextFieldPassword(_controllerNewPassword,
                  "Şifrenizi Giriniz", obscureValue, validatePassword),
              const SizedBox(height: 20),
              widgetTextFieldPasswordConfirm(
                  _controllerReNewPassword,
                  "Şifrenizi Tekrar Giriniz",
                  confirmObscureValue,
                  validateConfirmPassword),
              const SizedBox(height: 40),
              buttonSave(),
            ]),
          ),
        ),
      ),
    );
  }

  TextFormField widgetTextFieldCurrentPassword(
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
        labelText: "Şu anki şifrenizi giriniz",
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
            focusNode: FocusNode(skipTraversal: true),
            onPressed: () {
              setState(() {
                nowPassordObscureValue = !nowPassordObscureValue;
              });
            },
            icon: Icon(obscureValue ? Icons.visibility_off : Icons.visibility)),
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
        labelText: "Yeni şifrenizi doğrulayın",
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
  buttonSave() {
    return ElevatedButton(
      onPressed: () async {
        if (_controllerNewPassword.text == _controllerReNewPassword.text &&
            _formKey.currentState!.validate()) {
          final Session? sessionUserId = db.supabase.auth.currentSession;

          ///şuanki kullanıcı id ile controllerText içindeki veriyi karşılaştırılıyor
          ///eğer doğru ise yeni şifre veri tabanına kaydediliyor.
          ///
          if (sessionUserId!.user.id != null) {
            db.getPassword(sessionUserId.user.id).then((userPassword) {
              if (_controllerCurrentPassword.text == userPassword) {
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
                db
                    .saveNewPassword(
                        _controllerNewPassword.text, sessionUserId.user.id)
                    .then((value) {
                  if (value.isEmpty) {
                    _controllerNewPassword.clear();
                    _controllerCurrentPassword.clear();
                    _controllerReNewPassword.clear();
                    context.noticeBarTrue('Şifreniz değişmiştir', 1);
                  } else {
                    context.noticeBarError(value, 2);
                  }
                });
              } else {
                context.noticeBarError('Şu anki şifrenizi yalnış girdiniz.', 2);
              }
            });
          } else {
            context.noticeBarError('Düzgün giriş gerçekliştirilmemiştir.', 2);
          }
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
}
