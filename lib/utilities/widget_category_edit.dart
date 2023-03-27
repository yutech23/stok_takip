// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/bloc/bloc_categorty.dart';
import 'package:stok_takip/data/database_fetch_category.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_widgets.dart';
import '../validations/format_upper_case_capital_text_format.dart';
import '../validations/validation.dart';

// ignore: must_be_immutable
class WidgetCategoryEdit extends StatefulWidget {
  BlocCategory blocCategory;

  WidgetCategoryEdit(this.blocCategory, {super.key});

  @override
  State<WidgetCategoryEdit> createState() => _WidgetCategoryEditState();
}

class _WidgetCategoryEditState extends State<WidgetCategoryEdit>
    with Validation {
  ///Oluşturlan Listelerin Scroll Kontrolu için oluşturuldu.
  late final List<ScrollController> _controllerScrollList = [];

  ///Kategori uzunluğu belirlemek için döngülerde uzunluk vermek için daha
  ///kolay oldu.

  final GlobalKey<FormState> _globalFormKey = GlobalKey<FormState>();
  final ValueNotifier<int> _categoryAddIndex = ValueNotifier<int>(0);

  final TextEditingController _newValueCategoryController =
      TextEditingController();
  final String _labelUpdateButton = "Degiştir";

  bool _disableButtonValue = true;

  final double _scrollbarThickness = 10;
  final double _categoryBoxWidth = 150;
  final double _categoryBoxHeight = 175;

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
          widgetCategoryUpdate(),
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
        ],
      );
    }
  }

  //  #region Kategori girişi için TextFormField ayarları.

  ///Kategorileri girmek için TextFieldInput wrap içine dolduruluyor.
  widgetCategoryUpdate() {
    return ValueListenableBuilder<int>(
        valueListenable: _categoryAddIndex,
        builder: (context, value, child) {
          //kayıt Buttonunu enable yapıyo
          if (value != 0) {
            _disableButtonValue = false;
          }

          return SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                spacing: 10,
                runSpacing: 10,
                children: [
                  widgetTextFieldNewCategoryValue(),
                  widgetUpdateOnButtonByCategory(),
                ],
              ));
        });
  }

  ///Kategori inputlarını liste olarak oluşturuyor.
  widgetTextFieldNewCategoryValue() {
    return SizedBox(
        width: 200,
        height: 40,
        child: TextFormField(
          controller: _newValueCategoryController,
          decoration: const InputDecoration(
              labelStyle: TextStyle(
                fontSize: 14,
              ),
              labelText: "Kategori ismi",
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber))),
          inputFormatters: [FormatterUpperCaseCapitalEachWordTextFormatter()],
          //validationFunc: validateNotEmpty,
          enabled: widget.blocCategory.enableCategoryTextFormField,
        ));
  }

  widgetUpdateOnButtonByCategory() {
    return SizedBox(
      width: 200,
      height: 40,
      child: ElevatedButton(
          onPressed: widget.blocCategory.enableCategoryTextFormField
              ? () async {
                  if (_newValueCategoryController.text.isNotEmpty) {
                    String res = await widget.blocCategory
                        .updateNewCategoryValue(
                            _newValueCategoryController.text);
                    if (res.isEmpty) {
                      // ignore: use_build_context_synchronously
                      context.noticeBarTrue("İşlem başarılı.", 2);
                    } else {
                      // ignore: use_build_context_synchronously
                      context.noticeBarError(res, 3);
                    }
                  } else {
                    context.noticeBarError("Yeni kategori ismi girmediniz", 3);
                  }
                }
              : null,
          child: Text(
            _labelUpdateButton,
            style: context.theme.titleMedium!.copyWith(color: Colors.white),
          )),
    );
  }
}
