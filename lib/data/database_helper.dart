import 'dart:async';
import 'dart:typed_data';
import 'package:stok_takip/env/env.dart';
import 'package:stok_takip/models/customer.dart';
import 'package:stok_takip/models/payment.dart';
import 'package:stok_takip/models/sale.dart';
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

//Db başlangıç
  static Future dbBaslat() async {
    await Supabase.initialize(url: Env.url, anonKey: Env.apiKey);
  }

  //Giriş Ekran Sorgulama
  Future<Map<String, dynamic>> singIn(
      String setEmail, String setPassword) async {
    Map<String, dynamic> userSessionMap = {};
    bool status = false;

    try {
      final data = await db.supabase.auth
          .signInWithPassword(email: setEmail, password: setPassword);
      status = true;
      userSessionMap.addAll({
        'id': data.user?.id,
        'accessToken': data.session!.accessToken,
        'refreshToken': data.session!.refreshToken,
        'status': status
      });
      return userSessionMap;
    } catch (e) {
      status = false;
      userSessionMap.addAll({'id': "", 'status': status.toString()});
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
      try {
        final resData = await db.supabase
            .from('users')
            .select('name,last_name,role')
            .match({'user_uuid': uuid});

        selectedKullanici = Kullanici.nameSurnameRole(
            name: resData[0]['name'],
            lastName: resData[0]['last_name'],
            role: resData[0]['role'].toString());
        return selectedKullanici;
      } on PostgrestException catch (e) {
        print("Hata FetchNameAndSurnameRole : ${e.message}");
        selectedKullanici = Kullanici.nameSurnameRole(
            name: 'Null', lastName: 'Null', role: 'Null');

        return selectedKullanici;
      }
    }
  }

  ///ROLE GÖRE SAYFALARI GETİRİYOR
  Future<List<dynamic>> fetchPageInfoByRole(String isRole) async {
    List<dynamic> data = [];
    try {
      data = await db.supabase
          .from('path_role_permission')
          .select('class_name')
          .eq('role_id', int.parse(isRole));

      return data;
    } catch (e) {
      return data;
    }
  }

  Future refleshToken(String refleshToken) async {
    try {
      final data = await db.supabase.auth.setSession(refleshToken);
    } on PostgrestException catch (e) {
      print("erorr :${e.message}");
    }
  }

//Kullanıcı Çıkışı
  Future<String?> signOut() async {
    try {
      await db.supabase.auth.signOut();
      return "";
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Kulanıcının Şifresini Güncelleme
  Future<String> updateUserInformation(String newPassword) async {
    try {
      final data = await db.supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
      return "";
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Üye kayıt Fonksiyonu
  Future<String> signUpMy(Kullanici kullanici) async {
    //Auth. kayıt sağlar. Burada Kullanıca UUid belirlenir.
    try {
      final resAuth = await db.supabase.auth.signInWithPassword(
          email: kullanici.email!, password: kullanici.password!);

      //Kullanıcı Role Kaydı
      final roleIdJson = await db.supabase
          .from('roles')
          .select('role_id')
          .eq('role_type', kullanici.role);
      String roleIdString = Map.from(roleIdJson[0])
          .values
          .toString()
          .replaceAll(RegExp(r"[)(]"), '');

      /*  print("**********");
    print(kullanici.name);
    print(kullanici.lastName);
    print(kullanici.email);
    print(kullanici.password);
    print(roleIdString);
    print(resAuth.data!.user!.id);
    print("***********"); */
      //Kulanıcı Bilgileri Kayıt
      await db.supabase.from('users').insert([
        {
          'name': kullanici.name,
          'last_name': kullanici.lastName,
          'email': kullanici.email,
          'password': kullanici.password,
          'user_uuid': resAuth.user!.id,
          'role': roleIdString
        }
      ]);
      return "";
    } on PostgrestException catch (e) {
      print("Hata SignUp : ${e.message}");
      return e.message;
    }
  }

  //Role Listesini Getirir
  Future<List<String>> getRoles() async {
    final List<String> rolesList = [];
    try {
      final resData = await supabase.from('roles').select('role_type');
      final dropdownYetkiListe = <String>[];
      // Burada veritabanından gelen "data" değişkenine atanıyor.
      // Liste içinde map geliyor.
      for (var item in resData) {
        //Gelen  deger value = "(Genel Kullanıcı)" olarak geliyor burada () temizlemek
        //RegExp(r"[]"") ile r zorunlu [] bunların arasındaki karakteri siler.
        dropdownYetkiListe.add(
            Map.from(item).values.toString().replaceAll(RegExp(r"[)(]"), ''));
      }
      return dropdownYetkiListe;
    } on PostgrestException catch (e) {
      print("Hata getRole :${e.message} ");
      return rolesList;
    }
  }

  ///Şehirleri Getirir
  Future<List<String>> getCities(String value) async {
    final citiesList = <String>[];

    try {
      final resData = await supabase.from('cities').select('name');
      for (var item in resData) {
        citiesList.add(item['name']);
      }
      return citiesList;
    } on PostgrestException catch (e) {
      print("Hata Cities : ${e.message}");
      return citiesList;
    }
  }

  ///Şehirlere bağlı İlçeleri getirir
  Future<List<String>> getDistricts(String value, String selectedCity) async {
    final districtsList = <String>[];

    try {
      final resData = await supabase
          .from('district')
          .select('''name,cities(name)''').eq('cities.name', selectedCity);

      for (var item in resData) {
        if (item['cities'] != null) {
          districtsList.add(item['name']);
        }
      }

      /// Türkçe karkterlerine göre sıralanıyor
      districtsList.sort(turkish.comparator);
      return districtsList;
    } on PostgrestException catch (e) {
      print("Hata districts : ${e.message}");
      return districtsList;
    }
  }

  ///VergiDairelerini Getirir 05.01.22 tarihli güncel liste
  ///(veritabanunda kodlarıda bulunmaktadır ama kullanmıyorum)
  Future<List<String>> getTaxOfficeList(
      String value, String? selectedCity) async {
    final taxOfficesNameList = <String>[];
    try {
      final resData = await supabase
          .from('tax_offices')
          .select('''name,cities(name)''').eq('cities.name', selectedCity);

      for (var item in resData) {
        if (item['cities'] != null) {
          taxOfficesNameList.add(item['name']);
        }
      }
      taxOfficesNameList.sort(turkish.comparator);

      return taxOfficesNameList;
    } on PostgrestException catch (e) {
      print("Hata taxOffice : ${e.message}");
      return taxOfficesNameList;
    }
  }

  ///*****************Müşteri kayıt İşlemleri************************
  Future<String> saveCustomerSoleTrader(Customer customerSoleTrader) async {
    try {
      await supabase.from('customer_sole_trader').insert([
        {
          'name': customerSoleTrader.soleTraderName,
          'last_name': customerSoleTrader.soleTraderLastName,
          'phone': customerSoleTrader.phone,
          'city': customerSoleTrader.city,
          'district': customerSoleTrader.district,
          'address': customerSoleTrader.address,
          'tc_no': customerSoleTrader.TCno,
          'type': customerSoleTrader.type
        }
      ]);
      return "";
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  /// Şirket Kayıt
  Future<String> saveCustomerCompany(
    Customer customerCompany,
  ) async {
    try {
      await supabase.from('customer_company').insert([
        {
          'name': customerCompany.companyName,
          'phone': customerCompany.phone,
          'city': customerCompany.city,
          'district': customerCompany.district,
          'address': customerCompany.address,
          'tax_office': customerCompany.taxOffice,
          'tax_number': customerCompany.taxNumber,
          'cargo_company': customerCompany.cargoName,
          'cargo_number': customerCompany.cargoNumber,
        }
      ]);
      return "";
    } on PostgrestException catch (e) {
      print("Hata saveCustomer : ${e.message}");
      return e.message;
    }
  }

  Future<String> saveSuppliers(
    Customer supplier,
  ) async {
    try {
      await supabase.from('suppliers').insert([
        {
          'name': supplier.supplierName,
          'iban': supplier.iban,
          'bank_name': supplier.bankName,
          'phone': supplier.phone,
          'city': supplier.city,
          'district': supplier.district,
          'address': supplier.address,
          'tax_office': supplier.taxOffice,
          'tax_number': supplier.taxNumber,
          'cargo_company': supplier.cargoName,
          'cargo_number': supplier.cargoNumber,
        }
      ]);
      return "";
    } on PostgrestException catch (e) {
      print("Hata SaveSupplier : ${e.message}");
      return e.message;
    }
  }

  ///***********************Product işlemleri*********************************
  Future<List<String>> getProductCode() async {
    final productCode = <String>[];

    try {
      final resData = await supabase.from('product').select('product_code');
      // Burada veritabanından gelen "data" değişkenine atanıyor.
      // Liste içinde map geliyor.
      for (var item in resData) {
        //Gelen  deger value = "(Genel Kullanıcı)" olarak geliyor burada () temizlemek
        //RegExp(r"[]"") ile r zorunlu [] bunların arasındaki karakteri siler.
        productCode.add(
            Map.from(item).values.toString().replaceAll(RegExp(r"[)(]"), ''));
      }
      return productCode;
    } on PostgrestException catch (e) {
      print("Hata Product Code : ${e.message}");
      return productCode;
    }
  }

  ///Tedarikçi isimleri Stream
  Stream<List<Map<String, dynamic>>> getSuppliersNameStream() {
    final resProduct = db.supabase
        .from('suppliers')
        .stream(primaryKey: ['supplier_id']).order('name', ascending: true);

    return resProduct;
  }

  //-----------Kullanılmıyor-----------
  Future<List<String?>> getSuppliersName() async {
    final resData = await supabase
        .from('customer_company')
        .select('name')
        .eq('type', 'Tedarikçi')
        .order('name', ascending: true);

    final productCode = <String>[];
    // Burada veritabanından gelen "data" değişkenine atanıyor.
    // Liste içinde map geliyor.
    for (var item in resData) {
      //Gelen  deger value = "(Genel Kullanıcı)" olarak geliyor burada () temizlemek
      //RegExp(r"[]"") ile r zorunlu [] bunların arasındaki karakteri siler.
      productCode.add(
          Map.from(item).values.toString().replaceAll(RegExp(r"[)(]"), ''));
    }
    return productCode;
  }

  //------------- Kullanılmıyor ----------------
  Future<bool> isThereOnSupplierName(String supplierName) async {
    final resData = await supabase
        .from('customer_company')
        .select('name')
        .eq('type', 'Tedarikçi')
        .match({'name': supplierName});
    final List<dynamic> data = resData;
    if (data.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  /*----------------YENİ ÜRÜN KAYDETME İŞLEMLERİ----------------------*/
  Future<String> saveNewProduct(Product product, Payment payment) async {
    try {
      await supabase.from('product').insert([
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
      ]);

      ///İlk kez yeni bir ürün eklendiğinde payment yeni ürün fiyatını ekliyoruz.
      await supabase.from('payment').insert([
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
      ]);
      return "";
    } on PostgrestException catch (e) {
      print("Hata New Product Add : ${e.message}");
      return e.message;
    }

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
  }

  //*-----------------KULLANILMIYOR--------------------------- */
  Future<Product?> getProductDetail(String productCode) async {
    final resData =
        await supabase.from('product').select().eq('product_code', productCode);

    Category getProductCategory = Category();

    final resCategory1 = await supabase
        .from('category1')
        .select('name')
        .eq('category1_id', resData[0]['fk_category1_id']);

    getProductCategory.category1 = {
      resData[0]['fk_category1_id']: resCategory1[0]['name']
    };

    final resCategory2 = await supabase
        .from('category2')
        .select('name')
        .eq('category2_id', resData[0]['fk_category2_id']);
    getProductCategory.category2 = {
      resData[0]['fk_category2_id']: resCategory2[0]['name']
    };

    final resCategory3 = await supabase
        .from('category3')
        .select('name')
        .eq('category3_id', resData[0]['fk_category3_id']);
    getProductCategory.category3 = {
      resData[0]['fk_category3_id']: resCategory3[0]['name']
    };

    final resCategory4 = await supabase
        .from('category4')
        .select('name')
        .eq('category4_id', resData[0]['fk_category4_id']);
    getProductCategory.category4 = {
      resData[0]['fk_category4_id']: resCategory4[0]['name']
    };

    final resCategory5 = await supabase
        .from('category5')
        .select('name')
        .eq('category5_id', resData[0]['fk_category5_id']);
    getProductCategory.category5 = {
      resData[0]['fk_category5_id']: resCategory5[0]['name']
    };

    Product getProductDetail = Product(
        productCode: resData[0]['product_code'],
        currentAmountOfStock: resData[0]['current_amount_of_stock'],
        taxRate: resData[0]['tax_rate'],
        currentBuyingPriceWithoutTax: resData[0]
            ['current_buying_price_without_tax'],
        currentSallingPriceWithoutTax: resData[0]
            ['current_salling_price_without_tax'],
        category: getProductCategory);

    return getProductDetail;
  }

  Future<Product> fetchProductDetailForSale(String productCode) async {
    final resData =
        await supabase.from('product').select().eq('product_code', productCode);
    //Ürünün Vergili Değeri hesaplanıyor Ve Özelliğine Ekleniyor
    double calculateSallingWithTax = (resData[0]
            ['current_salling_price_without_tax']! *
        (1 + (resData[0]['tax_rate'] / 100)));

    double calculateBuyingWithTax = (resData[0]
            ['current_buying_price_without_tax']! *
        (1 + (resData[0]['tax_rate'] / 100)));

    Product getProductDetailForSale = Product.saleInfo(
        productCode: resData[0]['product_code'],
        currentAmountOfStock: resData[0]['current_amount_of_stock'],
        taxRate: resData[0]['tax_rate'],
        currentBuyingPriceWithoutTax: resData[0]
            ['current_buying_price_without_tax'],
        currentSallingPriceWith: calculateSallingWithTax,
        currentSallingPriceWithoutTax: resData[0]
            ['current_salling_price_without_tax'],
        total: resData[0]['current_salling_price_without_tax'],
        currentBuyingPriceWithTax: calculateBuyingWithTax);

    return getProductDetailForSale;
  }

  Stream<List<Map<String, dynamic>>>? fetchProductDetail() {
    final resProduct = db.supabase.from('product').stream(
        primaryKey: ['product_code']).order('product_code', ascending: true);

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

  //Ürün silme StokEdit Sayfasında kullanılıyor.
  Future<String> deleteProduct(String productCode) async {
    try {
      await db.supabase
          .from('product')
          .delete()
          .match({'product_code': productCode});
      return "";
    } on PostgrestException catch (e) {
      print("Hata Product Delete : ${e.message}");
      return e.message;
    }

    ///Birden fazla değp ekleme için kullanılmak için ön çalışma.
    /* final resStorehouseStock = await db.supabase
        .from('storehouse_stock')
        .delete()
        .match({'product_fk': productCode}).execute();

    final errorStorehouse = resStorehouseStock.error; */
  }

  //Stok Güncelleme için Kullanılıyor
  Future<String> updateProductDetail(
      String productCode, Map<String, dynamic> data, Payment payment) async {
    try {
      await db.supabase
          .from('product')
          .update(data)
          .match({'product_code': productCode});
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
      ]);
      return "";
    } on PostgrestException catch (e) {
      print("Hata Product Update : ${e.message}");
      return e.message;
    }
  }

  ///Kullanıcı Şifresini değiştirmek istediğinde Kullanıcının o anki şifresini
  ///istoruz kişi güvenliği için
  Future<String?> getPassword(String? uuid) async {
    try {
      final resData =
          await supabase.from('users').select('*').match({'user_uuid': uuid});
      return resData[0]['password'];
    } on PostgrestException catch (e) {
      print("Hata getPassword : ${e.message}");
      return "";
    }
  }

  /// Şifre Değiştirme Yeri
  Future<String> saveNewPassword(String? newPassword, String userId) async {
    try {
      await supabase
          .from('users')
          .update({'password': newPassword}).eq('user_uuid', userId);
      return "";
    } on PostgrestException catch (e) {
      print("Hata NewPassword : ${e.message}");
      return e.message;
    }
  }

  /*-----------------------SATIŞ EKRANI İŞLEMLERİ----------------------------*/
  ///***********************Product işlemleri*********************************
  /* Future<List<Map<String, String>>> fetchCustomerAndPhone() async {
    final listCustomer = <Map<String, String>>[];

    try {
      final List<Map<String, dynamic>> resDataSoleTrader = await supabase
          .from('customer_sole_trader')
          .select('name,last_name,phone,type');

      final List<Map<String, dynamic>> resDataCompany =
          await supabase.from('customer_company').select('name,phone,type');

      // Burada veritabanından gelen "data" değişkenine atanıyor.
      // Liste içinde map geliyor.
      for (var item in resDataSoleTrader) {
        listCustomer.add({
          'type': item['type'],
          'name': "${item['name']} ${item['last_name']}",
          'phone': item['phone']
        });
      }

      for (var item in resDataCompany) {
        listCustomer.add({
          'type': item['type'],
          'name': item['name'],
          'phone': item['phone']
        });
      }
      return listCustomer;
    } on PostgrestException catch (e) {
      print("Hata Product Code : ${e.message}");
      return listCustomer;
    }
  } */
/*------------------------ POP-UP Müşteri ARAMA BÖLÜMÜ--------------------*/
//Şahıs müşterileri getiriyor.
  Stream fetchSoloCustomerAndPhoneStream() {
    try {
      final resDataSoleTrader = supabase
          .from('customer_sole_trader')
          .stream(primaryKey: ['customer_id']);

      return resDataSoleTrader;
    } on PostgrestException catch (e) {
      print("Hata Product Code : ${e.message}");

      return const Stream.empty();
    }
  }

//Firma Müşterilerini getiriyor
  Stream fetchCompanyCustomerAndPhoneStream() {
    try {
      final resDataCompany =
          supabase.from('customer_company').stream(primaryKey: ['customer_id']);

      return resDataCompany;
    } on PostgrestException catch (e) {
      print("Hata Product Code : ${e.message}");
      return const Stream.empty();
    }
  }

/*-----------------------------ARA SON---------------------------------------*/
  Future<Map<String, dynamic>> saveSale(
      Sale soldProducts, List<Product> listProduct) async {
    Map<String, dynamic> resData = {'hata': null, 'invoice_number': null};
    try {
      final List<dynamic> customerId;
      final List<Map<String, dynamic>> tempSoldProductsList =
          <Map<String, dynamic>>[];
      if (soldProducts.customerType == "Şahıs") {
        customerId = await supabase
            .from('customer_sole_trader')
            .select('customer_id')
            .eq('phone', soldProducts.customerPhone);
      } else {
        customerId = await supabase
            .from('customer_company')
            .select('customer_id')
            .eq('phone', soldProducts.customerPhone);
      }

      final res = await supabase.from('sales').insert([
        {
          'customer_type': soldProducts.customerType,
          'customer_fk': customerId[0]['customer_id'],
          'total_payment_without_tax': soldProducts.totalPaymentWithoutTax,
          'kdv_rate': soldProducts.kdvRate,
          'cash_payment': soldProducts.cashPayment,
          'bankcard_payment': soldProducts.bankcardPayment,
          'eft_havale_payment': soldProducts.eftHavalePayment,
          'unit_of_currency': soldProducts.unitOfCurrency,
          'payment_next_date': soldProducts.paymentNextDate,
          'seller': soldProducts.userId
        }
      ]).select('invoice_number');

      for (var elementSold in soldProducts.soldProductsList) {
        for (var orjinalProduct in listProduct) {
          if (orjinalProduct.productCode == elementSold.productCode) {
            int newStockAmount =
                orjinalProduct.currentAmountOfStock - elementSold.productAmount;

            await supabase
                .from('product')
                .update({'current_amount_of_stock': newStockAmount}).eq(
                    'product_code', elementSold.productCode);
          }
        }

        tempSoldProductsList.add({
          'sales_fk': res[0]['invoice_number'],
          'product_code': elementSold.productCode,
          'product_amount': elementSold.productAmount,
          'product_price_without_tax': elementSold.productPriceWithoutTax
        });
      }
      await supabase.from('sales_detail').insert(tempSoldProductsList);

      resData['invoice_number'] = res[0]['invoice_number'];

      return resData;
    } on PostgrestException catch (e) {
      print("Hata Save Sale : ${e.message}");
      resData['hata'] = e.message;
      return resData;
    }
  }

  /*----------------------------------------------------------------------- */
  /*-----------------------------FATURA İŞLEMLERİ---------------------------*/
  //Seçilen müşteri bilgileri alınıyor
  Future<List<dynamic>> fetchSelectCustomerInformation(
      String customerType, String customerPhone) async {
    List<dynamic> resCustomerInfo = [];
    try {
      if (customerType == "Şahıs") {
        resCustomerInfo = await supabase
            .from('customer_sole_trader')
            .select('name,last_name,phone,address,city,district,tc_no,type')
            .eq('phone', customerPhone);
        //seçilen kişi Firma ise burası çalışıyor.
      } else {
        resCustomerInfo = await supabase
            .from('customer_company')
            .select(
                'name,phone,address,city,district,tax_number,tax_office,type')
            .eq('phone', customerPhone);
      }
      return resCustomerInfo;
    } on PostgrestException catch (e) {
      print("Hata : ${e.message}");
      return resCustomerInfo;
    }
  }

  //Kendi şirket Bilgilerini çekiyor.
  Future<List<dynamic>> fetchMyCompanyInformation() async {
    List<dynamic> res = [];
    try {
      res = await db.supabase.from('company_information').select('*');

      return res;
    } on PostgrestException catch (e) {
      print("Hata New Product Add : ${e.message}");
      return res;
    }
  }

  /*---------------------------------------------------------------- */
  /*-----------------------------CARİ EKRANIN İŞLEMLERİ-------------------- */
//TODO:buradan başla
  Future<List<dynamic>> fetchCustomerSolo() async {
    List<dynamic> res = [];
    try {
      res = await db.supabase.from('customer_sole_trader').select('phone');
      return res;
    } on PostgrestException catch (e) {
      print("Hata Cari Sahıs: ${e.message}");
      return res;
    }
  }

  Future<List<dynamic>> fetchCustomerCompany() async {
    List<dynamic> res = [];
    try {
      res = await db.supabase.from('customer_company').select('name,type');
      return res;
    } on PostgrestException catch (e) {
      print("Hata Cari Firma: ${e.message}");
      return res;
    }
  }

  Future<List<dynamic>> fetchSuppliers() async {
    List<dynamic> res = [];
    try {
      res = await db.supabase.from('suppliers').select('name,type');
      return res;
    } on PostgrestException catch (e) {
      print("Hata Cari Tedarikci: ${e.message}");
      return res;
    }
  }

  /*  Future<List<dynamic>> fetchCari(Map<String, String> customerInfo) async {
    final res = await db.supabase.from('sales').select('''
      customer_fk,
      customer_solo_trader:customer_id(phone)
    ''');
    print(res);
    return res;
  } */
}

final db = DbHelper();
