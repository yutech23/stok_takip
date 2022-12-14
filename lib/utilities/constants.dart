class Sabitler {
  ///Telefon için girilen alan 2 bölümden oluşuyor burada veri tabanına kayıt
  ///alırken ayrı oldukları için sorun çıkıyor bu yüzden Ülke kodu static olarak
  ///tutuyoruz. Sayfalar arası veri taşımak içinde yapıldı.
  static String countryCode = "90";
  static int deger = 0;
  static String dbHiveBoxName = 'necessaryData';
}

class ConstRoute {
  static const String initName = 'initName';
  static const String init = '/splash';
  static const String login = '/login';
  static const String stockEdit = '/stockEdit';
  static const String productAdd = '/productAdd';
  static const String signUp = '/signUp';
  static const String categoryEdit = '/categoryEdit';
  static const String customerRegister = '/customerRegister';
  static const String userSetting = '/userSetting';
  static const String test = '/test';
}

Sabitler sabitler = Sabitler();
