import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: '.env.dev')
abstract class Env {
  @EnviedField(varName: 'KEY1', obfuscate: true)
  static const url = _Env._url;

  @EnviedField(varName: 'KEY2', obfuscate: true)
  static const apiKey = _Env._anonKey;

  @EnviedField(varName: 'EXCHANGE_RATE_URL', obfuscate: true)
  static const exchangeRateUrl = _Env._urlExchangeRate;

  @EnviedField(varName: 'EXCHANGE_RATE_APIKEY', obfuscate: true)
  static const exchangeRateApiKey = _Env._keyExchangeRate;
}
