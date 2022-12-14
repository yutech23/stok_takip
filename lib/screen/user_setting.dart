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
              Text("??ifre De??i??tirme", style: context.theme.headline4),
              const SizedBox(height: 40),
              widgetTextFieldCurrentPassword(
                  _controllerCurrentPassword,
                  "??u anki ??ifrenizi giriniz",
                  nowPassordObscureValue,
                  validatePassword),
              const SizedBox(height: 20),
              widgetTextFieldPassword(_controllerNewPassword,
                  "??ifrenizi Giriniz", obscureValue, validatePassword),
              const SizedBox(height: 20),
              widgetTextFieldPasswordConfirm(
                  _controllerReNewPassword,
                  "??ifrenizi Tekrar Giriniz",
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
        labelText: "??u anki ??ifrenizi giriniz",
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

  // ??ifre Widget
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
        labelText: "Yeni ??ifrenizi Giriniz",
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
        labelText: "Yeni ??ifrenizi do??rulay??n",
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

//Kullan??c?? olu??turma kay??t buttonu.
  buttonSave() {
    return ElevatedButton(
      onPressed: () async {
        if (_controllerNewPassword.text == _controllerReNewPassword.text &&
            _formKey.currentState!.validate()) {
          final Session? sessionUserId = db.supabase.auth.currentSession;

          ///??uanki kullan??c?? id ile controllerText i??indeki veriyi kar????la??t??r??l??yor
          ///e??er do??ru ise yeni ??ifre veri taban??na kaydediliyor.
          ///
          if (sessionUserId!.user.id != null) {
            db.getPassword(sessionUserId.user.id).then((userPassword) {
              if (_controllerCurrentPassword.text == userPassword) {
                ///password g??ncelliyor ama sadece supabase user i??inde yap??yor.
                ///??ifreyi kullan??c??lar tablosunda tutuluyor. g??stermek i??in.
                db
                    .updateUserInformation(_controllerReNewPassword.text)
                    .then((resValue) {
                  if (resValue.isEmpty) {
                    context.noticeBarTrue("????lem ba??ar??l??.", 1);
                  } else {
                    context.noticeBarError("????lem Ba??ar??s??z", 1);
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
                    context.noticeBarTrue('??ifreniz de??i??mi??tir', 1);
                  } else {
                    context.noticeBarError(value, 2);
                  }
                });
              } else {
                context.noticeBarError('??u anki ??ifrenizi yaln???? girdiniz.', 2);
              }
            });
          } else {
            context.noticeBarError('D??zg??n giri?? ger??ekli??tirilmemi??tir.', 2);
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
