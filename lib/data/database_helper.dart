import 'package:flutter/material.dart';
import 'package:stok_takip/env/env.dart';
import 'package:stok_takip/models/customer.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'package:turkish/turkish.dart';

class DbHelper {
  DbHelper._intenat();

  static final _singlaton = DbHelper._intenat();

  factory DbHelper() {
    return _singlaton;
  }

  final supabase = Supabase.instance.client;

  static Future dbBaslat() async {
    await Supabase.initialize(url: Env.url, anonKey: Env.apiKey);
  }

  //Giriş Ekran Sorgulama
  Future<Map<String, String?>> singIn(
      BuildContext context, String setEmail, String setPassword) async {
    Map<String, String?> userSessionMap = {};
    bool status = false;
    final res =
        await db.supabase.auth.signIn(email: setEmail, password: setPassword);
    //print("database'den access_token degeri : ${res.data!.accessToken}");
    final error = res.error;
    if (res.error == null) {
      status = true;
      userSessionMap.addAll({
        'id': res.user?.id,
        'accessToken': res.data!.accessToken,
        'refreshToken': res.data!.refreshToken,
        'status': status.toString()
      });
    } else {
      status = false;
    }

    if (error != null) {
      context.extensionShowErrorSnackBar(message: error.message);
      return userSessionMap;
    } else {
      context.extenionShowSnackBar(message: 'Giriş başarılı.');
      return userSessionMap;
    }
  }

  Future refleshToken(String refleshToken) async {
    final res = await db.supabase.auth.setSession(refleshToken);
    final data = res.data;
    print("Yeni session : $data");
  }

  Future<String?> signOut() async {
    final res = await db.supabase.auth.signOut();
    final error = res.error?.message;
    return error;
  }

  Future<String?> updateUserInformation(String newPassword) async {
    final res = await db.supabase.auth.update(
      UserAttributes(
        password: newPassword,
      ),
    );

    final resError = res.error?.message;

    print("cevap : $resError");
    return resError;
  }

  //Üye kayıt Fonksiyonu
  Future<bool?> signUp(BuildContext context, GlobalKey<FormState> formKey,
      Kullanici kullanici) async {
    //Buttona forKey.currentSaate.validate() sayesinde validata() hepsi tetikleniyor.
    //validate() değeri null ise dönen değer true bu sayede if bloku çalışır. dataBase
    //kayıt işlemleri gerçekleşir.

    if (formKey.currentState!.validate()) {
      //Auth. kayıt sağlar. Burada Kullanıca UUid belirlenir.
      final resAuth = await db.supabase.auth.api
          .signUpWithEmail(kullanici.email!, kullanici.password!);

      final error = resAuth.error;
      if (error != null) {
        // ignore: use_build_context_synchronously
        context.extensionShowErrorSnackBar(message: error.message);
      } else {
        final roleIdJson = await db.supabase
            .from('roles')
            .select('role_id')
            .eq('role_type', kullanici.role)
            .execute();
        String roleIdString = Map.from(roleIdJson.data[0])
            .values
            .toString()
            .replaceAll(RegExp(r"[)(]"), '');

        print("**********");
        print(kullanici.name);
        print(kullanici.lastName);
        print(kullanici.email);
        print(kullanici.password);
        print(roleIdString);
        print(resAuth.data!.user!.id);
        print("***********");
        final resUserRegister = await db.supabase.from('users').insert([
          {
            'name': kullanici.name,
            'last_name': kullanici.lastName,
            'email': kullanici.email,
            'password': kullanici.password,
            'user_uuid': resAuth.data!.user!.id,
            'role': roleIdString
          }
        ]).execute();
        // ignore: use_build_context_synchronously
        context.extenionShowSnackBar(
            message: 'KAYIT BAŞARILI.', backgroundColor: Colors.green);
        return true;
      }
    } else {
      context.extensionShowErrorSnackBar(
          message: 'Kurallara uygun veri giriniz.');
      return false;
    }

    //await db.supabase.auth.signOut();
  }

  //Role Listesini Getirir
  Future<List<String>> getRoles() async {
    final res = await supabase.from('roles').select('role_type').execute();
    final data = res.data;
    final error = res.error;
    final dropdownYetkiListe = <String>[];
    // Burada veritabanından gelen "data" değişkenine atanıyor.
    // Liste içinde map geliyor.
    for (var item in data) {
      //Gelen  deger value = "(Genel Kullanıcı)" olarak geliyor burada () temizlemek
      //RegExp(r"[]"") ile r zorunlu [] bunların arasındaki karakteri siler.
      dropdownYetkiListe.add(
          Map.from(item).values.toString().replaceAll(RegExp(r"[)(]"), ''));
    }
    return dropdownYetkiListe;
  }

  ///Şehirleri Getirir
  Future<List<String>> getCities(String value) async {
    final res = await supabase.from('cities').select('name').execute();
    final data = res.data;
    final error = res.error;
    final cities = <String>[];

    for (var item in data) {
      cities.add(item['name']);
    }
    return cities;
  }

  ///Şehirlere bağlı İlçeleri getirir
  Future<List<String>> getDistricts(String value, String _selectedCity) async {
    final res = await supabase
        .from('district')
        .select('''name,cities(name)''')
        .eq('cities.name', _selectedCity)
        .execute();
    final data = res.data;
    final error = res.error;

    final districts = <String>[];

    for (var item in data) {
      if (item['cities'] != null) {
        districts.add(item['name']);
      }
    }

    /// Türkçe karkterlerine göre sıralanıyor
    districts.sort(turkish.comparator);

    return districts;
  }

  ///VergiDairelerini Getirir 05.01.22 tarihli güncel liste
  ///(veritabanunda kodlarıda bulunmaktadır ama kullanmıyorum)
  Future<List<String>> getTaxOfficeList(
      String value, String _selectedCity) async {
    final res = await supabase
        .from('tax_offices')
        .select('''name,cities(name)''')
        .eq('cities.name', _selectedCity)
        .execute();
    final data = res.data;
    final error = res.error;

    final tax_offices_name = <String>[];

    for (var item in data) {
      if (item['cities'] != null) {
        tax_offices_name.add(item['name']);
      }
    }
    tax_offices_name.sort(turkish.comparator);

    return tax_offices_name;
  }

  Future saveCustomerSoleTrader(
      BuildContext context, Customer customerSoleTrader) async {
    final res = await supabase.from('customer_sole_trader').insert([
      {
        'name': customerSoleTrader.soleTraderName,
        'last_name': customerSoleTrader.soleTraderLastName,
        'phone': customerSoleTrader.phone,
        'city': customerSoleTrader.city,
        'district': customerSoleTrader.district,
        'adress': customerSoleTrader.adress,
        'tax_office': customerSoleTrader.taxOffice,
        'tax_number': customerSoleTrader.taxNumber,
        'cargo_company': customerSoleTrader.CargoName,
        'cargo_number': customerSoleTrader.CargoNumber
      }
    ]).execute();
    final error = res.error;

    if (error != null) {
      context.extensionShowErrorSnackBar(message: error.message);
    } else {
      context.extenionShowSnackBar(message: 'Kayıt Başarılı');
    }
    return error;
  }

  Future saveCustomerCompany(
    BuildContext context,
    Customer customerCompany,
  ) async {
    final res = await supabase.from('customer_company').insert([
      {
        'name': customerCompany.companyName,
        'phone': customerCompany.phone,
        'city': customerCompany.city,
        'district': customerCompany.district,
        'adress': customerCompany.adress,
        'tax_office': customerCompany.taxOffice,
        'tax_number': customerCompany.taxNumber,
        'cargo_company': customerCompany.CargoName,
        'cargo_number': customerCompany.CargoNumber
      }
    ]).execute();
    final error = res.error;

    if (error != null) {
      context.extensionShowErrorSnackBar(message: error.message);
    } else {
      context.extenionShowSnackBar(message: 'Kayıt Başarılı');
    }
    return error;
  }

  ///***********************Product işlemleri*********************************
  Future<List<String>> getProductCode() async {
    final res = await supabase.from('product').select('product_code').execute();
    final data = res.data;
    final error = res.error;
    final productCode = <String>[];
    // Burada veritabanından gelen "data" değişkenine atanıyor.
    // Liste içinde map geliyor.
    for (var item in data) {
      //Gelen  deger value = "(Genel Kullanıcı)" olarak geliyor burada () temizlemek
      //RegExp(r"[]"") ile r zorunlu [] bunların arasındaki karakteri siler.
      productCode.add(
          Map.from(item).values.toString().replaceAll(RegExp(r"[)(]"), ''));
    }
    return productCode;
  }

  Future<bool> saveProduct(BuildContext context, Product product) async {
    final res = await supabase.from('product').insert([
      {
        'product_code': product.productCodeAndQrCode,
        'tax_rate': product.taxRate,
        'amount_of_stock': product.amountOfStock,
        'buying_price_without_tax': product.buyingpriceWithoutTax,
        'salling_price_without_tax': product.sallingPriceWithoutTax,
        'fk_category1_id': product.category!.category1!.keys.first,
        'fk_category2_id': product.category!.category2!.keys.first,
        'fk_category3_id': product.category!.category3!.keys.first,
        'fk_category4_id': product.category!.category4!.keys.first,
        'fk_category5_id': product.category!.category5!.keys.first,
      }
    ]).execute();
    final error = res.error;

    ///kayıt edilen ürünün id sini alıyoruz ki fiyat ve stok bilgilerin geçmişini
    ///kaydetmek için.
    int productId = res.data[0]['product_id'];

    final resProductPriceHistory =
        await supabase.from('product_price_history').insert([
      {
        'fk_product_id': productId,
        'amount_of_stock': product.amountOfStock,
        'buying_price_without_tax': product.buyingpriceWithoutTax,
        'salling_price_without_tax': product.sallingPriceWithoutTax,
      }
    ]).execute();
    final errorProductPriceHistory = resProductPriceHistory.error;

    if (error != null && errorProductPriceHistory != null) {
      context.extensionShowErrorSnackBar(message: error.message);
      return false;
    } else {
      context.extenionShowSnackBar(message: 'Kayıt Başarılı');
      return true;
    }
  }

  Future<Product?> getProductDetail(String productCode) async {
    final res = await supabase
        .from('product')
        .select()
        .eq('product_code', productCode)
        .execute();
    final data = res.data;
    final error = res.error;
    Category getProductCategory = Category();

    final resCategory1 = await supabase
        .from('category1')
        .select('name')
        .eq('category1_id', data[0]['fk_category1_id'])
        .execute();
    getProductCategory.category1 = {
      data[0]['fk_category1_id']: resCategory1.data[0]['name']
    };

    final resCategory2 = await supabase
        .from('category2')
        .select('name')
        .eq('category2_id', data[0]['fk_category2_id'])
        .execute();
    getProductCategory.category2 = {
      data[0]['fk_category2_id']: resCategory2.data[0]['name']
    };

    final resCategory3 = await supabase
        .from('category3')
        .select('name')
        .eq('category3_id', data[0]['fk_category3_id'])
        .execute();
    getProductCategory.category3 = {
      data[0]['fk_category3_id']: resCategory3.data[0]['name']
    };

    final resCategory4 = await supabase
        .from('category4')
        .select('name')
        .eq('category4_id', data[0]['fk_category4_id'])
        .execute();
    getProductCategory.category4 = {
      data[0]['fk_category4_id']: resCategory4.data[0]['name']
    };

    final resCategory5 = await supabase
        .from('category5')
        .select('name')
        .eq('category5_id', data[0]['fk_category5_id'])
        .execute();
    getProductCategory.category5 = {
      data[0]['fk_category5_id']: resCategory5.data[0]['name']
    };

    Product getProductDetail = Product(
        productCodeAndQrCode: data[0]['product_code'],
        amountOfStock: data[0]['amount_of_stock'],
        taxRate: data[0]['tax_rate'],
        buyingpriceWithoutTax: data[0]['buying_price_without_tax'],
        sallingPriceWithoutTax: data[0]['salling_price_without_tax'],
        category: getProductCategory);

    return getProductDetail;
  }

  Stream<List<Map<String, dynamic>>>? fetchProductDetail() {
    final resProduct = db.supabase
        .from('product')
        .stream(['product_id'])
        .order('product_code', ascending: true)
        .execute();
    return resProduct;
  }

  Future<List<dynamic>> fetchProductDetailFuture() async {
    List<Map<String, dynamic>>? _mapList = [];
    final resProduct = await db.supabase.from('product').select().execute();

    final data = resProduct.data;

    /* for (var element in resProduct.data) {
      _mapList.add(element);
    }*/

    return resProduct.data;
  }

  Future deleteProduct(String productCode) async {
    final res = await db.supabase
        .from('product')
        .delete()
        .match({'product_code': productCode}).execute();
    return res.error;
  }

  Future updateProductDetail(String productCode, int? selectProductId,
      int? newStockValue, Map<String, dynamic> data) async {
    final res = await db.supabase
        .from('product')
        .update(data)
        .match({'product_code': productCode}).execute();
    final resProductPriceHistory =
        await db.supabase.from('product_price_history').insert([
      {
        'buying_price_without_tax': data['buying_price_without_tax'],
        'salling_price_without_tax': data['salling_price_without_tax'],
        'amount_of_stock': newStockValue,
        'fk_product_id': selectProductId,
      }
    ]).execute();
  }

  Future<String?> getPassword(String? uuid) async {
    final res = await supabase
        .from('users')
        .select('*')
        .match({'user_uuid': uuid}).execute();

    return res.data[0]['password'];
  }

  Future saveNewPassword(String? newPassword, String userId) async {
    final res = await supabase
        .from('users')
        .update({'password': newPassword})
        .eq('user_uuid', userId)
        .execute();
    final error = res.error;
    print(error);
  }

  Future<Kullanici> fetchNameSurnameRole(String? uuid) async {
    Kullanici selectedKullanici;

    if (uuid == null) {
      selectedKullanici = Kullanici.nameSurnameRole(
          name: 'Null', lastName: 'Null', role: 'Null');
      return selectedKullanici;
    } else {
      final res = await supabase
          .from('users')
          .select('name,last_name,role')
          .match({'user_uuid': uuid}).execute();

      selectedKullanici = Kullanici.nameSurnameRole(
          name: res.data[0]['name'],
          lastName: res.data[0]['last_name'],
          role: res.data[0]['role'].toString());
      return selectedKullanici;
    }
  }
}

final db = DbHelper();
