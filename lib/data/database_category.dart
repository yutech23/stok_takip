import 'package:flutter/material.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/category.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

class DbCategory {
  late DbHelper db;

  DbCategory() {
    db = DbHelper();
  }

  Future<bool> saveNewCategory(BuildContext context,
      GlobalKey<FormState> formKey, CategoryString category) async {
    //Buttona forKey.currentSaate.validate() sayesinde validata() hepsi tetikleniyor.
    //validate() değeri null ise dönen değer true bu sayede if bloku çalışır. dataBase
    //kayıt işlemleri gerçekleşir.
    bool saveController = true;
    if (formKey.currentState!.validate() &&
        category.category1!.isNotEmpty &&
        category.category2!.isNotEmpty &&
        category.category3!.isNotEmpty &&
        category.category4!.isNotEmpty &&
        category.category5!.isNotEmpty) {
      ///Kategoride aynı veri olup olmadığını kontrol ediliyor ki Tekrar aynı
      ///kategori oluşturulmasın için burada kontrol ediliyor.

      final getCategory1 = await db.supabase.from('category1').select('name');

      for (var item in getCategory1.data) {
        if (category.category1 == item['name']) {
          saveController = false;
          break;
        }
      }

      if (saveController) {
        //Auth. kayıt sağlar. Burada Kullanıca UUid belirlenir.
        final resCategory1Id = await db.supabase.from('category1').insert([
          {'name': category.category1},
        ]);

        final resCategory2Id = await db.supabase.from('category2').insert([
          {
            'name': category.category2,
            'fk_category1_id': Map.of(resCategory1Id.data[0]).values.first
          }
        ]);
        final resCategory3Id = await db.supabase.from('category3').insert([
          {
            'name': category.category3,
            'fk_category2_id': Map.of(resCategory2Id.data[0]).values.first
          }
        ]);
        final resCategory4Id = await db.supabase.from('category4').insert([
          {
            'name': category.category4,
            'fk_category3_id': Map.of(resCategory3Id.data[0]).values.first
          }
        ]);
        final resCategory5Id = await db.supabase.from('category5').insert([
          {
            'name': category.category5,
            'fk_category4_id': Map.of(resCategory4Id.data[0]).values.first
          }
        ]);
        final errorCategory1 = resCategory1Id.hasError;
        final errorCategory2 = resCategory2Id.hasError;
        final errorCategory3 = resCategory3Id.hasError;
        final errorCategory4 = resCategory4Id.hasError;
        final errorCategory5 = resCategory5Id.hasError;

        if (errorCategory1 == true ||
            errorCategory2 == true ||
            errorCategory3 == true ||
            errorCategory4 == true ||
            errorCategory5 == true) {
          // ignore: use_build_context_synchronously
          context.extensionShowErrorSnackBar(
              message: "Kayıt yapılır iken bir hata ile karşılaşıldı");
          return false;
        } else {
          // ignore: use_build_context_synchronously
          context.extenionShowSnackBar(
              message: "Başarılı bir şekilde Kaydedildi.");
          return true;
        }
      } else {
        // ignore: use_build_context_synchronously
        context.extensionShowErrorSnackBar(
            message:
                "Kayıtlı bir kategori seçtiniz. Lütfen kategori düzenleme bölümünden yapınız");
        return false;
      }
    } else {
      context.extensionShowErrorSnackBar(
          message: "Lütfen Tüm Alanları Doldurun");
      return false;
    }
  }

  Future<bool> saveOnSubCategory2(
      {required BuildContext context,
      required Category categoryMap,
      required CategoryString categoryString,
      required ValueNotifier<int> categoryIndex}) async {
    bool saveController = true;
    if (categoryString.category2!.isNotEmpty &&
        categoryString.category3!.isNotEmpty &&
        categoryString.category4!.isNotEmpty &&
        categoryString.category5!.isNotEmpty) {
      final getCategory2 = await db.supabase
          .from('category2')
          .select('name')
          .eq('fk_category1_id', categoryMap.category1!.keys.first);

      for (var item in getCategory2.data) {
        if (categoryString.category2 == item['name']) {
          saveController = false;
          break;
        }
      }

      if (saveController) {
        final resSubSave2 = await db.supabase.from('category2').insert([
          {
            'name': categoryString.category2,
            'fk_category1_id': categoryMap.category1!.keys.first
          }
        ]);

        final resSubSave3 = await db.supabase.from('category3').insert([
          {
            'name': categoryString.category3,
            'fk_category2_id': Map.of(resSubSave2.data[0]).values.first
          }
        ]);
        final resSubSave4 = await db.supabase.from('category4').insert([
          {
            'name': categoryString.category4,
            'fk_category3_id': Map.of(resSubSave3.data[0]).values.first
          }
        ]);
        final resSubSave5 = await db.supabase.from('category5').insert([
          {
            'name': categoryString.category5,
            'fk_category4_id': Map.of(resSubSave4.data[0]).values.first
          }
        ]);
        final errorSubSave2 = resSubSave2.hasError;
        final errorSubSave3 = resSubSave3.hasError;
        final errorSubSave4 = resSubSave4.hasError;
        final errorSubSave5 = resSubSave5.hasError;

        if (errorSubSave2 == true ||
            errorSubSave3 == true ||
            errorSubSave4 == true ||
            errorSubSave5 == true) {
          // ignore: use_build_context_synchronously
          context.extensionShowErrorSnackBar(
              message: "Kayıt yapılır iken bir hata ile karşılaşıldı");
          return false;
        } else {
          // ignore: use_build_context_synchronously
          context.extenionShowSnackBar(
              message: "Başarılı bir şekilde Kaydedildi.");
          return true;
        }
      } else {
        // ignore: use_build_context_synchronously
        context.extensionShowErrorSnackBar(
            message:
                "Kayıtlı bir kategori seçtiniz. Lütfen kategori düzenleme bölümünden yapınız");
        return false;
      }
    } else {
      context.extensionShowErrorSnackBar(
          message: "Lütfen Tüm Alanları Doldurun");
      return false;
    }
  }

  Future<bool> saveOnSubCategory3(
      {required BuildContext context,
      required Category categoryMap,
      required CategoryString categoryString,
      required ValueNotifier<int> categoryIndex}) async {
    bool saveController = true;
    if (categoryString.category3!.isNotEmpty &&
        categoryString.category4!.isNotEmpty &&
        categoryString.category5!.isNotEmpty) {
      final getCategory3 = await db.supabase
          .from('category3')
          .select('name')
          .eq('fk_category2_id', categoryMap.category2!.keys.first);

      for (var item in getCategory3.data) {
        if (categoryString.category3 == item['name']) {
          saveController = false;
          break;
        }
      }

      if (saveController) {
        final resSubSave3 = await db.supabase.from('category3').insert([
          {
            'name': categoryString.category3,
            'fk_category2_id': categoryMap.category2!.keys.first
          }
        ]);
        final resSubSave4 = await db.supabase.from('category4').insert([
          {
            'name': categoryString.category4,
            'fk_category3_id': Map.of(resSubSave3.data[0]).values.first
          }
        ]);
        final resSubSave5 = await db.supabase.from('category5').insert([
          {
            'name': categoryString.category5,
            'fk_category4_id': Map.of(resSubSave4.data[0]).values.first
          }
        ]);

        final errorSubSave3 = resSubSave3.hasError;
        final errorSubSave4 = resSubSave4.hasError;
        final errorSubSave5 = resSubSave5.hasError;

        if (errorSubSave3 == true ||
            errorSubSave4 == true ||
            errorSubSave5 == true) {
          // ignore: use_build_context_synchronously
          context.extensionShowErrorSnackBar(
              message: "Kayıt yapılır iken bir hata ile karşılaşıldı");
          return false;
        } else {
          // ignore: use_build_context_synchronously
          context.extenionShowSnackBar(
              message: "Başarılı bir şekilde Kaydedildi.");
          return true;
        }
      } else {
        // ignore: use_build_context_synchronously
        context.extensionShowErrorSnackBar(
            message:
                "Kayıtlı bir kategori seçtiniz. Lütfen kategori düzenleme bölümünden yapınız");
        return false;
      }
    } else {
      context.extensionShowErrorSnackBar(
          message: "Lütfen Tüm Alanları Doldurun");
      return false;
    }
  }

  Future<bool> saveOnSubCategory4(
      {required BuildContext context,
      required Category categoryMap,
      required CategoryString categoryString,
      required ValueNotifier<int> categoryIndex}) async {
    bool saveController = true;
    if (categoryString.category4!.isNotEmpty &&
        categoryString.category5!.isNotEmpty) {
      final getCategory4 = await db.supabase
          .from('category4')
          .select('name')
          .eq('fk_category3_id', categoryMap.category3!.keys.first);

      for (var item in getCategory4.data) {
        if (categoryString.category4 == item['name']) {
          saveController = false;
          break;
        }
      }

      if (saveController) {
        final resSubSave4 = await db.supabase.from('category4').insert([
          {
            'name': categoryString.category4,
            'fk_category3_id': categoryMap.category3!.keys.first
          }
        ]);
        final resSubSave5 = await db.supabase.from('category5').insert([
          {
            'name': categoryString.category5,
            'fk_category4_id': Map.of(resSubSave4.data[0]).values.first
          }
        ]);

        final errorSubSave4 = resSubSave4.hasError;
        final errorSubSave5 = resSubSave5.hasError;

        if (errorSubSave4 == true || errorSubSave5 == true) {
          // ignore: use_build_context_synchronously
          context.extensionShowErrorSnackBar(
              message: "Kayıt yapılır iken bir hata ile karşılaşıldı");
          return false;
        } else {
          // ignore: use_build_context_synchronously
          context.extenionShowSnackBar(
              message: "Başarılı bir şekilde Kaydedildi.");
          return true;
        }
      } else {
        // ignore: use_build_context_synchronously
        context.extensionShowErrorSnackBar(
            message:
                "Kayıtlı bir kategori seçtiniz. Lütfen kategori düzenleme bölümünden yapınız");
        return false;
      }
    } else {
      context.extensionShowErrorSnackBar(
          message: "Lütfen Tüm Alanları Doldurun");
      return false;
    }
  }

  Future<bool> saveOnSubCategory5(
      {required BuildContext context,
      required Category categoryMap,
      required CategoryString categoryString,
      required ValueNotifier<int> categoryIndex}) async {
    bool saveController = true;
    if (categoryString.category5!.isNotEmpty) {
      final getCategory5 = await db.supabase
          .from('category5')
          .select('name')
          .eq('fk_category4_id', categoryMap.category4!.keys.first);

      for (var item in getCategory5.data) {
        if (categoryString.category5 == item['name']) {
          saveController = false;
          break;
        }
      }

      if (saveController) {
        final resSubSave5 = await db.supabase.from('category5').insert([
          {
            'name': categoryString.category5,
            'fk_category4_id': categoryMap.category4!.keys.first
          }
        ]);

        final errorSubSave5 = resSubSave5.hasError;

        if (errorSubSave5 == true) {
          // ignore: use_build_context_synchronously
          context.extensionShowErrorSnackBar(
              message: "Kayıt yapılır iken bir hata ile karşılaşıldı");
          return false;
        } else {
          // ignore: use_build_context_synchronously
          context.extenionShowSnackBar(
              message: "Başarılı bir şekilde Kaydedildi.");
          return true;
        }
      } else {
        // ignore: use_build_context_synchronously
        context.extensionShowErrorSnackBar(
            message:
                "Kayıtlı bir kategori seçtiniz. Lütfen kategori düzenleme bölümünden yapınız");
        return false;
      }
    } else {
      context.extensionShowErrorSnackBar(
          message: "Lütfen Tüm Alanları Doldurun");
      return false;
    }
  }

  Future deleteSelectedCategory(Category category, int selectedCategory) async {
    if (selectedCategory == 1) {
      await db.supabase
          .from('category1')
          .delete()
          .match({'category1_id': category.category1!.keys.first});
    } else if (selectedCategory == 2) {
      await db.supabase
          .from('category2')
          .delete()
          .match({'category2_id': category.category2!.keys.first});
    } else if (selectedCategory == 3) {
      await db.supabase
          .from('category3')
          .delete()
          .match({'category3_id': category.category3!.keys.first});
    } else if (selectedCategory == 4) {
      await db.supabase
          .from('category4')
          .delete()
          .match({'category4_id': category.category4!.keys.first});
    } else if (selectedCategory == 5) {
      await db.supabase
          .from('category5')
          .delete()
          .match({'category5_id': category.category5!.keys.first});
    }
  }
}

final dbCategory = DbCategory();
