import 'dart:async';
import 'package:dio/dio.dart';

class ExchangeRateApi {
  final _dio = Dio();

  final _streamControllerExchangeRate =
      StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get getStreamExchangeRate =>
      _streamControllerExchangeRate.stream;

  Map<String, double> exchangeRate = {};
  Future getExchangeRate() async {
    try {
      Response response = await _dio.get(
        'https://3dbaskiservis.com/api/exchange/?interval=600',
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> resData = response.data;
        resData.forEach((key, value) {
          if (key == 'USD') {
            exchangeRate.addAll({key: value});
          }
          if (key == 'EUR') {
            exchangeRate.addAll({key: value});
          }
          if (key == 'TIME') {
            exchangeRate.addAll({key: value});
          }
        });

        _streamControllerExchangeRate.sink.add(exchangeRate);
      }
    } catch (e) {
      print("Api Hatası : $e");
      return exchangeRate;
    }
  }
}

final exchangeRateService = ExchangeRateApi();
