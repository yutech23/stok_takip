class Sabitler {
  ///Telefon için girilen alan 2 bölümden oluşuyor burada veri tabanına kayıt
  ///alırken ayrı oldukları için sorun çıkıyor bu yüzden Ülke kodu static olarak
  ///tutuyoruz. Sayfalar arası veri taşımak içinde yapıldı.

  static String countryCode = "90";
  static int deger = 0;
  static String dbHiveBoxName = 'necessaryData';

  final List<String> listDropdownService = [
    'Hepsi',
    'Bürüt Ücretler',
    'Demirbaş ve Bakım Onarım Giderleri',
    'Elektrik Giderleri',
    'Isınma Giderleri',
    'Su Giderleri',
    'Doğalgaz Giderleri',
    'Haberleşme Giderleri',
    'Kira Giderleri',
    'Temizlik Giderleri',
    'Yemek Giderleri',
    'Yol, OGS, HGS, Ulaşım Giderleri',
    'Nakliye Giderleri',
    'SGK',
    'Ambalaj, Boşet ve Çuval',
    'Ambar Ödemesi',
    'Diğer Giderler'
  ];

  final productTaxList = <String>['% 0', '% 10', '% 20'];
  final resetPasswordPath = "https://erp.esnaficin.com/resetPassword";
  // final resetPasswordPath = "https://erp.enisthetoptan.com/resetPassword";
}

class ConstRoute {
  static const String splash = '/splash';
  static const String login = '/';
  static const String stockEdit = '/stockEdit';
  static const String productAdd = '/productAdd';
  static const String signUp = '/signUp';
  static const String categoryEdit = '/categoryEdit';
  static const String customerRegister = '/customerRegister';
  static const String userSetting = '/userSetting';
  static const String test = '/test';
  static const String sale = '/sale';
  static const String cariCustomer = '/cariCustomer';
  static const String cariSupplier = '/cariSupplier';
  static const String caseSnapshot = '/caseSnapshot';
  static const String capital = '/capital';
  static const String expenses = '/expenses';
  static const String users = '/usersEdit';
  static const String resetPassword = "/resetPassword";
}

Sabitler sabitler = Sabitler();
