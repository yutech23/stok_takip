import 'package:flutter/material.dart';

class DatatableHeader {
  final String text;
  final String value;
  final bool sortable;
  final bool editable;
  bool show;
  final TextAlign textAlign;
  final int flex;
  final Widget Function(dynamic value)? headerBuilder;
  final Widget Function(dynamic value, Map<String?, dynamic> row)?
      sourceBuilder;

  DatatableHeader({
    required this.text,
    required this.value,
    this.textAlign = TextAlign.center,
    this.sortable = false,
    this.show = true,
    this.editable = false,
    this.flex = 1,
    this.headerBuilder,
    this.sourceBuilder,
  });

  factory DatatableHeader.fromMap(Map<String, dynamic> map) => DatatableHeader(
        text: map['text'],
        value: map['value'],
        sortable: map['sortable'],
        show: map['show'],
        textAlign: map['textAlign'],
        flex: map['flex'],
        headerBuilder: map['headerBuilder'],
        sourceBuilder: map['sourceBuilder'],
      );
  Map<String, dynamic> toMap() => {
        "text": text,
        "value": value,
        "sortable": sortable,
        "show": show,
        "textAlign": textAlign,
        "flex": flex,
        "headerBuilder": headerBuilder,
        "sourceBuilder": sourceBuilder,
      };
}
