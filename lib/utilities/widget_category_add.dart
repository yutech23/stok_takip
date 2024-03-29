// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/bloc/bloc_categorty.dart';
import 'package:stok_takip/data/database_fetch_category.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import '../data/database_save_new_category.dart';
import '../models/category.dart';
import '../validations/format_upper_case_capital_text_format.dart';
import '../validations/validation.dart';

// ignore: must_be_immutable
class WidgetCategoryAdd extends StatefulWidget {
  BlocCategory blocCategory;

  WidgetCategoryAdd(this.blocCategory, {super.key});

  @override
  State<WidgetCategoryAdd> createState() => _WidgetCategoryAddState();
}

class _WidgetCategoryAddState extends State<WidgetCategoryAdd> with Validation {
  ///Oluşturlan Listelerin Scroll Kontrolu için oluşturuldu.
  late final List<ScrollController> _controllerScrollList = [];

  ///Kategori uzunluğu belirlemek için döngülerde uzunluk vermek için daha
  ///kolay oldu.
  final int _lengthCategory = 5;

  final GlobalKey<FormState> _globalFormKey = GlobalKey<FormState>();

  final ValueNotifier<int> _categoryAddIndex = ValueNotifier<int>(0);

  final List<TextEditingController> _controllerCategories = [];
  final List<Widget> _listCategoryCreate = [];
  List<bool> _enableCategoryTextFormField = [];

  bool _disableButtonValue = true;

  final CategoryString _newCategoryAdd = CategoryString();
  final double _scrollbarThickness = 10;
  final double _categoryBoxWidth = 150;
  final double _categoryBoxHeight = 175;
  final Size _buttonAddCategoryMinSize = const Size(150, 40);

  final List<int> _lenghtCategorylistUpdate = [];
  final String _labelMainCategory1 = "Kategori-1 Ekle";
  final String _labelSubCategory2 = "Alt Kategori-2 Ekle";
  final String _labelSubCategory3 = "Alt Kategori-3 Ekle";
  final String _labelSubCategory4 = "Alt Kategori-4 Ekle";
  final String _labelSubCategory5 = "Alt Kategori-5 Ekle";

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
    super.dispose();
    /*  widget.blocCategory.listSelectIndex.clear();
    _controllerScrollList.clear();
    _controllerCategories.clear();
   

    _categoryAddIndex.dispose();
    _controllerCategories.clear();
    _listCategoryCreate.clear();
    _enableCategoryTextFormField.clear();
    _lenghtCategorylistUpdate.clear(); */
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Container(
      constraints: const BoxConstraints(minWidth: 360, maxWidth: 800),
      alignment: Alignment.topLeft,
      // decoration: context.extensionThemaGreyContainer(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
              alignment: WrapAlignment.start,
              direction: Axis.horizontal,
              spacing: 10,
              runSpacing: 10,
              children: [
                widgetCategory1Show(_controllerScrollList[0]),
                widgetCategory2Show(_controllerScrollList[1]),
                widgetCategory3Show(_controllerScrollList[2]),
                widgetCategory4Show(_controllerScrollList[3]),
                widgetCategory5Show(_controllerScrollList[4]),
              ]),
          Divider(
              height: 50, color: context.extensionDefaultColor, thickness: 3),
          widgetCategoryAdd(),
        ],
      ),
    ));
  }

  widgetCategory1Show(ScrollController controllerScroll) {
    return Column(
      children: [
        SizedBox(
          width: _categoryBoxWidth,
          height: _categoryBoxHeight,
          child: Card(
            semanticContainer: true,
            color: Colors.blueGrey.shade50,
            elevation: 4,
            child: StreamBuilder(
              stream: categoryBloc.getCategory1(),
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasError && snapshot.hasData) {
                  ///Burada veri tabanında okunan category1 tüm veri
                  ///{id:isim} şeklinde yeni bir map liste aktarılıyor.
                  List<Map<int, String>> category1Name = [];

                  for (var element in snapshot.data!) {
                    category1Name
                        .add({element['category1_id']: element['name']});
                  }

                  return Scrollbar(
                    controller: controllerScroll,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thickness: _scrollbarThickness,
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ListTile(
                                dense: true,
                                visualDensity: const VisualDensity(
                                    horizontal: 0, vertical: -4),
                                contentPadding: EdgeInsets.zero,
                                title: Text(category1Name[index].values.first,

                                    ///Categori içindeki gelen item ları eğer seçerseniz yazıyı beyaz yapıyor. seçmezseniz siyah. bunu listSelectIndex ile yapılıyor üzerine tıklandı onTap ile index atanıyor.
                                    style: TextStyle(
                                      color: widget.blocCategory
                                                  .listSelectIndex[0] ==
                                              index
                                          ? Colors.white
                                          : null,
                                    )),
                                tileColor:
                                    widget.blocCategory.listSelectIndex[0] ==
                                            index
                                        ? Colors.blueGrey.shade600
                                        : null,
                                onTap: () {
                                  setState(() {
                                    widget.blocCategory.selectCategory1(
                                        category1Name[index], index);
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
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              widget.blocCategory.category.category1 = null;
              widget.blocCategory.category.category2 = null;
              widget.blocCategory.category.category3 = null;
              widget.blocCategory.category.category4 = null;
              widget.blocCategory.listSelectIndex[1] = null;
              widget.blocCategory.listSelectIndex[2] = null;
              widget.blocCategory.listSelectIndex[3] = null;
              widget.blocCategory.listSelectIndex[4] = null;
            });
            _categoryAddIndex.value = 1;

            for (var i = 0; i < _lengthCategory; i++) {
              if (_controllerCategories[i].text.isNotEmpty) {
                _controllerCategories[i].text = "";
              }
            }
          },
          style:
              ElevatedButton.styleFrom(minimumSize: _buttonAddCategoryMinSize),
          child: Text(
            textAlign: TextAlign.center,
            _labelMainCategory1,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.white),
          ),
        )
      ],
    );
  }

  widgetCategory2Show(ScrollController controllerScroll) {
    if (widget.blocCategory.category.category1 == null) {
      return Container();
    } else {
      return Column(
        children: [
          SizedBox(
            width: _categoryBoxWidth,
            height: _categoryBoxHeight,
            child: Card(
              semanticContainer: true,
              color: Colors.blueGrey.shade50,
              elevation: 4,
              child: StreamBuilder(
                stream: categoryBloc
                    .getCategory2(widget.blocCategory.category.category1),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (!snapshot.hasError && snapshot.hasData) {
                    List<Map<int, String>> category2Name = [];
                    for (var element in snapshot.data!) {
                      if (element['name'].isNotEmpty) {
                        category2Name
                            .add({element['category2_id']: element['name']});
                      }
                    }
                    return Scrollbar(
                      controller: controllerScroll,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: _scrollbarThickness,
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: ListTile(
                                  dense: true,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  contentPadding: EdgeInsets.zero,
                                  title:

                                      ///Map i value değerini bir listeye dönüşüyor.
                                      Text(category2Name[index].values.first,
                                          style: TextStyle(
                                            color: widget.blocCategory
                                                        .listSelectIndex[1] ==
                                                    index
                                                ? Colors.white
                                                : null,
                                          )),
                                  tileColor:
                                      widget.blocCategory.listSelectIndex[1] ==
                                              index
                                          ? Colors.blueGrey.shade600
                                          : null,
                                  onTap: () {
                                    setState(() {
                                      widget.blocCategory.selectCategory2(
                                          category2Name[index], index);
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
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.blocCategory.category.category2 = null;
                widget.blocCategory.category.category3 = null;
                widget.blocCategory.category.category4 = null;
                widget.blocCategory.listSelectIndex[2] = null;
                widget.blocCategory.listSelectIndex[3] = null;
                widget.blocCategory.listSelectIndex[4] = null;

                _categoryAddIndex.value = 2;
                _controllerCategories[0].text =
                    widget.blocCategory.category.category1!.values.first;
                if (_controllerCategories[1].text.isNotEmpty) {
                  _controllerCategories[1].text = "";
                  _controllerCategories[2].text = "";
                  _controllerCategories[3].text = "";
                }
              });
            },
            style: ElevatedButton.styleFrom(
                minimumSize: _buttonAddCategoryMinSize),
            child: Text(
              textAlign: TextAlign.center,
              _labelSubCategory2,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white),
            ),
          )
        ],
      );
    }
  }

  widgetCategory3Show(ScrollController controllerScroll) {
    if (widget.blocCategory.category.category2 == null) {
      return Container();
    } else {
      return Column(
        children: [
          SizedBox(
            width: _categoryBoxWidth,
            height: _categoryBoxHeight,
            child: Card(
              semanticContainer: true,
              color: Colors.blueGrey.shade50,
              elevation: 4,
              child: StreamBuilder(
                stream: categoryBloc
                    .getCategory3(widget.blocCategory.category.category2),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (!snapshot.hasError && snapshot.hasData) {
                    List<Map<int, String>> category3Name = [];
                    for (var element in snapshot.data!) {
                      category3Name
                          .add({element['category3_id']: element['name']});
                    }

                    return Scrollbar(
                      controller: controllerScroll,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: _scrollbarThickness,
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: ListTile(
                                  dense: true,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  contentPadding: EdgeInsets.zero,
                                  title:

                                      ///Map i value değerini bir listeye dönüşüyor.

                                      Text(category3Name[index].values.first,
                                          style: TextStyle(
                                            color: widget.blocCategory
                                                        .listSelectIndex[2] ==
                                                    index
                                                ? Colors.white
                                                : null,
                                          )),
                                  tileColor:
                                      widget.blocCategory.listSelectIndex[2] ==
                                              index
                                          ? Colors.blueGrey.shade600
                                          : null,
                                  onTap: () {
                                    setState(() {
                                      widget.blocCategory.selectCategory3(
                                          category3Name[index], index);
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
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.blocCategory.category.category3 = null;
                widget.blocCategory.category.category4 = null;
                widget.blocCategory.listSelectIndex[3] = null;
                widget.blocCategory.listSelectIndex[4] = null;
              });

              _categoryAddIndex.value = 3;
              _controllerCategories[0].text =
                  widget.blocCategory.category.category1!.values.first;
              _controllerCategories[1].text =
                  widget.blocCategory.category.category2!.values.first;

              if (_controllerCategories[2].text.isNotEmpty) {
                _controllerCategories[2].text = "";
                _controllerCategories[3].text = "";
              }
            },
            style: ElevatedButton.styleFrom(
                minimumSize: _buttonAddCategoryMinSize),
            child: Text(
              textAlign: TextAlign.center,
              _labelSubCategory3,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.white),
            ),
          )
        ],
      );
    }
  }

  widgetCategory4Show(ScrollController controllerScroll) {
    if (widget.blocCategory.category.category3 == null) {
      return Container();
    } else {
      return Column(
        children: [
          SizedBox(
            width: _categoryBoxWidth,
            height: _categoryBoxHeight,
            child: Card(
              semanticContainer: true,
              color: Colors.blueGrey.shade50,
              elevation: 4,
              child: StreamBuilder(
                stream: categoryBloc
                    .getCategory4(widget.blocCategory.category.category3),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (!snapshot.hasError && snapshot.hasData) {
                    ///Buradaki listeyi oluşturma sebebi gelen veriyi Map<int,String>
                    ///dönüştürme bu şekilde categorinin id tutmuş oluyoruz.
                    List<Map<int, String>> category4Name = [];

                    for (var element in snapshot.data!) {
                      category4Name
                          .add({element['category4_id']: element['name']});
                    }
                    return Scrollbar(
                      controller: controllerScroll,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: _scrollbarThickness,
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: ListTile(
                                  dense: true,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  contentPadding: EdgeInsets.zero,
                                  title:

                                      ///Map i value değerini bir listeye dönüşüyor.

                                      Text(category4Name[index].values.first,
                                          style: TextStyle(
                                            color: widget.blocCategory
                                                        .listSelectIndex[3] ==
                                                    index
                                                ? Colors.white
                                                : null,
                                          )),
                                  tileColor:
                                      widget.blocCategory.listSelectIndex[3] ==
                                              index
                                          ? Colors.blueGrey.shade600
                                          : null,
                                  onTap: () {
                                    setState(() {
                                      widget.blocCategory.selectCategory4(
                                          category4Name[index], index);
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
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.blocCategory.category.category4 = null;
                widget.blocCategory.listSelectIndex[4] = null;
              });

              _categoryAddIndex.value = 4;
              _controllerCategories[0].text =
                  widget.blocCategory.category.category1!.values.first;
              _controllerCategories[1].text =
                  widget.blocCategory.category.category2!.values.first;
              _controllerCategories[2].text =
                  widget.blocCategory.category.category3!.values.first;

              if (_controllerCategories[3].text.isNotEmpty) {
                _controllerCategories[3].text = "";
              }
            },
            style: ElevatedButton.styleFrom(
                minimumSize: _buttonAddCategoryMinSize),
            child: Text(
              textAlign: TextAlign.center,
              _labelSubCategory4,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.white),
            ),
          )
        ],
      );
    }
  }

  widgetCategory5Show(ScrollController controllerScroll) {
    if (widget.blocCategory.category.category4 == null) {
      return Container();
    } else {
      return Column(
        children: [
          SizedBox(
            width: _categoryBoxWidth,
            height: _categoryBoxHeight,
            child: Card(
              semanticContainer: true,
              color: Colors.blueGrey.shade50,
              elevation: 4,
              child: StreamBuilder(
                stream: categoryBloc
                    .getCategory5(widget.blocCategory.category.category4),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (!snapshot.hasError && snapshot.hasData) {
                    ///Buradaki listeyi oluşturma sebebi gelen veriyi Map<int,String>
                    ///dönüştürme bu şekilde categorinin id tutmuş oluyoruz.
                    List<Map<int, String>> category5Name = [];

                    for (var element in snapshot.data!) {
                      category5Name
                          .add({element['category5_id']: element['name']});
                    }
                    return Scrollbar(
                      controller: controllerScroll,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: _scrollbarThickness,
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: ListTile(
                                  dense: true,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  contentPadding: EdgeInsets.zero,
                                  title:

                                      ///Map i value değerini bir listeye dönüşüyor.
                                      Text(category5Name[index].values.first,
                                          style: TextStyle(
                                            color: widget.blocCategory
                                                        .listSelectIndex[4] ==
                                                    index
                                                ? Colors.white
                                                : null,
                                          )),
                                  tileColor:
                                      widget.blocCategory.listSelectIndex[4] ==
                                              index
                                          ? Colors.blueGrey.shade600
                                          : null,
                                  onTap: () {
                                    setState(() {
                                      widget.blocCategory.selectCategory5(
                                          category5Name[index], index);
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
          ),
          ElevatedButton(
            onPressed: () {
              _categoryAddIndex.value = 5;
              _controllerCategories[0].text =
                  widget.blocCategory.category.category1!.values.first;
              _controllerCategories[1].text =
                  widget.blocCategory.category.category2!.values.first;
              _controllerCategories[2].text =
                  widget.blocCategory.category.category3!.values.first;
              _controllerCategories[3].text =
                  widget.blocCategory.category.category4!.values.first;
            },
            style: ElevatedButton.styleFrom(
                minimumSize: _buttonAddCategoryMinSize),
            child: Text(
              textAlign: TextAlign.center,
              _labelSubCategory5,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.white),
            ),
          )
        ],
      );
    }
  }

  //  #region Kategori girişi için TextFormField ayarları.

  ///Kategorileri girmek için TextFieldInput wrap içine dolduruluyor.
  widgetCategoryAdd() {
    return Form(
      key: _globalFormKey,
      child: ValueListenableBuilder<int>(
          valueListenable: _categoryAddIndex,
          builder: (context, value, child) {
            //kayıt Buttonunu enable yapıyo
            if (value != 0) {
              _disableButtonValue = false;
            }
            if (value == 1) {
              _disableButtonValue = false; //Buttonu enable yapıyor
              listFuncCategoryCreate(enableValueStart: value);

              return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var textFieldItem in _listCategoryCreate)
                        textFieldItem,
                    ],
                  ));
            } else if (value == 2) {
              listFuncCategoryCreate(enableValueStart: value);

              return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var textFieldItem in _listCategoryCreate)
                        textFieldItem,
                    ],
                  ));
            } else if (value == 3) {
              listFuncCategoryCreate(enableValueStart: value);
              return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var textFieldItem in _listCategoryCreate)
                        textFieldItem,
                    ],
                  ));
            } else if (value == 4) {
              listFuncCategoryCreate(enableValueStart: value);
              return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var textFieldItem in _listCategoryCreate)
                        textFieldItem,
                    ],
                  ));
            } else if (value == 5) {
              listFuncCategoryCreate(enableValueStart: value);
              return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var textFieldItem in _listCategoryCreate)
                        textFieldItem,
                    ],
                  ));
            } else {
              listFuncCategoryCreate(enableValueStart: 0);
              return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var textFieldItem in _listCategoryCreate)
                        textFieldItem,
                    ],
                  ));
            }
          }),
    );
  }

  ///Kategori inputlarını liste olarak oluşturuyor.
  listFuncCategoryCreate({required int enableValueStart}) {
    _enableCategoryTextFormField = List<bool>.filled(5, false);
    if (enableValueStart != 0) {
      for (var i = enableValueStart - 1; i < 5; i++) {
        _enableCategoryTextFormField[i] = true;
      }
    }

    ///Kategori ekleme bölümünü seçer iken liste tekrarlanmamsı için sıfırlama
    ///gerekiyor.
    _listCategoryCreate.clear();
    int categoryNo = 1;
    for (var i = 0; i < 5; i++) {
      _controllerCategories.add(TextEditingController());
      _listCategoryCreate.add(SizedBox(
          width: 200,
          child: widgetTextFieldByCategory(
              controller: _controllerCategories[i],
              etiket: "Kategori-$categoryNo Elemanını Giriniz",
              inputFormat: [FormatterUpperCaseCapitalEachWordTextFormatter()],
              //validationFunc: validateNotEmpty,
              enable: _enableCategoryTextFormField[i])));

      if (i != 4) {
        _listCategoryCreate.add(Icon(
          Icons.arrow_forward_sharp,
          color: Colors.blueGrey.shade900,
          size: 40,
        ));
      }

      ///ok işareti olmadığı simetrik olsun diye yapıldı.
      if (i == 4) {
        _listCategoryCreate.add(const SizedBox(
          width: 40,
        ));
      }
      categoryNo++;
    }
    _listCategoryCreate.add(const Divider());
    _listCategoryCreate.add(widgetSaveOnButtonByCategory());
  }

  ///kategori input  TextField özellikleri burada.
  widgetTextFieldByCategory({
    TextEditingController? controller,
    String? Function(String?)? validationFunc,
    String? etiket,
    List<TextInputFormatter>? inputFormat,
    required bool enable,
  }) {
    return TextFormField(
      enabled: enable,
      controller: controller,
      validator: validationFunc,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
          labelStyle: const TextStyle(
            fontSize: 14,
          ),
          labelText: etiket,
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber))),
      inputFormatters: inputFormat,
    );
  }

// #endregion
  ElevatedButton widgetSaveOnButtonByCategory() {
    return ElevatedButton(
        onPressed: _disableButtonValue
            ? null
            : () {
                if (_categoryAddIndex.value != 0) {
                  //  _globalFormKey.currentState!.validate();
                }

                ///textfiled girilen kategori adlarını burada Oluşturlan
                ///CategoryString nesnesinin içine atılıyor.Bunuda database gönderiliyor.
                _newCategoryAdd.category1 = _controllerCategories[0].text;
                _newCategoryAdd.category2 = _controllerCategories[1].text;
                _newCategoryAdd.category3 = _controllerCategories[2].text;
                _newCategoryAdd.category4 = _controllerCategories[3].text;
                _newCategoryAdd.category5 = _controllerCategories[4].text;

                if (_categoryAddIndex.value == 1) {
                  dbCategory
                      .saveNewCategory(
                    context,
                    _globalFormKey,
                    _newCategoryAdd,
                  )
                      .then((value) {
                    if (value) {
                      ///Kayıt Başarı olduktan sonra input girişleri sıfırlıyor. Kullanıcı
                      /// peş peşe daha rahat girsin diye tüm inputları sıfırlanmıyor.
                      /// son input boşaltılması aynı veri kaydedilmemesi için.
                      for (var i = 0; i < _lengthCategory; i++) {
                        _controllerCategories[i].text = "";
                      }
                    }
                    setState(() {
                      _lenghtCategorylistUpdate;
                    });
                  });
                } else if (_categoryAddIndex.value == 2) {
                  dbCategory
                      .saveOnSubCategory2(
                          context: context,
                          categoryMap: widget.blocCategory.category,
                          categoryString: _newCategoryAdd,
                          categoryIndex: _categoryAddIndex)
                      .then((value) {
                    if (value) {
                      setState(() {
                        _lenghtCategorylistUpdate;
                      });
                      _controllerCategories[1].text = "";
                      _controllerCategories[2].text = "";
                      _controllerCategories[3].text = "";
                      _controllerCategories[4].text = "";
                    }
                  });
                } else if (_categoryAddIndex.value == 3) {
                  dbCategory
                      .saveOnSubCategory3(
                          context: context,
                          categoryMap: widget.blocCategory.category,
                          categoryString: _newCategoryAdd,
                          categoryIndex: _categoryAddIndex)
                      .then((value) {
                    if (value) {
                      setState(() {
                        _lenghtCategorylistUpdate;
                      });
                      _controllerCategories[2].text = "";
                      _controllerCategories[3].text = "";
                      _controllerCategories[4].text = "";
                    }
                  });
                } else if (_categoryAddIndex.value == 4) {
                  dbCategory
                      .saveOnSubCategory4(
                          context: context,
                          categoryMap: widget.blocCategory.category,
                          categoryString: _newCategoryAdd,
                          categoryIndex: _categoryAddIndex)
                      .then((value) {
                    if (value) {
                      setState(() {
                        _lenghtCategorylistUpdate;
                      });
                      _controllerCategories[3].text = "";
                      _controllerCategories[4].text = "";
                    }
                  });
                } else if (_categoryAddIndex.value == 5) {
                  dbCategory
                      .saveOnSubCategory5(
                          context: context,
                          categoryMap: widget.blocCategory.category,
                          categoryString: _newCategoryAdd,
                          categoryIndex: _categoryAddIndex)
                      .then((value) {
                    if (value) {
                      _controllerCategories[4].text = "";
                      setState(() {
                        _lenghtCategorylistUpdate;
                      });
                    }
                  });
                }
              },
        child: const Text("Kategoriyi Kaydet"));
  }
}
