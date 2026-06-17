import 'package:auth_app/src/const/endpoints.dart';

class AuthEndpoints {
  const AuthEndpoints._();
  static const _baseUrl = Endpoints.baseUrl;

  static const login = '$_baseUrl/login';
  static const register = '$_baseUrl/auth/signup';
}
