import 'package:stok_takip/data/database_fetch_category.dart';

import '../data/database_save_new_category.dart';
import '../models/category.dart';

class BlocCategory {
  final Category category = Category();

  ///listelerin içindeki seçilen satırı index atıyoruz. Bu sayede o satırdaki
  ///veriyi alıyoruz. Background color değiştirmek içinde kullanılıyor.
  ///her liste için ayrı index oluşturlmalı yoksa karışıyor.
  ///listSelectIndex[0] category1 'deki seçilen index tutuyor..
  ///listSelectIndex[1] category2 'deki list seçimi. diye devam ediyor.
  final listSelectIndex = List<int?>.filled(5, null);

  ///ilk kategori verisi seçildiğinde sonra değiştirildiğinde Listelerin güncellenmesi için burada temp data tuluyor bu sayede category.category1 vb. veri değişimi izleniyor. 5 kategori olduğu için 5 boyutlu liste oluşturuluyor.
  final _temp = List<String?>.filled(5, null);

  bool enableCategoryTextFormField = false;

  Map<int, String> selectedCategory = {};

  deleteCategory() async {
    ///listSelectIndex seçilen categoriye kadar doluyor.
    ///ona göre siliyor.
    int selectedCategory = 0;
    for (var i = 0; i < listSelectIndex.length; i++) {
      if (listSelectIndex[i] != null) {
        selectedCategory++;
      }
    }

    ///silme işleminden sonra select siliyor.
    listSelectIndex[selectedCategory - 1] = null;
    await dbCategory.deleteSelectedCategory(category, selectedCategory);

    /*  switch (res) {
      case 1:
        category.category1!.clear();
        break;
      case 2:
        category.category2!.clear();
        break;
      case 3:
        category.category3!.clear();
        break;
      case 4:
        category.category4!.clear();
        break;
      case 5:
        category.category5!.clear();
        break;
      default:
    } */
  }

  selectCategory1(Map<int, String>? category1Name, int index) {
    ///Burada ki listSelectIndex sayesinde background
    ///rengini değişimi sağlanılıyor.
    listSelectIndex[0] = index;

    ///burada değer seçilen değer categoriye atanıyor
    category.category1 = category1Name;
    //Seçilen kategori
    selectedCategory = category1Name!;

    ///Category 1 değiştiğinde diğer kategorilerde seçili olan ve tutulan değerleri siliyor.
    if (_temp[0] != category.category1!.values.first) {
      listSelectIndex[1] = null; //seçili olmasını sıfırlıyor
      category.category2 = null;
      category.category3 = null;
      category.category4 = null;
      listSelectIndex[2] = null;
      listSelectIndex[3] = null;
      listSelectIndex[4] = null;
    }

    ///ilk seçilen değer ile farklı anlamak için geçici
    ///bir değişkene atılıyor
    _temp[0] = category.category1?.values.first;
    changeEnableCategoryTextFormField();
  }

  selectCategory2(Map<int, String>? category2Name, int index) {
    ///ilk başta listSelectIndex = null olduğunda girer.
    /// Buradaki amaç aynı öğe liste seçildiğinde öndeki select lerin sıfırlanması
    ///  gerek ki Delete işlemi yapabilmemiz için.(delete widget.blocCategory.listSelectIndex yapılıyor.)
    if (listSelectIndex[1] != index) {
      listSelectIndex[1] = index;
    } else {
      listSelectIndex[2] = null;
      listSelectIndex[3] = null;
      listSelectIndex[4] = null;
      category.category3 = null;
      category.category4 = null;
      category.category5 = null;
    }

    category.category2 = category2Name;
    //Seçilen kategori
    selectedCategory = category2Name!;

    if (_temp[1] != category.category2!.values.first) {
      category.category3 = null;
      category.category4 = null;
      category.category5 = null;
      listSelectIndex[2] = null; //seçili olmasını sıfırlıyor
    }

    ///ilk seçilen değer ile farklı anlamak için geçici
    ///bir değişkene atılıyor
    _temp[1] = category.category2?.values.first;
    changeEnableCategoryTextFormField();
  }

  selectCategory3(Map<int, String>? category3Name, int index) {
    ///ilk seçilen değer ile farklı anlamak için geçici
    ///bir değişkene atılıyor
    _temp[2] = category.category3?.values.first;

    ///ilk başta listSelectIndex = null olduğunda girer.
    ///Buradaki amaç aynı öğe liste seçildiğinde öndeki
    ///select lerin sıfırlanması gerek ki Delete işlemi
    ///yapabilmemiz için.(delete widget.blocCategory.listSelectIndex yapılıyor.)
    if (listSelectIndex[2] != index) {
      listSelectIndex[2] = index;
    } else {
      listSelectIndex[3] = null;
      listSelectIndex[4] = null;
      category.category4 = null;
      category.category5 = null;
    }

    category.category3 = category3Name;
    //Seçilen kategori
    selectedCategory = category3Name!;
    if (_temp[2] != category.category3!.values.first) {
      category.category4 = null;
      listSelectIndex[3] = null; //seçili olmasını sıfırlıyor

      category.category4 = null;
      category.category5 = null;
    }

    ///ilk seçilen değer ile farklı anlamak için geçici
    ///bir değişkene atılıyor
    _temp[2] = category.category3?.values.first;
    changeEnableCategoryTextFormField();
  }

  selectCategory4(Map<int, String>? category4Name, int index) {
    ///ilk başta listSelectIndex = null olduğunda girer.
    ///Buradaki amaç aynı öğe liste seçildiğinde öndeki
    ///select lerin sıfırlanması gerek ki Delete işlemi
    ///yapabilmemiz için.(delete widget.blocCategory.listSelectIndex yapılıyor.)
    if (listSelectIndex[3] != index) {
      listSelectIndex[3] = index;
    } else {
      listSelectIndex[4] = null;
    }

    category.category4 = category4Name;
    //Seçilen kategori
    selectedCategory = category4Name!;
    if (_temp[3] != category.category4!.values.first) {
      listSelectIndex[4] = null; //seçili olmasını sıfırlıyor

      category.category5 = null;
    }

    ///ilk seçilen değer ile farklı anlamak için geçici
    ///bir değişkene atılıyor
    _temp[3] = category.category4?.values.first;
    changeEnableCategoryTextFormField();
  }

  selectCategory5(Map<int, String>? category5Name, int index) {
    listSelectIndex[4] = index;
    category.category5 = category5Name;
    //Seçilen kategori
    selectedCategory = category5Name!;
    changeEnableCategoryTextFormField();
  }

  changeEnableCategoryTextFormField() {
    if (category.category1 != null ||
        category.category2 != null ||
        category.category3 != null ||
        category.category5 != null ||
        category.category5 != null) {
      enableCategoryTextFormField = true;
    }
    print(selectedCategory);
  }

  Future<String> updateNewCategoryValue(String newValue) async {
    int selectedCategoryIndex = 0;
    for (var i = 0; i < listSelectIndex.length; i++) {
      if (listSelectIndex[i] != null) {
        selectedCategoryIndex++;
      }
    }
    String res = await categoryBloc.updateNewCategoryValue(
        category, selectedCategoryIndex, selectedCategory, newValue);
    return res;
  }
}
