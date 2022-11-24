import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_interceptor/http/interceptor_contract.dart';
import 'package:http_interceptor/models/response_data.dart';
import 'package:http_interceptor/models/request_data.dart';

class ServiceInterceptor implements InterceptorContract {
  ServiceInterceptor._intenat();

  static final _singlatonServiceInterceptor = ServiceInterceptor._intenat();

  factory ServiceInterceptor() {
    return _singlatonServiceInterceptor;
  }

  final storageToken = FlutterSecureStorage();

  Future<String> get tokenOrEmpty async {
    var token = await storageToken.read(key: "token");
    if (token == null) {
      return "";
    }
    return token;
  }

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    String token = await tokenOrEmpty;
    try {
      data.headers["Authorization"] = token;
    } catch (e) {}
    throw UnimplementedError();
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) {
    // TODO: implement interceptResponse
    throw UnimplementedError();
  }
}
