import 'dart:developer';

import 'package:auth_app/src/commons/providers/dio.dart';
import 'package:auth_app/src/model/failure.dart';
import 'package:auth_app/src/network/types.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_auth/src/commons/providers/auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:auth_app/src/commons/providers/auth.dart';
part 'network.g.dart';

@Riverpod(keepAlive: true)
NetworkRepository networkRepository(Ref ref) {
  return NetworkRepository(
    authToken: ref.watch(currentAuthProvider)?.token ?? '',
    dio: ref.watch(dioProvider),
  );
}

class NetworkRepository {
  final String? _authToken;
  final Dio _dio;

  NetworkRepository({required String? authToken, required Dio dio})
    : _dio = dio,
      _authToken = authToken;

  /// Helper to generate standard headers for all requests
  Options _getOptions() {
    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    );
  }

  /// Generic handler for Dio requests to ensure consistent Error handling
  FutureEither<Response> _requestSafely(
    Future<Response> Function() request,
    String method,
    String url,
    dynamic data,
  ) async {
    try {
      _debugPrint(method: method, url: url, data: data);
      final response = await request();

      return Right(response);
    } on DioException catch (e) {
      return Left(
        Failure(
          message: e.message ?? 'Dio Exception occurred',
          stackTrace: e.stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      return Left(Failure(message: e.toString(), stackTrace: stackTrace));
    }
  }

  // --- GET ---
  FutureEither<Response> getRequest({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) {
    return _requestSafely(
      () => _dio.get(
        url,
        queryParameters: queryParameters,
        options: _getOptions(), // Uses common headers
      ),
      'GET',
      url,
      null,
    );
  }

  // --- POST ---
  FutureEither<Response> postRequest({required String url, dynamic data}) {
    return _requestSafely(
      () => _dio.post(
        url,
        data: data,
        options: _getOptions(), // Uses common headers
      ),
      'POST',
      url,
      data,
    );
  }

  // --- PUT ---
  FutureEither<Response> putRequest({required String url, dynamic data}) {
    return _requestSafely(
      () => _dio.put(
        url,
        data: data,
        options: _getOptions(), // Uses common headers
      ),
      'PUT',
      url,
      data,
    );
  }

  // --- DELETE ---
  FutureEither<Response> deleteRequest({required String url, dynamic data}) {
    return _requestSafely(
      () => _dio.delete(
        url,
        data: data,
        options: _getOptions(), // Uses common headers
      ),
      'DELETE',
      url,
      data,
    );
  }

  // --- UPDATE (PATCH) ---
  FutureEither<Response> updateRequest({required String url, dynamic data}) {
    return _requestSafely(
      () => _dio.patch(
        url,
        data: data,
        options: _getOptions(), // Uses common headers
      ),
      'PATCH',
      url,
      data,
    );
  }

  void _debugPrint({
    required String method,
    required String url,
    dynamic data,
  }) {
    if (kDebugMode) {
      print('🌐 [Network] $method Request: $url');
      if (data != null) print('📦 Data: $data');
      if (_authToken != null) print('🔑 Auth Token Present');
    }
  }
}
