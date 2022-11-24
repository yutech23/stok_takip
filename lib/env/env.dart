import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: '.env.dev')
abstract class Env {
  @EnviedField(varName: 'KEY1', obfuscate: true)
  static final url = _Env._url;

  @EnviedField(varName: 'KEY2', obfuscate: true)
  static final apiKey = _Env._anonKey;
}
