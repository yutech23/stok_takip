import '../data/database_helper.dart';

class BlocProductFiltre {
  Stream<List<Map<String, dynamic>>>? fetchCategory1() {
    var res =
        db.supabase.from('category1').stream(['category1_id,name']).execute();
    return res;
  }

  Stream<List<Map<String, dynamic>>>? fetchCategory2(int? selectCategory1) {
    if (selectCategory1 != null) {
      var res = db.supabase
          .from('category2:fk_category1_id=eq.$selectCategory1')
          .stream(['category2_id,name']).execute();

      return res;
    }
    return null;
  }

  Stream<List<Map<String, dynamic>>>? fetchCategory3(int? selectCategory2) {
    if (selectCategory2 != null) {
      var res = db.supabase
          .from('category3:fk_category2_id=eq.$selectCategory2')
          .stream(['category3_id,name']).execute();

      return res;
    }
    return null;
  }


  Stream<List<Map<String, dynamic>>>? fetchCategory4(int? selectCategory3) {
    if (selectCategory3 != null) {
      var res = db.supabase
          .from('category4:fk_category3_id=eq.$selectCategory3')
          .stream(['category4_id,name']).execute();

      return res;
    }
    return null;
  }

  Stream<List<Map<String, dynamic>>>? fetchCategory5(int? selectCategory4) {
    if (selectCategory4 != null) {
      var res = db.supabase
          .from('category5:fk_category4_id=eq.$selectCategory4')
          .stream(['category5_id,name']).execute();

      return res;
    }
    return null;
  }

}

final filtreBloc = BlocProductFiltre();
