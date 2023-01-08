import 'package:dio/dio.dart';

class ExchangeRateApi {
  final _dio = Dio();

  Future<String?> getExchangeRate() async {
    Response response =
        await _dio.get('http://54.144.168.5:8081/api/exchange/?format=json');

    /*  if (response.statusCode == 200) {
      final _rest = response.data;

      print(_rest);

      return 'basarili';
    } else
      return null; */
  }

  /*  Future<String?> getExchangeRateUSD() async {
    Response responseUSD = await _dio.get(
        '${Env.exchangeRateUrl}?api_key=${Env.exchangeRateApiKey}&base=USD&target=TRY');

    if (responseUSD.statusCode == 200) {
      final _rest1 = responseUSD.data;

      print(_rest1);

      return 'basarili';
    } else
      return null;
  }

  Future<String?> getExchangeRateEUR() async {
    Response responseEUR = await _dio.get(
        '${Env.exchangeRateUrl}?api_key=${Env.exchangeRateApiKey}&base=EUR&target=TRY');
    if (responseEUR.statusCode == 200) {
      final _rest2 = responseEUR.data;

      print(_rest2);
      return 'basarili';
    } else
      return null;
  }
} */
}

final exchangeRateService = ExchangeRateApi();
