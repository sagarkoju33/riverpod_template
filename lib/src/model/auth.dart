import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

// ─── Auth ───────────────────────────────────────────────

@freezed
sealed class Auth with _$Auth {
  const factory Auth({
    // 👈 const is required for .g.dart to generate
    required User user,
    required String token,
  }) = _Auth;

  factory Auth.fromJson(Map<String, dynamic> json) => _$AuthFromJson(json);
}

// ─── AuthResponse ────────────────────────────────────────
@freezed
sealed class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required bool success,
    required AuthData data,
    required String message,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

// ─── AuthData ────────────────────────────────────────────
@freezed
sealed class AuthData with _$AuthData {
  const factory AuthData({
    @JsonKey(name: '_id') required String id,
    required String token,
  }) = _AuthData;

  factory AuthData.fromJson(Map<String, dynamic> json) =>
      _$AuthDataFromJson(json);
}

@freezed
sealed class User with _$User {
  const factory User({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
