import 'package:auth_app/src/model/user.dart';

// class Auth {
//   final User user;
//   final String token;

//   Auth({required this.user, required this.token});

//   factory Auth.fromJson(Map<String, dynamic> json) {
//     return Auth(user: User.fromJson(json['user']), token: json['token']);
//   }

//   Map<String, dynamic> toJson() {
//     return {'user': user.toJson(), 'token': token};
//   }
// }

class Auth {
  final User user;
  final String token;

  Auth({required this.user, required this.token});

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(user: User.fromJson(json['user']), token: json['token']);
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': token};
  }
}

class AuthResponse {
  final bool success;
  final AuthData data;
  final String message;

  AuthResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'],
      data: AuthData.fromJson(json['data']),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson(), 'message': message};
  }
}

class AuthData {
  final String id;
  final String token;

  AuthData({required this.id, required this.token});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(id: json['_id'], token: json['token']);
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'token': token};
  }
}
