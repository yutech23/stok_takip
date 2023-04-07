import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/validations/formatter_iban.dart';
import 'package:stok_takip/validations/validation.dart';
import 'package:stok_takip/validations/validation_phone_number.dart';

class ShareWidget with Validation {
  final String _labelIBANName = "IBAN Numarası";

  //Widget - inputlar
  TextFormField widgetTextFieldInput(
      {TextEditingController? controller,
      required String etiket,
      bool? karakterGostermeDurumu = false,
      bool? skipTravelFocusValue = false,
      int? maxCharacter,
      String? Function(String?)? validationFunc,
      List<TextInputFormatter>? inputFormat,
      TextInputType? keyboardInputType,
      void Function(String)? onChanged,
      TextStyle? style
      // Color borderSideColor,
      }) {
    return TextFormField(
      onChanged: onChanged,
      maxLength: maxCharacter,
      obscureText: karakterGostermeDurumu!,
      controller: controller,
      validator: validationFunc,
      style: style,

      // autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
          counterText: "",
          labelText: etiket,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          )),
      focusNode: FocusNode(skipTraversal: skipTravelFocusValue!),
      keyboardType: keyboardInputType,
      inputFormatters: inputFormat,
    );
  }

  ///[Sadece Türkiye telefonu için ayarlanmış özeli format 5xx-xxx-xx-xx]
  ///Widget -  Telefon numarası alanı ŞUAN KULLANILMIYOR AŞAĞIDAKİ KULLANILIYOR
  TextFormField widgetTextFormFieldPhone(
      {TextEditingController? controllerPhoneNumber,
      String? Function(String?)? validateFunc,
      String? intialNumber}) {
    return TextFormField(
      initialValue: intialNumber,
      controller: controllerPhoneNumber,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[0-9,-]")),
        CardFormatter(sample: 'xxx-xxx-xx-xx', separator: '-')
      ],
      decoration: const InputDecoration(
          hintText: "5XX-XXX-XX-XX",
          labelText: " Telefon numarınızı giriniz",
          border: OutlineInputBorder()),
      onFieldSubmitted: (value) => print(value.replaceAll(RegExp(r"[-]"), '')),
      validator: validateFunc,
    );
  }

/* //Aktif Telefon Numara giriş bölmü kullanılıyor
  IntlPhoneField widgetIntlPhoneField(
      {TextEditingController? controllerPhoneNumber,
      Function(String?)? selectedCountryCode}) {
    return IntlPhoneField(
      controller: controllerPhoneNumber,
      initialCountryCode: 'TR',

      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[0-9,-]")),
      ],

      decoration: const InputDecoration(
        labelText: 'Telefon Numarısı Giriniz',
        border: OutlineInputBorder(
          borderSide: BorderSide(),
        ),
      ),

      ///Numara girme alanı 2 ayrı bölümden oluşmakta Ülke kodu alabilmek için
      ///static olarak bir değişken tanımladım çünkü diğer sayfadan ulaşmak için
      ///SetState ihtiyaç vardı. AYNI İŞİ "KEY" YAPILABİLİR. İŞ HIZLI OLMASI İÇİN
      ///ŞUABNLIK BÖYLE YAPILDI.
      onCountryChanged: (value) {
        Sabitler.countryCode = value.dialCode;
      },
      selectedCountryCode: selectedCountryCode,
    );
  } */

  //Aktif Telefon Numara giriş bölmü kullanılıyor
  widgetPhoneFormField({
    PhoneController? controllerPhoneNumber,
  }) {
    return PhoneFormField(
        validator: (phoneNumber) {
          if (phoneNumber?.nsn == null) {
            return validateNotEmpty("");
          } else {
            return validateNotEmpty(phoneNumber?.nsn);
          }
        },
        defaultCountry: IsoCode.TR,
        isCountryChipPersistent: true,
        autocorrect: false,
        controller: controllerPhoneNumber,
        decoration: const InputDecoration(
            labelText: 'Telefon Numarısı Giriniz',
            border: OutlineInputBorder(
              borderSide: BorderSide(),
            )));
  }

  ///Elevated Button
  ElevatedButton widgetElevatedButton(
      {required void Function()? onPressedDoSomething,
      required String label,
      ButtonStyle? buttonStyle}) {
    return ElevatedButton(
      style: buttonStyle,
      onPressed: onPressedDoSomething,
      child: Text(label),
    );
  }

  TextFormField widgetTextFieldIban({
    TextEditingController? controller,
    bool? focusValue = false,
    String? Function(String?)? validationFunc,
    TextInputType? keyboardInputType,
  }) {
    return TextFormField(
      maxLength: 32,
      controller: controller,
      validator: validationFunc,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
          counterText: "",
          labelText: _labelIBANName,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          )),
      focusNode: FocusNode(skipTraversal: focusValue!),
      inputFormatters: [FormatterIbanInput()],
    );
  }
}

final ShareWidget shareWidget = ShareWidget();
