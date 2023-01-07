import 'database_helper.dart';

class CategoryProductFiltre {
  Stream<List<Map<String, dynamic>>>? fetchCategory1() {
    var res =
        db.supabase.from('category1').stream(primaryKey: ['category1_id']);
    return res;
  }

  Stream<List<Map<String, dynamic>>>? fetchCategory2(int? selectCategory1) {
    if (selectCategory1 != null) {
      var res = db.supabase.from('category2').stream(
          primaryKey: ['category2_id']).eq('fk_category1_id', selectCategory1);

      return res;
    }
    return null;
  }

  Stream<List<Map<String, dynamic>>>? fetchCategory3(int? selectCategory2) {
    if (selectCategory2 != null) {
      var res = db.supabase.from('category3').stream(
          primaryKey: ['category3_id']).eq('fk_category2_id', selectCategory2);

      return res;
    }
    return null;
  }

  Stream<List<Map<String, dynamic>>>? fetchCategory4(int? selectCategory3) {
    if (selectCategory3 != null) {
      var res = db.supabase.from('category4').stream(
          primaryKey: ['category4_id']).eq('fk_category3_id', selectCategory3);

      return res;
    }
    return null;
  }

  Stream<List<Map<String, dynamic>>>? fetchCategory5(int? selectCategory4) {
    if (selectCategory4 != null) {
      var res = db.supabase.from('category5').stream(
          primaryKey: ['category5_id']).eq('fk_category4_id', selectCategory4);

      return res;
    }
    return null;
  }
}

final categoryBlocProductFiltre = CategoryProductFiltre();
