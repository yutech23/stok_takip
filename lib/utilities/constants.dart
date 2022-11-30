import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Sabitler {
  ///Telefon için girilen alan 2 bölümden oluşuyor burada veri tabanına kayıt
  ///alırken ayrı oldukları için sorun çıkıyor bu yüzden Ülke kodu static olarak
  ///tutuyoruz. Sayfalar arası veri taşımak içinde yapıldı.
  static String countryCode = "90";
  static int deger = 0;
}

Sabitler sabitler = Sabitler();
