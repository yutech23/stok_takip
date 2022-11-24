import 'package:flutter/material.dart';

extension DimensionFont on BuildContext {
  double dynamicHeigh(double val) => MediaQuery.of(this).size.height;
  double dynamicWidth(double val) => MediaQuery.of(this).size.width;

  double get extendFixedWightContainer => 750;
  double get extendFixedHeighContainer => 800;

  TextTheme get theme => Theme.of(this).textTheme;

  EdgeInsets extensionPaddingAllLow() => EdgeInsets.all(dynamicHeigh(0.01));

  EdgeInsets extensionPadding20() => EdgeInsets.all(20);
  EdgeInsets extensionMargin20() => EdgeInsets.all(20);

  EdgeInsets extensionPadding10() => EdgeInsets.all(10);
  EdgeInsets extensionMargin10() => EdgeInsets.all(10);

  SizedBox extensionWidhSizedBox20() => const SizedBox(width: 20);
  SizedBox extensionHighSizedBox20() => const SizedBox(height: 20);

  void extenionShowSnackBar({
    required String message,
    Color backgroundColor = Colors.green,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Container(
          alignment: Alignment.center,
          height: 50,
          child: Text(message, style: TextStyle(fontSize: 20))),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: 4),
    ));
  }

  void extensionShowErrorSnackBar({required String message}) {
    extenionShowSnackBar(message: message, backgroundColor: Colors.red);
  }

  BoxDecoration extensionThemaButton() => BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFF8A2387),
            Color(0xFFE94057),
            Color(0XFFF27121),
          ]),
          borderRadius: BorderRadius.circular(25),
          // ignore: prefer_const_literals_to_create_immutables
          boxShadow: [
            const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.8), blurRadius: 8)
          ]);

  BoxDecoration extensionThemaContainer() => const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
            Color(0xFF8A2387),
            Color(0xFFE94057),
            Color(0XFFF27121),
          ]));

  BoxDecoration extensionThemaGreyContainer() => BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(3, 128, 132, 138),
            Color.fromARGB(45, 128, 132, 138),
            Color.fromARGB(90, 128, 132, 138),
          ]));

  BoxDecoration extensionThemaWhiteContainer() => BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 8)
          ]);
  dynamic extensionGetPercentageOfNumber(dynamic number,dynamic percentage) => number * (1+percentage/100);
}

extension ExtensionPadding on TextStyle {
  Color? get sabitColor {
    return Colors.cyanAccent;
  }
}

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
}
