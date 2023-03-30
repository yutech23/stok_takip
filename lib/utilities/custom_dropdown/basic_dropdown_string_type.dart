import 'dart:js';

import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

///Widget - Basic Dropdown Menü String List ile doluyor Future List ile değil.

// ignore: must_be_immutable
class BasicDropdown extends StatelessWidget {
  final ValueChanged<String>? getShareDropdownCallbackFunc;
  String hint;
  List<String> itemList;
  String? Function(String?)? validator;
  String? selectValue;
  bool skipTravel = false;

  BasicDropdown(
      {super.key,
      required this.hint,
      required this.itemList,
      this.validator,
      this.selectValue,
      this.getShareDropdownCallbackFunc,
      skipTravel});

  final TextStyle _shareTextStyle = const TextStyle(
      fontSize: 12, overflow: TextOverflow.visible, color: Colors.black);

  final double _shareHeight = 40;

  @override
  Widget build(BuildContext context) {
    ///Dropdown Listesini Dolduruyor.
    List<DropdownMenuItem<String>> dropdownMenuitemList = [];
    for (var item in itemList) {
      dropdownMenuitemList.add(DropdownMenuItem(
          value: item,
          child: Container(
            /*   decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey))), */
            height: _shareHeight,
            alignment: Alignment.centerLeft,
            child: Text(
              item,
              style: context.theme.titleSmall,
            ),
          )));
    }
    return DropdownButtonFormField<String>(
      focusNode: FocusNode(skipTraversal: skipTravel),
      decoration: const InputDecoration(
        fillColor: Colors.white,
        contentPadding: EdgeInsets.fromLTRB(4, 0, 4, 0),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        filled: true,
      ),
      // ignore: prefer_const_constructors
      /*  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1), */
      hint: Container(
        height: _shareHeight,
        //    color: Colors.blue,
        alignment: Alignment.center,
        child: Text(hint, style: context.theme.titleSmall),
      ),

      icon: Icon(
        Icons.arrow_drop_down_circle,
        color: context.extensionDefaultColor,
        size: 30,
      ),
      isExpanded: true,
      isDense: true,

      // borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      // dropdownColor: Colors.blueGrey.shade200,
      items: dropdownMenuitemList,
      value: selectValue,
      onChanged: (String? value) {
        selectValue = value;
        getShareDropdownCallbackFunc!(selectValue!);
      },
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
