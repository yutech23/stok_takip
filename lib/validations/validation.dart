import 'package:email_validator/email_validator.dart';

mixin Validation {
  late String? password;

  String? validateFirstAndLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen Alanı Boş Bırakmayınız';
    } else if (value.length < 3 || value.length > 20) {
      return '3 ile 20 karakter arasında giriniz.';
    }
    return null;
  }

  String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen Alanı Boş Bırakmayınız';
    } else if (value.length < 3 || value.length > 100) {
      return '3 ile 100 karakter arasında giriniz.';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen alanı boş bırakmayınız';
    } else if (EmailValidator.validate(value) == false) {
      return 'E-Mail adres Standartlarını giriniz';
    }
    return null;
  }

  String? validatePassword(String? value) {
    password = value;
    if (value == null || value.isEmpty) {
      return 'Lütfen alanı boş bırakmayınız';
    } else if (value.length < 6) {
      return '6 Karakterden aşağı olamaz.';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen alanı boş bırakmayınız';
    } else if (value.length < 6) {
      return '6 Karakterden aşağı olamaz.';
    } else if (password != value) {
      return 'Girdiğiniz şifreler eşleşmedi. Tekrar deneyin.';
    }
    return null;
  }

  String? validateRoleSelectFunc(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen bir yetki türü seçiniz.';
    } else {
      return null;
    }
  }

  String? validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen alanı doldurun.';
    } else {
      return null;
    }
  }

  String? validateNotEmptyAddText(String? value, {required String message}) {
    if (value == null || value.isEmpty) {
      return 'Lütfen $message';
    } else {
      return null;
    }
  }

  String? validateNotEmptySelect(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen seçim yapınız.';
    } else {
      return null;
    }
  }

  String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen İl seçiniz';
    } else {
      return null;
    }
  }

  String? validateDistrict(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen İlçe seçiniz';
    } else {
      return null;
    }
  }

  String? validateTaxNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen alanı boş bırakmayınız';
    } else if (value.length <= 9) {
      return '10 haneden küçük olamaz';
    }
    return null;
  }

  String? validateTCNumber(String? value) {
    if (value!.length != 11) {
      return '11 haneden küçük olamaz.';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen alanı boş bırakmayınız';
    } else if (value.length <= 5) {
      return '5 haneden küçük olamaz';
    }
    return null;
  }
}
