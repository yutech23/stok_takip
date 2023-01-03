import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stok_takip/env/env.dart';
import 'package:stok_takip/models/customer.dart';
import 'package:stok_takip/models/payment.dart';
import 'package:stok_takip/models/suppliers.dart';
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
  Future<Map<String, dynamic>> singIn(
      BuildContext context, String setEmail, String setPassword) async {
    Map<String, dynamic> userSessionMap = {};
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
        'status': status
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

  ///Kullanıcı Adını, Soyadını ve Role getiriyor.
  ///SingIn fonksiyonu supabase farklı bir table olduğu için
  ///Bu fonksiyona ihtiyaç var.
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

  Future<List<dynamic>> fetchPageInfoByRole(String isRole) async {
    final res = await db.supabase
        .from('path_role_permission')
        .select('class_name')
        .eq('role_id', int.parse(isRole))
        .execute();

    final data = res.data;

    return data;
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
      String value, String? selectedCity) async {
    final res = await supabase
        .from('tax_offices')
        .select('''name,cities(name)''')
        .eq('cities.name', selectedCity)
        .execute();
    final data = res.data;
    final error = res.error;

    final taxOfficesName = <String>[];

    for (var item in data) {
      if (item['cities'] != null) {
        taxOfficesName.add(item['name']);
      }
    }
    taxOfficesName.sort(turkish.comparator);

    return taxOfficesName;
  }

  ///*****************Müşteri kayıt İşlemleri************************
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
        'cargo_company': customerSoleTrader.cargoName,
        'cargo_number': customerSoleTrader.cargoNumber
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
        'cargo_company': customerCompany.cargoName,
        'cargo_number': customerCompany.cargoNumber,
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

  Future saveSuppliers(
    BuildContext context,
    Customer supplier,
  ) async {
    final res = await supabase.from('suppliers').insert([
      {
        'name': supplier.supplierName,
        'iban': supplier.iban,
        'bank_name': supplier.bankName,
        'phone': supplier.phone,
        'city': supplier.city,
        'district': supplier.district,
        'adress': supplier.adress,
        'tax_office': supplier.taxOffice,
        'tax_number': supplier.taxNumber,
        'cargo_company': supplier.cargoName,
        'cargo_number': supplier.cargoNumber,
      }
    ]).execute();
    final error = res.error?.message;

    return error;
  }

  ///***********************Product işlemleri*********************************
  Future<List<String>> getProductCode() async {
    final res = await supabase.from('product').select('product_code').execute();
    final data = res.data;
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

  Stream<List<Map<String, dynamic>>> getSuppliersNameStream() {
    final resProduct = db.supabase
        .from('suppliers')
        .stream(['supplier_id'])
        .order('name', ascending: true)
        .execute();

    return resProduct;
  }

  Future<List<String?>> getSuppliersName() async {
    final res = await supabase
        .from('customer_company')
        .select('name')
        .eq('type', 'Tedarikçi')
        .order('name', ascending: true)
        .execute();
    final data = res.data;
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

  Future<bool> isThereOnSupplierName(String supplierName) async {
    final res = await supabase
        .from('customer_company')
        .select('name')
        .eq('type', 'Tedarikçi')
        .match({'name': supplierName}).execute();
    final List<dynamic> data = res.data;
    if (data.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future saveSupplier(Supplier supplier) async {
    final resSupplier = await supabase.from('suppliers').insert([
      {
        'name': supplier.name,
        'phone': supplier.phone,
        'adress': supplier.adress,
        'tax_office': supplier.taxOffice,
        'cargo_number': supplier.cargoNumber,
        'cargo_company': supplier.cargoCompany,
        'bank_name': supplier.bankName,
        'iban': supplier.iban,
      }
    ]).execute();

    final errorSupplier = resSupplier.error;
    print('error Supplier : $errorSupplier');
  }

  Future<String> saveNewProduct(
      BuildContext context, Product product, Payment payment) async {
    final resProduct = await supabase.from('product').insert([
      {
        'product_code': product.productCode,
        'tax_rate': product.taxRate,
        'current_buying_price_without_tax':
            product.currentBuyingPriceWithoutTax,
        'current_salling_price_without_tax':
            product.currentSallingPriceWithoutTax,
        'fk_category1_id': product.category!.category1!.keys.first,
        'fk_category2_id': product.category!.category2!.keys.first,
        'fk_category3_id': product.category!.category3!.keys.first,
        'fk_category4_id': product.category!.category4!.keys.first,
        'fk_category5_id': product.category!.category5!.keys.first,
        'current_amount_of_stock': product.currentAmountOfStock
      }
    ]).execute();
    final errorProduct = resProduct.error;

    ///İlk kez yeni bir ürün eklendiğinde payment yeni ürün fiyatını ekliyoruz.
    final resPayment = await supabase.from('payment').insert([
      {
        'supplier_fk': payment.suppliersFk,
        'product_fk': payment.productFk,
        'amount_of_stock': product.currentAmountOfStock,
        'buying_price_without_tax': product.currentBuyingPriceWithoutTax,
        'salling_price_without_tax': product.currentSallingPriceWithoutTax,
        'invoice_code': payment.invoiceCode,
        'unit_of_currency': payment.unitOfCurrency,
        'total': payment.total,
        'cash': payment.cash,
        'bankcard': payment.bankcard,
        'eft_havale': payment.eftHavale,
        'repayment_date': payment.repaymentDateTime
      }
    ]).execute();
    final errorPayment = resPayment.error;

    ///Depo sistemi için yapıldı
    /*  final resStorehouse = await supabase.from('storehouse_stock').insert([
      {
        'storehouse_fk': storehouse,
        'product_fk': product.productCode,
        'current_amount_of_stock': product.currentAmountOfStock
      }
    ]).execute();
    final errorStorehouse = resStorehouse.error; */

    //  print('Storehouse error : $errorStorehouse');

    if (errorProduct == null || errorPayment == null) {
      return "";
    } else {
      return errorProduct.message + errorPayment.message;
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
        productCode: data[0]['product_code'],
        currentAmountOfStock: data[0]['current_amount_of_stock'],
        taxRate: data[0]['tax_rate'],
        currentBuyingPriceWithoutTax: data[0]['buying_price_without_tax'],
        currentSallingPriceWithoutTax: data[0]['salling_price_without_tax'],
        category: getProductCategory);

    return getProductDetail;
  }

  Stream<List<Map<String, dynamic>>>? fetchProductDetail() {
    final resProduct = db.supabase
        .from('product')
        .stream(['product_code'])
        .order('product_code', ascending: true)
        .execute();

    /*  resProduct.listen((event) {
      print(event);
    }); */
    /* final resStorehouseStock = db.supabase
        .from('storehouse_stock')
        .stream(['id'])
        .order('product_fk', ascending: true)
        .execute();

    Future resProductNew = resProduct.forEach((elementProductList) {
      elementProductList.forEach((elementProductMap) {
        resStorehouseStock.forEach((elementStorehouseList) {
          elementStorehouseList.forEach((elementStorehouseMap) {
            // print(elementProductMap['product_code']);
            // print(elementStorehouseMap['product_fk']);
            if (elementProductMap['product_code'] ==
                elementStorehouseMap['product_fk']) {
              elementProductMap.addAll({
                'current_amount_of_stock':
                    elementStorehouseMap['current_amount_of_stock']
              });
            }
          });
        });
      });
    });
 */
    return resProduct;
  }

  Future<List<dynamic>> fetchProductDetailFuture() async {
    List<Map<String, dynamic>>? mapList = [];
    final resProduct = await db.supabase.from('product').select().execute();

    final data = resProduct.data;

    /* for (var element in resProduct.data) {
      _mapList.add(element);
    }*/

    return resProduct.data;
  }

  //Ürün silme StokEdit Sayfasında kullanılıyor.
  Future<String> deleteProduct(String productCode) async {
    final resProduct = await db.supabase
        .from('product')
        .delete()
        .match({'product_code': productCode}).execute();
    print(resProduct);

    ///Birden fazla değp ekleme için kullanılmak için ön çalışma.
    /* final resStorehouseStock = await db.supabase
        .from('storehouse_stock')
        .delete()
        .match({'product_fk': productCode}).execute();

    final errorStorehouse = resStorehouseStock.error; */

    final errorProduct = resProduct.error;

    if (errorProduct == null) {
      return "";
    } else {
      return errorProduct.message;
    }
  }

  //Stok Güncelleme için Kullanılıyor
  Future updateProductDetail(
      String productCode, Map<String, dynamic> data, Payment payment) async {
    final resProduct = await db.supabase
        .from('product')
        .update(data)
        .match({'product_code': productCode}).execute();
    /*  //TEST
    print("veri içinde ");
    print(payment.productFk);
    print(payment.suppliersFk);
    print(payment.invoiceCode);
    print(payment.amountOfStock);
    print(payment.bankcard);
    print(payment.buyingPriceWithoutTax);
    print(payment.cash);
    print(payment.eftHavale);
    print(payment.repaymentDateTime);
    print(payment.sallingPriceWithoutTax);
    print(payment.total);
    print(payment.unitOfCurrency); */

    final resPayment = await db.supabase.from('payment').insert([
      {
        'product_fk': payment.productFk,
        'supplier_fk': payment.suppliersFk,
        'invoice_code': payment.invoiceCode,
        'unit_of_currency': payment.unitOfCurrency,
        'total': payment.total,
        'cash': payment.cash,
        'bankcard': payment.bankcard,
        'eft_havale': payment.eftHavale,
        'buying_price_without_tax': payment.buyingPriceWithoutTax,
        'salling_price_without_tax': payment.sallingPriceWithoutTax,
        'amount_of_stock': payment.amountOfStock,
        'repayment_date': payment.repaymentDateTime
      }
    ]).execute();
    final errorProduct = resProduct.error;
    final errorPayment = resPayment.error;

    if (errorProduct == null || errorPayment == null) {
      return "";
    } else {
      return "${errorProduct.message} + ${errorPayment.message}";
    }
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
}

final db = DbHelper();
