import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

extension DimensionFont on BuildContext {
  double dynamicHeight(double val) => MediaQuery.of(this).size.height;
  double dynamicWidth(double val) => MediaQuery.of(this).size.width;

  double get extendFixedWightContainer => 750;
  double get extendFixedHeighContainer => 800;
  double get extensionButtonHeight => 50;

  double get extensionTextFieldWidth => 150;
  double get extensionTextFieldHeight => 40;

  Color get extensionDefaultColor => Colors.blueGrey.shade900;
  Color get extensionLineColor => Colors.blueGrey.shade600;
  Color get extensionDisableColor => Colors.grey;
  TextTheme get theme => Theme.of(this).textTheme;

  EdgeInsets extensionPaddingAllLow() => EdgeInsets.all(dynamicHeight(0.01));

  EdgeInsets extensionPadding20() => const EdgeInsets.all(20);
  EdgeInsets extensionMargin20() => const EdgeInsets.all(20);
  EdgeInsets extensionPaddingVertical10() =>
      const EdgeInsets.symmetric(vertical: 10);
  EdgeInsets extensionPaddingHorizantal10() =>
      const EdgeInsets.symmetric(horizontal: 10);

  EdgeInsets extensionPadding10() => const EdgeInsets.all(10);
  EdgeInsets extensionMargin10() => const EdgeInsets.all(10);

  SizedBox extensionWidhSizedBox10() => const SizedBox(width: 10);
  SizedBox extensionWidhSizedBox20() => const SizedBox(width: 20);
  SizedBox extensionHighSizedBox20() => const SizedBox(height: 20);
  SizedBox extensionHighSizedBox10() => const SizedBox(height: 10);

  double extensionWrapSpacing10() => 10;
  double extensionWrapSpacing20() => 20;

  BorderRadius get extensionRadiusDefault5 => BorderRadius.circular(5);
  BorderRadius get extensionRadiusDefault10 => BorderRadius.circular(10);

  void extenionShowSnackBar({
    required String message,
    Color backgroundColor = Colors.green,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Container(
          alignment: Alignment.center,
          height: 50,
          child: Text(message, style: const TextStyle(fontSize: 20))),
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

  List<BoxShadow> extensionBoxShadow() =>
      [const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 8)];
  dynamic extensionGetPercentageOfNumber(dynamic number, dynamic percentage) =>
      number * (1 + percentage / 100);

  Future noticeBarError(String message, int durationSeconds) async {
    return await Flushbar(
      backgroundColor: Colors.red,
      titleText: Text(
        'HATA MESAJI',
        textAlign: TextAlign.center,
        style: theme.titleLarge!.copyWith(
            color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
      messageText: Text(message,
          style: theme.titleLarge!.copyWith(color: Colors.white),
          textAlign: TextAlign.center),
      duration: Duration(seconds: durationSeconds),
    ).show(this);
  }

  Future noticeBarCustom(String header, String message, int durationSeconds,
      Color background) async {
    return await Flushbar(
      backgroundColor: background,
      titleText: Text(
        header,
        textAlign: TextAlign.center,
        style: theme.titleLarge!.copyWith(
            color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
      messageText: Text(message,
          style: theme.titleLarge!.copyWith(color: Colors.white),
          textAlign: TextAlign.center),
      duration: Duration(seconds: durationSeconds),
    ).show(this);
  }

  Future noticeBarTrue(String message, int durationSeconds) async {
    return await Flushbar(
      backgroundColor: Colors.green,
      titleText: Text(
        'BAŞARILI',
        textAlign: TextAlign.center,
        style: theme.titleLarge!.copyWith(
            color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
      messageText: Text(
        message,
        style: theme.titleLarge!.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      duration: Duration(seconds: durationSeconds),
    ).show(this);
  }
}

Widget spaceColumn = const Divider(height: 10);
Widget spaceRowSizedBox = const SizedBox(width: 10);

extension ExtensionPadding on TextStyle {
  Color? get sabitColor {
    return Colors.cyanAccent;
  }
}

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${substring(1)}';
  String get allInCaps => toUpperCase();
}

class Dimension {
  final double widthMainSection = 870;
  final double heightSection = 720;
  final double paddingMainAndSide = 20;
  final double widthSideSection = 360;
  final double heightInputTextAnDropdown50 = 50;
  final double heightInputTextAnDropdown40 = 40;
  final double widthMainSectionInsideHalfOfTheRow = 405;
  final double widthTable = 830;
  final double widthMobilButtonAndTextfield = 340;
}

Dimension dimension = Dimension();
