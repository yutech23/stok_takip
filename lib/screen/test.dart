import 'package:flutter/material.dart';

import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

import '../service/exchange_rate_api.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

String sum = "none";

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text(
                "getir",
              ),
              onPressed: () async {
                //   String? deger = await dioService.getExchangeRate();
                //String? usd = await dioService.getExchangeRateUSD();
                String? euro = await dioService.getExchangeRateEUR();
                //  print("dio deger : $deger");
                //  print("dio USD : $usd");
                print("dio Euro : $euro");
              },
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              Sabitler.deger.toString(),
              style: context.theme.headline6,
            ),
          ],
        ),
      )),
    );
  }
}
