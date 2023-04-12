import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/validation.dart';
import '../../data/database_helper.dart';

// ignore: must_be_immutable
class WidgetDropdownRoles extends StatelessWidget with Validation {
  final ValueChanged<String>? _getRoleCallbackFunc;
  WidgetDropdownRoles(this._role, this._getRoleCallbackFunc, {Key? key})
      : super(key: key);
  String? _role;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasError && snapshot.hasData) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: context.extensionDefaultColor,
                  borderRadius: BorderRadius.circular(15)),
              width: 360,
              height: 40,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    focusedBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 5, 0)),
                // ignore: prefer_const_constructors
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),

                hint: const Center(
                  child: Text(
                    "Yetki Tipini Seçiniz.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                iconSize: 30,
                icon: const Icon(
                  Icons.arrow_drop_down_circle_sharp,
                  color: Colors.white,
                ),
                isExpanded: true,
                dropdownColor: Colors.blueGrey.shade200,
                items: roleList(snapshot.data!),

                value: _role,
                onChanged: (String? value) {
                  _role = value;
                  _getRoleCallbackFunc!(_role!);
                },
                // validator: validateRoleSelectFunc,
              ),
            );
          } else {
            return const Text("");
          }
        },
        future: db.getRoles());
  }

  List<DropdownMenuItem<String>>? roleList(List<String> roles) {
    List<DropdownMenuItem<String>> roleList = [];
    for (var item in roles) {
      roleList.add(DropdownMenuItem(
          value: item,
          child: Container(
            alignment: Alignment.center,
            child: Text(item),
          )));
    }
    return roleList;
  }
}
