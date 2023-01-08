import 'dart:io';

import 'package:dio/dio.dart';

class ExchangeRateApi {
  final _dio = Dio();

  Future<Map<String, double>> getExchangeRate() async {
    Map<String, double> _exchangeRate = {};
    try {
      Response response = await _dio.get(
        'http://54.144.168.5:8081/api/exchange/',
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> resData = response.data;
        resData.forEach((key, value) {
          if (key == 'USD') {
            _exchangeRate.addAll({key: value});
          }
          if (key == 'EUR') {
            _exchangeRate.addAll({key: value});
          }
        });
        return _exchangeRate;
      } else {
        return _exchangeRate;
      }
    } catch (e) {
      print("Api Hatası : $e");
      return _exchangeRate;
    }
  }

  Stream getExchangeRateStream() {
    var response = _dio
        .get(
          'http://54.144.168.5:8081/api/exchange/',
        )
        .asStream();

    response.listen((event) {
      print(event);
    });

    return response;
  }
}

final exchangeRateService = ExchangeRateApi();
