import 'dart:convert';

import 'package:auth_app/src/model/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences.g.dart';

@Riverpod(keepAlive: true)
SharedPrefService sharedPrefService(Ref ref) => SharedPrefService();

class SharedPrefService {
  static const String _authKey = "AUTH_KEY";

  Future<void> saveAuth(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_authKey, jsonEncode(auth.toJson()));
  }

  Future<AuthResponse?> getAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString(_authKey);
    if (authData == null) {
      return null;
    }

    return AuthResponse.fromJson(jsonDecode(authData));
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_authKey);
  }
}
