import 'package:dio/dio.dart';
import 'package:stok_takip/env/env.dart';

class ServiceExchangeRateApi {
  final _dio = Dio();

  Future<String?> getExchangeRate() async {
    Response response = await _dio.get(
        '${Env.exchangeRateUrl}?api_key=${Env.exchangeRateApiKey}&base=TRY&target=USD,EUR');

    if (response.statusCode == 200) {
      final rest = response.data;

      print(rest);

      return 'basarili';
    } else {
      return null;
    }
  }

  Future<String?> getExchangeRateUSD() async {
    Response responseUSD = await _dio.get(
        '${Env.exchangeRateUrl}?api_key=${Env.exchangeRateApiKey}&base=USD&target=TRY');

    if (responseUSD.statusCode == 200) {
      final rest1 = responseUSD.data;

      print(rest1);

      return 'basarili';
    } else {
      return null;
    }
  }

  Future<String?> getExchangeRateEUR() async {
    Response responseEUR = await _dio.get(
        '${Env.exchangeRateUrl}?api_key=${Env.exchangeRateApiKey}&base=EUR&target=TRY');
    if (responseEUR.statusCode == 200) {
      final rest2 = responseEUR.data;

      print(rest2);
      return 'basarili';
    } else {
      return null;
    }
  }
}

final dioService = ServiceExchangeRateApi();
