import 'dart:async';

import '../data/database_helper.dart';

class BlocCategory {
  Stream<List<Map<String, dynamic>>>? getCategory1() {
    var res =
        db.supabase.from('category1').stream(['category1_id,name']).execute();
    return res;
  }

  Stream<List<Map<String, dynamic>>>? getCategory2(
      Map<int, String>? selectCategory1) {
    if (selectCategory1 != null) {
      var res = db.supabase
          .from('category2:fk_category1_id=eq.${selectCategory1.keys.first}')
          .stream(['category2_id,name']).execute();
      return res;
    }
  }

  Stream<List<Map<String, dynamic>>>? getCategory3(
      Map<int, String>? selectCategory2) {
    if (selectCategory2 != null) {
      var res = db.supabase
          .from('category3:fk_category2_id=eq.${selectCategory2.keys.first}')
          .stream(['category3_id,name']).execute();

      return res;
    }
  }

  Stream<List<Map<String, dynamic>>>? getCategory4(
      Map<int, String>? selectCategory3) {
    if (selectCategory3 != null) {
      var res = db.supabase
          .from('category4:fk_category3_id=eq.${selectCategory3.keys.first}')
          .stream(['category4_id,name']).execute();

      return res;
    }
  }

  Stream<List<Map<String, dynamic>>>? getCategory5(
      Map<int, String>? selectCategory4) {
    if (selectCategory4 != null) {
      var res = db.supabase
          .from('category5:fk_category4_id=eq.${selectCategory4.keys.first}')
          .stream(['category5_id,name']).execute();
      print(res);
      return res;
    }
  }
}

final categoryBloc = BlocCategory();
