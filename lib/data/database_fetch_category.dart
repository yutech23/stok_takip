import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';
import 'database_helper.dart';

class FetchCategory {
  Stream<List<Map<String, dynamic>>>? getCategory1() {
    var res =
        db.supabase.from('category1').stream(primaryKey: ['category1_id']);
    return res;
  }

  Stream<List<Map<String, dynamic>>>? getCategory2(
      Map<int, String>? selectCategory1) {
    if (selectCategory1 != null) {
      var res = db.supabase
          .from('category2')
          .stream(primaryKey: ['category2_id']).eq(
              'fk_category1_id', selectCategory1.keys.first);
      return res;
    }
    return null;
  }

  Stream<List<Map<String, dynamic>>>? getCategory3(
      Map<int, String>? selectCategory2) {
    if (selectCategory2 != null) {
      var res = db.supabase
          .from('category3')
          .stream(primaryKey: ['category3_id']).eq(
              'fk_category2_id', selectCategory2.keys.first);

      return res;
    }
    return null;
  }

  Stream<List<Map<String, dynamic>>>? getCategory4(
      Map<int, String>? selectCategory3) {
    if (selectCategory3 != null) {
      var res = db.supabase
          .from('category4')
          .stream(primaryKey: ['category4_id']).eq(
              'fk_category3_id', selectCategory3.keys.first);

      return res;
    }
    return null;
  }

  Stream<List<Map<String, dynamic>>>? getCategory5(
      Map<int, String>? selectCategory4) {
    if (selectCategory4 != null) {
      var res = db.supabase
          .from('category5')
          .stream(primaryKey: ['category5_id']).eq(
              'fk_category4_id', selectCategory4.keys.first);

      return res;
    }
    return null;
  }

  Future<String> updateNewCategoryValue(
      Category category,
      int selectedCategoryIndex,
      Map<int, String> selectedCategory,
      String newValue) async {
    try {
      if (selectedCategoryIndex == 1) {
        await db.supabase.from('category1').update({'name': newValue}).eq(
            'category1_id', selectedCategory.keys.first);
        return "";
      } else if (selectedCategoryIndex == 2) {
        await db.supabase.from('category2').update({'name': newValue}).eq(
            'category2_id', selectedCategory.keys.first);
        return "";
      } else if (selectedCategoryIndex == 3) {
        await db.supabase.from('category3').update({'name': newValue}).eq(
            'category3_id', selectedCategory.keys.first);
        return "";
      } else if (selectedCategoryIndex == 4) {
        await db.supabase.from('category4').update({'name': newValue}).eq(
            'category4_id', selectedCategory.keys.first);
        return "";
      } else if (selectedCategoryIndex == 5) {
        await db.supabase.from('category5').update({'name': newValue}).eq(
            'category5_id', selectedCategory.keys.first);
        return "";
      }
      return "";
    } on PostgrestException catch (e) {
      print("Hata: ${e.message}");
      return e.message;
    }
  }
}

final categoryBloc = FetchCategory();
