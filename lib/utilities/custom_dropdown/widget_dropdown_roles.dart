import 'package:flutter/material.dart';
import 'package:stok_takip/validations/validation.dart';
import '../../data/database_helper.dart';

// ignore: must_be_immutable
class WidgetDropdownRoles extends StatelessWidget with Validation {
  final ValueChanged<String>? _getRoleCallbackFunc;
  WidgetDropdownRoles(this._getRoleCallbackFunc, {Key? key}) : super(key: key);
  String? _role;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasError && snapshot.hasData) {
            return DropdownButtonFormField<String>(
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(),
                  borderRadius: BorderRadius.circular(15),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
              ),
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
              iconSize: 36,
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
              validator: validateRoleSelectFunc,
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
