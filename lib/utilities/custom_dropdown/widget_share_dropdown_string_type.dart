import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

///Widget - Basic Dropdown Menü String List ile doluyor Future List ile değil.

// ignore: must_be_immutable
class ShareDropdown extends StatelessWidget {
  final ValueChanged<String>? getShareDropdownCallbackFunc;
  String hint;
  List<String> itemList;
  String? Function(String?)? validator;
  String? selectValue;
  bool skipTravel = false;

  ShareDropdown(
      {required this.hint,
      required this.itemList,
      this.validator,
      this.selectValue,
      this.getShareDropdownCallbackFunc,
      skipTravel});

  @override
  Widget build(BuildContext context) {
    ///Dropdown Listesini Dolduruyor.
    List<DropdownMenuItem<String>> dropdownMenuitemList = [];
    for (var item in itemList) {
      dropdownMenuitemList.add(DropdownMenuItem(
          value: item,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(item),
          )));
    }
    return DropdownButtonFormField<String>(
      focusNode: FocusNode(skipTraversal: skipTravel),
      decoration: InputDecoration(
        isDense: false,
        contentPadding: const EdgeInsets.only(right: 5, bottom: 15),
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(15)),
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
      onChanged: (String? value) {
        selectValue = value;
        getShareDropdownCallbackFunc!(selectValue!);
      },
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
