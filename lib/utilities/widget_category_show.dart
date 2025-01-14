import 'package:flutter/material.dart';
import '../data/database_fetch_category.dart';
import '../models/category.dart';

class WidgetCategoryShow extends StatefulWidget {
  Category _category = Category();
  WidgetCategoryShow(this._category, {super.key});

  ///Category Bilgilerini almak için nesne buradan oluşturuyoruz. parametre geçerek
  /// verileri alıyoruz.

  @override
  State<WidgetCategoryShow> createState() => _WidgetCategoryShowState();
}

class _WidgetCategoryShowState extends State<WidgetCategoryShow> {
  ///Oluşturlan Listelerin Scroll Kontrolu için oluşturuldu.
  late final List<ScrollController> _controllerScrollList = [];

  ///Kategori Fonksiyonu parametre veri almak için Class oluşturulması gerekti
  ///veriler bu sınıfta tutuluyor.
  // late Category category;

  ///listelerin içindeki seçilen satırı index atıyoruz. Bu sayede o satırdaki
  ///veriyi alıyoruz. Background color değiştirmek içinde kullanılıyor.
  ///her liste için ayrı index oluşturlmalı yoksa karışıyor.
  final _listSelectIndex = List<int?>.filled(5, null);

  ///ilk kategori verisi seçildiğinde sonra değiştirildiğinde Listelerin güncellenmesi
  ///için burada temp data tuluyor bu sayede category.category1 vb. veri değişimi
  ///izleniyor. 5 kategori olduğu için 5 boyutlu liste oluşturuluyor.
  final _temp = List<String?>.filled(5, null);

  @override
  void initState() {
    super.initState();

    // 5 adet ScrollController Olacağından Burada hepsi oluşturuluyor.
    for (var i = 0; i < 5; i++) {
      _controllerScrollList.add(ScrollController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints:
            const BoxConstraints(minWidth: 120, maxWidth: 550, minHeight: 550),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
          ],
        ),
      ),
    );
  }

  widgetCategory1Show(ScrollController controllerScroll) {
    return SizedBox(
      width: 120,
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
              List<Map<int, String>> category1Name = [];

              for (var element in snapshot.data!) {
                category1Name.add({element['category1_id']: element['name']});
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
                    itemCount: category1Name.length,
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
                                    category1Name[index]
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
                                  widget._category.category2 = null;
                                  widget._category.category3 = null;
                                  widget._category.category4 = null;
                                  widget._category.category5 = null;
                                }

                                widget._category.category1 =
                                    category1Name[index];
                                if (_temp[0] !=
                                    widget._category.category1!.values.first) {
                                  widget._category.category2 = null;
                                  _listSelectIndex[1] =
                                      null; //seçili olmasını sıfırlıyor
                                  widget._category.category3 = null;
                                  widget._category.category4 = null;
                                }

                                ///ilk seçilen değer ile farklı anlamak için geçici
                                ///bir değişkene atılıyor
                                _temp[0] =
                                    widget._category.category1?.values.first;
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
    if (widget._category.category1 == null) {
      return Container();
    } else {
      return SizedBox(
        width: 120,
        height: 175,
        child: Card(
          semanticContainer: true,
          color: Colors.blueGrey.shade50,
          elevation: 4,
          child: StreamBuilder(
            stream: categoryBloc.getCategory2(widget._category.category1),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasError && snapshot.hasData) {
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
                                    widget._category.category3 = null;
                                    widget._category.category4 = null;
                                    widget._category.category5 = null;
                                  }

                                  widget._category.category2 =
                                      category2Name[index];
                                  if (_temp[1] !=
                                      widget
                                          ._category.category2!.values.first) {
                                    widget._category.category3 = null;
                                    _listSelectIndex[2] =
                                        null; //seçili olmasını sıfırlıyor
                                    widget._category.category4 = null;
                                    widget._category.category5 = null;
                                  }

                                  ///ilk seçilen değer ile farklı anlamak için geçici
                                  ///bir değişkene atılıyor
                                  _temp[1] =
                                      widget._category.category2?.values.first;
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
    if (widget._category.category2 == null) {
      return Container();
    } else {
      return SizedBox(
        width: 120,
        height: 175,
        child: Card(
          semanticContainer: true,
          color: Colors.blueGrey.shade50,
          elevation: 4,
          child: StreamBuilder(
            stream: categoryBloc.getCategory3(widget._category.category2),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasError && snapshot.hasData) {
                ///Buradaki listeyi oluşturma sebebi gelen veriyi Map<int,String>
                ///dönüştürme bu şekilde categorinin id tutmuş oluyoruz.
                List<Map<int, String>> category3Name = [];

                for (var element in snapshot.data!) {
                  category3Name.add({element['category3_id']: element['name']});
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
                      itemCount: category3Name.length,
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
                                  category3Name[index].values.first,
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
                                    _temp[2] = widget
                                        ._category.category3?.values.first;

                                    ///ilk başta listSelectIndex = null olduğunda girer.
                                    ///Buradaki amaç aynı öğe liste seçildiğinde öndeki
                                    ///select lerin sıfırlanması gerek ki Delete işlemi
                                    ///yapabilmemiz için.(delete _listSelectIndex yapılıyor.)
                                    if (_listSelectIndex[2] != index) {
                                      _listSelectIndex[2] = index;
                                    } else {
                                      _listSelectIndex[3] = null;
                                      _listSelectIndex[4] = null;
                                      widget._category.category4 = null;
                                      widget._category.category5 = null;
                                    }

                                    widget._category.category3 =
                                        category3Name[index];
                                    if (_temp[2] !=
                                        widget._category.category3!.values
                                            .first) {
                                      widget._category.category4 = null;
                                      _listSelectIndex[3] =
                                          null; //seçili olmasını sıfırlıyor

                                      widget._category.category4 = null;
                                      widget._category.category5 = null;
                                    }

                                    ///ilk seçilen değer ile farklı anlamak için geçici
                                    ///bir değişkene atılıyor
                                    _temp[2] = widget
                                        ._category.category3?.values.first;
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
    if (widget._category.category3 == null) {
      return Container();
    } else {
      return SizedBox(
        width: 120,
        height: 175,
        child: Card(
          semanticContainer: true,
          color: Colors.blueGrey.shade50,
          elevation: 4,
          child: StreamBuilder(
            stream: categoryBloc.getCategory4(widget._category.category3),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasError && snapshot.hasData) {
                ///Buradaki listeyi oluşturma sebebi gelen veriyi Map<int,String>
                ///dönüştürme bu şekilde categorinin id tutmuş oluyoruz.
                List<Map<int, String>> category4Name = [];

                for (var element in snapshot.data!) {
                  category4Name.add({element['category4_id']: element['name']});
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
                      itemCount: category4Name.length,
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
                                  category4Name[index].values.first,
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

                                    widget._category.category4 =
                                        category4Name[index];
                                    if (_temp[3] !=
                                        widget._category.category4!.values
                                            .first) {
                                      _listSelectIndex[4] =
                                          null; //seçili olmasını sıfırlıyor

                                      widget._category.category5 = null;
                                    }

                                    ///ilk seçilen değer ile farklı anlamak için geçici
                                    ///bir değişkene atılıyor
                                    _temp[3] = widget
                                        ._category.category4?.values.first;
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
    if (widget._category.category4 == null) {
      return Container();
    } else {
      return SizedBox(
        width: 120,
        height: 175,
        child: Card(
          semanticContainer: true,
          color: Colors.blueGrey.shade50,
          elevation: 4,
          child: StreamBuilder(
            stream: categoryBloc.getCategory5(widget._category.category4),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasError && snapshot.hasData) {
                ///Buradaki listeyi oluşturma sebebi gelen veriyi Map<int,String>
                ///dönüştürme bu şekilde categorinin id tutmuş oluyoruz.
                List<Map<int, String>> category5Name = [];

                for (var element in snapshot.data!) {
                  category5Name.add({element['category5_id']: element['name']});
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
                      itemCount: category5Name.length,
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
                                category5Name[index].values.first,
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

                                widget._category.category5 =
                                    category5Name[index];
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
}
