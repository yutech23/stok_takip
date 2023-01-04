import 'package:flutter/material.dart';
import 'package:stok_takip/bloc/bloc_category.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_widgets.dart';
import '../data/database_category.dart';
import '../models/category.dart';

class WidgetCategoryDelete extends StatefulWidget {
  const WidgetCategoryDelete({super.key});

  @override
  State<WidgetCategoryDelete> createState() => _WidgetCategoryDeleteState();
}

class _WidgetCategoryDeleteState extends State<WidgetCategoryDelete> {
  final Category _category = Category();

  ///Oluşturlan Listelerin Scroll Kontrolu için oluşturuldu.
  late final List<ScrollController> _controllerScrollList = [];

  ///listelerin içindeki seçilen satırı index atıyoruz. Bu sayede o satırdaki
  ///veriyi alıyoruz. Background color değiştirmek içinde kullanılıyor.
  ///her liste için ayrı index oluşturlmalı yoksa karışıyor.
  final _listSelectIndex = List<int?>.filled(5, null);

  ///ilk kategori verisi seçildiğinde sonra değiştirildiğinde Listelerin güncellenmesi
  ///için burada temp data tuluyor bu sayede category.category1 vb. veri değişimi
  ///izleniyor. 5 kategori olduğu için 5 boyutlu liste oluşturuluyor.
  final _temp = List<String?>.filled(5, null);

  final List<int> _lenghtCategorylistUpdate = [];

  final GlobalKey _globalListviewKey = GlobalKey();
  final ValueNotifier<int> _selectedChangeColor = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    // 5 adet ScrollController Olacağından Burada hepsi oluşturuluyor.
    for (var i = 0; i < 5; i++) {
      _controllerScrollList.add(ScrollController());
    }
  }

  @override
  void dispose() {
    _controllerScrollList.clear();
    _listSelectIndex.clear();
    _temp.clear();
    _lenghtCategorylistUpdate.clear();

    _selectedChangeColor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildCategoryDelete();
  }

  Widget buildCategoryDelete() {
    return Form(
        child: Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      decoration: context.extensionThemaGreyContainer(),
      child: Container(
        constraints: const BoxConstraints(minWidth: 360, maxWidth: 750),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        decoration: context.extensionThemaWhiteContainer(),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
                direction: Axis.horizontal,
                spacing: 10,
                runSpacing: 20,
                verticalDirection: VerticalDirection.down,
                children: [
                  widgetCategory1Show(_controllerScrollList[0]),
                  widgetCategory2Show(_controllerScrollList[1]),
                  widgetCategory3Show(_controllerScrollList[2]),
                  widgetCategory4Show(_controllerScrollList[3]),
                  widgetCategory5Show(_controllerScrollList[4]),
                ]),
            widgetDeleteButton(),
          ],
        ),
      ),
    ));
  }

  widgetCategory1Show(ScrollController controllerScroll) {
    return Container(
      width: 130,
      height: 175,
      child: Card(
        semanticContainer: true,
        color: Colors.blueGrey.shade50,
        elevation: 4,
        child: StreamBuilder(
          stream: categoryBloc.getCategory1(),
          builder:
              (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasError && snapshot.hasData) {
              ///Buradaki listeyi oluşturma sebebi gelen veriyi Map<int,String>
              ///dönüştürme bu şekilde categorinin id tutmuş oluyoruz.
              List<Map<int, String>> _category1Name = [];

              for (var element in snapshot.data!) {
                _category1Name.add({element['category1_id']: element['name']});
              }

              return Scrollbar(
                controller: controllerScroll,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 15,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: true),
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: controllerScroll,
                    itemCount: _category1Name.length,
                    itemBuilder: (context, index) {
                      return Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black, width: 1))),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: ListTile(
                            visualDensity: const VisualDensity(
                                horizontal: 0, vertical: -4),
                            contentPadding: EdgeInsets.zero,
                            title:

                                ///Map i value değerini bir listeye dönüşüyor.
                                Text(
                                    _category1Name[index]
                                        .values
                                        .toString()
                                        .replaceAll(RegExp(r"[)(]"), ''),
                                    style: TextStyle(
                                      color: _listSelectIndex[0] == index
                                          ? Colors.white
                                          : null,
                                    )),
                            tileColor: _listSelectIndex[0] == index
                                ? Colors.blueGrey.shade600
                                : null,
                            onTap: () {
                              setState(() {
                                ///ilk başta listSelectIndex = null olduğunda girer.
                                /// Buradaki amaç aynı öğe liste seçildiğinde öndeki
                                ///  select lerin sıfırlanması gerek ki Delete işlemi
                                /// yapabilmemiz için.(delete _listSelectIndex yapılıyor.)
                                if (_listSelectIndex[0] != index) {
                                  _listSelectIndex[0] = index;
                                } else {
                                  _listSelectIndex[1] = null;
                                  _listSelectIndex[2] = null;
                                  _listSelectIndex[3] = null;
                                  _listSelectIndex[4] = null;

                                  ///kategori liste widget ekrandan siliyor.
                                  _category.category2 = null;
                                  _category.category3 = null;
                                  _category.category4 = null;
                                  _category.category5 = null;
                                }

                                _category.category1 = _category1Name[index];
                                if (_temp[0] !=
                                    _category.category1!.values.first) {
                                  _category.category2 = null;
                                  _listSelectIndex[1] =
                                      null; //seçili olmasını sıfırlıyor
                                  _category.category3 = null;
                                  _category.category4 = null;
                                }

                                ///ilk seçilen değer ile farklı anlamak için geçici
                                ///bir değişkene atılıyor
                                _temp[0] = _category.category1?.values.first;
                              });
                            },
                          ));
                    },
                  ),
                ),
              );
            } else {
              return Container(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                      color: Colors.blueGrey.shade700),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  widgetCategory2Show(ScrollController controllerScroll) {
    if (_category.category1 == null) {
      return Container();
    } else {
      return Container(
        width: 130,
        height: 175,
        child: Card(
          semanticContainer: true,
          color: Colors.blueGrey.shade50,
          elevation: 4,
          child: StreamBuilder(
            stream: categoryBloc.getCategory2(_category.category1),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasError && snapshot.hasData) {
                print("deneme");

                ///Buradaki listeyi oluşturma sebebi gelen veriyi Map<int,String>
                ///dönüştürme bu şekilde categorinin id tutmuş oluyoruz.
                List<Map<int, String>> category2Name = [];

                for (var element in snapshot.data!) {
                  category2Name.add({element['category2_id']: element['name']});
                }

                return Scrollbar(
                  controller: controllerScroll,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 15,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: true),
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: controllerScroll,
                      itemCount: category2Name.length,
                      itemBuilder: (context, index) {
                        return Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black, width: 1))),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListTile(
                              visualDensity: const VisualDensity(
                                  horizontal: 0, vertical: -4),
                              contentPadding: EdgeInsets.zero,
                              title:

                                  ///Map i value değerini bir listeye dönüşüyor.
                                  Text(
                                      category2Name[index]
                                          .values
                                          .toString()
                                          .replaceAll(RegExp(r"[)(]"), ''),
                                      style: TextStyle(
                                        color: _listSelectIndex[1] == index
                                            ? Colors.white
                                            : null,
                                      )),
                              tileColor: _listSelectIndex[1] == index
                                  ? Colors.blueGrey.shade600
                                  : null,
                              onTap: () {
                                setState(() {
                                  ///ilk başta listSelectIndex = null olduğunda girer.
                                  /// Buradaki amaç aynı öğe liste seçildiğinde öndeki select lerin sıfırlanması
                                  ///  gerek ki Delete işlemi yapabilmemiz için.(delete _listSelectIndex yapılıyor.)
                                  if (_listSelectIndex[1] != index) {
                                    _listSelectIndex[1] = index;
                                  } else {
                                    _listSelectIndex[2] = null;
                                    _listSelectIndex[3] = null;
                                    _listSelectIndex[4] = null;
                                    _category.category3 = null;
                                    _category.category4 = null;
                                    _category.category5 = null;
                                  }

                                  _category.category2 = category2Name[index];
                                  if (_temp[1] !=
                                      _category.category2!.values.first) {
                                    _category.category3 = null;
                                    _listSelectIndex[2] =
                                        null; //seçili olmasını sıfırlıyor
                                    _category.category4 = null;
                                    _category.category5 = null;
                                  }

                                  ///ilk seçilen değer ile farklı anlamak için geçici
                                  ///bir değişkene atılıyor
                                  _temp[1] = _category.category2?.values.first;
                                });
                              },
                            ));
                      },
                    ),
                  ),
                );
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                        color: Colors.blueGrey.shade700),
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }

  widgetCategory3Show(ScrollController controllerScroll) {
    if (_category.category2 == null) {
      return Container();
    } else {
      return Container(
        width: 120,
        height: 175,
        child: Card(
          semanticContainer: true,
          color: Colors.blueGrey.shade50,
          elevation: 4,
          child: StreamBuilder(
            stream: categoryBloc.getCategory3(_category.category2),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasError && snapshot.hasData) {
                ///Buradaki listeyi oluşturma sebebi gelen veriyi Map<int,String>
                ///dönüştürme bu şekilde categorinin id tutmuş oluyoruz.
                List<Map<int, String>> _category3Name = [];

                for (var element in snapshot.data!) {
                  _category3Name
                      .add({element['category3_id']: element['name']});
                }
                print(_category3Name);
                return Scrollbar(
                  controller: controllerScroll,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 15,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: true),
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: controllerScroll,
                      itemCount: _category3Name.length,
                      itemBuilder: (context, index) {
                        return Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black, width: 1))),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListTile(
                                visualDensity: const VisualDensity(
                                    horizontal: 0, vertical: -4),
                                contentPadding: EdgeInsets.zero,
                                title:

                                    ///Map i value değerini bir listeye dönüşüyor.
                                    Text(
                                  _category3Name[index].values.first,
                                  style: TextStyle(
                                    color: _listSelectIndex[2] == index
                                        ? Colors.white
                                        : null,
                                  ),
                                ),
                                tileColor: _listSelectIndex[2] == index
                                    ? Colors.blueGrey.shade600
                                    : null,
                                onTap: () {
                                  setState(() {
                                    ///ilk seçilen değer ile farklı anlamak için geçici
                                    ///bir değişkene atılıyor
                                    _temp[2] =
                                        _category.category3?.values.first;

                                    ///ilk başta listSelectIndex = null olduğunda girer.
                                    ///Buradaki amaç aynı öğe liste seçildiğinde öndeki
                                    ///select lerin sıfırlanması gerek ki Delete işlemi
                                    ///yapabilmemiz için.(delete _listSelectIndex yapılıyor.)
                                    if (_listSelectIndex[2] != index) {
                                      _listSelectIndex[2] = index;
                                    } else {
                                      _listSelectIndex[3] = null;
                                      _listSelectIndex[4] = null;
                                      _category.category4 = null;
                                      _category.category5 = null;
                                    }

                                    _category.category3 = _category3Name[index];
                                    if (_temp[2] !=
                                        _category.category3!.values.first) {
                                      _category.category4 = null;
                                      _listSelectIndex[3] =
                                          null; //seçili olmasını sıfırlıyor

                                      _category.category4 = null;
                                      _category.category5 = null;
                                    }

                                    ///ilk seçilen değer ile farklı anlamak için geçici
                                    ///bir değişkene atılıyor
                                    _temp[2] =
                                        _category.category3?.values.first;
                                  });
                                }));
                      },
                    ),
                  ),
                );
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                        color: Colors.blueGrey.shade700),
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }

  widgetCategory4Show(ScrollController controllerScroll) {
    if (_category.category3 == null) {
      return Container();
    } else {
      return Container(
        width: 120,
        height: 175,
        child: Card(
          semanticContainer: true,
          color: Colors.blueGrey.shade50,
          elevation: 4,
          child: StreamBuilder(
            stream: categoryBloc.getCategory4(_category.category3),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasError && snapshot.hasData) {
                ///Buradaki listeyi oluşturma sebebi gelen veriyi Map<int,String>
                ///dönüştürme bu şekilde categorinin id tutmuş oluyoruz.
                List<Map<int, String>> _category4Name = [];

                for (var element in snapshot.data!) {
                  _category4Name
                      .add({element['category4_id']: element['name']});
                }

                return Scrollbar(
                  controller: controllerScroll,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 15,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: true),
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: controllerScroll,
                      itemCount: _category4Name.length,
                      itemBuilder: (context, index) {
                        return Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black, width: 1))),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListTile(
                                visualDensity: const VisualDensity(
                                    horizontal: 0, vertical: -4),
                                contentPadding: EdgeInsets.zero,
                                title:

                                    ///Map i value değerini bir listeye dönüşüyor.
                                    Text(
                                  _category4Name[index].values.first,
                                  style: TextStyle(
                                    color: _listSelectIndex[3] == index
                                        ? Colors.white
                                        : null,
                                  ),
                                ),
                                tileColor: _listSelectIndex[3] == index
                                    ? Colors.blueGrey.shade600
                                    : null,
                                onTap: () {
                                  setState(() {
                                    ///ilk başta listSelectIndex = null olduğunda girer.
                                    ///Buradaki amaç aynı öğe liste seçildiğinde öndeki
                                    ///select lerin sıfırlanması gerek ki Delete işlemi
                                    ///yapabilmemiz için.(delete _listSelectIndex yapılıyor.)
                                    if (_listSelectIndex[3] != index) {
                                      _listSelectIndex[3] = index;
                                    } else {
                                      _listSelectIndex[4] = null;
                                    }

                                    _category.category4 = _category4Name[index];
                                    if (_temp[3] !=
                                        _category.category4!.values.first) {
                                      _listSelectIndex[4] =
                                          null; //seçili olmasını sıfırlıyor

                                      _category.category5 = null;
                                    }

                                    ///ilk seçilen değer ile farklı anlamak için geçici
                                    ///bir değişkene atılıyor
                                    _temp[3] =
                                        _category.category4?.values.first;
                                  });
                                }));
                      },
                    ),
                  ),
                );
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                        color: Colors.blueGrey.shade700),
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }

  widgetCategory5Show(ScrollController controllerScroll) {
    if (_category.category4 == null) {
      return Container();
    } else {
      return Container(
        width: 120,
        height: 175,
        child: Card(
          semanticContainer: true,
          color: Colors.blueGrey.shade50,
          elevation: 4,
          child: StreamBuilder(
            stream: categoryBloc.getCategory5(_category.category4),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasError && snapshot.hasData) {
                ///Buradaki listeyi oluşturma sebebi gelen veriyi Map<int,String>
                ///dönüştürme bu şekilde categorinin id tutmuş oluyoruz.
                List<Map<int, String>> _category5Name = [];

                for (var element in snapshot.data!) {
                  _category5Name
                      .add({element['category5_id']: element['name']});
                }

                return Scrollbar(
                  controller: controllerScroll,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 15,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: true),
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: controllerScroll,
                      itemCount: _category5Name.length,
                      itemBuilder: (context, index) {
                        return Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black, width: 1))),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListTile(
                              visualDensity: const VisualDensity(
                                  horizontal: 0, vertical: -4),
                              contentPadding: EdgeInsets.zero,
                              title:

                                  ///Map i value değerini bir listeye dönüşüyor.
                                  Text(
                                _category5Name[index].values.first,
                                style: TextStyle(
                                  color: _listSelectIndex[4] == index
                                      ? Colors.white
                                      : null,
                                ),
                              ),
                              tileColor: _listSelectIndex[4] == index
                                  ? Colors.blueGrey.shade600
                                  : null,
                              onTap: () {
                                setState(() {
                                  _listSelectIndex[4] = index;
                                });

                                _category.category5 = _category5Name[index];
                              },
                            ));
                      },
                    ),
                  ),
                );
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                        color: Colors.blueGrey.shade700),
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }

  widgetDeleteButton() {
    return shareWidget.widgetElevatedButton(
        onPressedDoSomething: () {
          int _selectedCategory = 0;
          for (var i = 0; i < _listSelectIndex.length; i++) {
            if (_listSelectIndex[i] != null) {
              _selectedCategory++;
            }
          }
          setState(() {
            dbCategory.deleteSelectedCategory(_category, _selectedCategory);
          });
        },
        label: 'Sil');
  }
}
