import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

///Widget - Basic Dropdown Menü String List ile doluyor Future List ile değil.

// ignore: must_be_immutable
class ShareDropdownFiltre extends StatelessWidget {
  final ValueChanged<int>? getShareDropdownCallbackFunc;
  String hint;
  List<Map<int, String>> itemList;
  String? Function(int?)? validator;
  int? selectValue;
  bool disable;

  ShareDropdownFiltre(
      {super.key,
      required this.hint,
      required this.itemList,
      this.validator,
      required this.selectValue,
      this.getShareDropdownCallbackFunc,
      this.disable = false});

  @override
  Widget build(BuildContext context) {
    ///Dropdown Listesini Dolduruyor.
    List<DropdownMenuItem<int>> dropdownMenuitemList = [];

    ///Dropdown gösterilen liste elemanları ayarlanıyor.
    for (var item in itemList) {
      dropdownMenuitemList.add(DropdownMenuItem(
          value: item.keys.first,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(item.values.first),
          )));
    }
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        enabled: false,
        fillColor: disable ? Colors.grey : null,
        isDense: false,
        contentPadding: const EdgeInsets.only(right: 5, bottom: 15),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(15)),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
      ),
      // ignore: prefer_const_constructors
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
      hint: Container(
        height: 50,
        alignment: Alignment.center,
        child: Text(hint,
            style: context.theme.bodyMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
      ),

      icon: const Icon(
        Icons.arrow_drop_down_circle_sharp,
        color: Colors.white,
        size: 30,
      ),
      isExpanded: true,
      isDense: true,
      itemHeight: 50,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),

      dropdownColor: Colors.blueGrey.shade200,
      items: dropdownMenuitemList,
      value: selectValue,
      onChanged: disable
          ? null
          : (value) {
              selectValue = value;
              getShareDropdownCallbackFunc!(selectValue!);
            },
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
