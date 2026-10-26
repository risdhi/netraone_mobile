import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const apiBase = String.fromEnvironment('API_BASE_URL', defaultValue: '');

class ApiError implements Exception {
  final String message;

  ApiError(this.message);

  @override
  String toString() => message;
}

class Api {
  Api({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? apiBase;

  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final http.Client _client;
  final String _baseUrl;
  VoidCallback? onUnauthorized;
  String? token;
  Map<String, dynamic>? me;

  Uri _uri(String path) {
    final base = _baseUrl.trim();
    if (base.isEmpty) {
      throw ApiError(
        'URL API belum dikonfigurasi. Jalankan aplikasi dengan '
        '--dart-define=API_BASE_URL=https://domain-backend',
      );
    }
    final origin = Uri.tryParse(base);
    if (origin == null ||
        !origin.hasAuthority ||
        origin.host.isEmpty ||
        origin.path.isNotEmpty && origin.path != '/' ||
        origin.hasQuery ||
        origin.hasFragment ||
        origin.userInfo.isNotEmpty ||
        !const ['http', 'https'].contains(origin.scheme)) {
      throw ApiError(
        'API_BASE_URL harus berupa origin backend, misalnya '
        'https://domain-backend tanpa /api/v1, path, query, atau slash akhir.',
      );
    }
    final localHosts = {'localhost', '127.0.0.1', '10.0.2.2', '::1'};
    if (origin.scheme != 'https' && !localHosts.contains(origin.host)) {
      throw ApiError(
        'API_BASE_URL harus menggunakan HTTPS kecuali untuk host lokal.',
      );
    }
    final relative = Uri.parse(path.startsWith('/') ? path.substring(1) : path);
    return origin.replace(
      path: '/api/v1/${relative.path}',
      query: relative.hasQuery ? relative.query : null,
      fragment: null,
    );
  }

  Future<void> restore() async {
    token = await storage.read(key: 'netra_token');
    if (token == null) return;

    final result = await request('GET', '/me');
    if (result is! Map) throw ApiError('Respons profil tidak sesuai kontrak');
    me = Map<String, dynamic>.from(result);
  }

  Future<dynamic> request(
    String method,
    String path, [
    Map<String, dynamic>? data,
  ]) async {
    final request = http.Request(method, _uri(path))
      ..headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (data != null) request.body = jsonEncode(data);

    late final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 20)),
      );
    } catch (e) {
      throw ApiError('Koneksi gagal: $e');
    }

    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } on FormatException {
        body = response.body;
      }
    }

    if (response.statusCode == 401) {
      await _clearLocalSession();
      onUnauthorized?.call();
    }
    if (response.statusCode >= 400) {
      var message = body is Map
          ? '${body['message'] ?? 'Request gagal'}'
          : body is String && body.isNotEmpty
          ? body
          : 'Request gagal';
      if (body is Map && body['errors'] is Map) {
        final errors = (body['errors'] as Map).values
            .expand((value) => value is List ? value : [value])
            .join('; ');
        if (errors.isNotEmpty) message = errors;
      }
      throw ApiError('$message (${response.statusCode})');
    }
    return body;
  }

  Future<void> login(String email, String password) async {
    final result = await request('POST', '/mobile/login', {
      'email': email,
      'password': password,
    });
    if (result is! Map || result['token'] == null || result['user'] is! Map) {
      throw ApiError('Respons login tidak sesuai kontrak');
    }

    token = '${result['token']}';
    me = Map<String, dynamic>.from(result['user']);
    try {
      await storage.write(key: 'netra_token', value: token);
    } catch (_) {
      await _clearLocalSession();
      rethrow;
    }
  }

  Future<void> logout() async {
    Object? logoutError;
    try {
      if (token != null) await request('POST', '/mobile/logout');
    } catch (e) {
      logoutError = e;
    } finally {
      await _clearLocalSession();
    }
    if (logoutError != null) throw ApiError('$logoutError');
  }

  Future<void> _clearLocalSession() async {
    token = null;
    me = null;
    await storage.delete(key: 'netra_token');
  }

  Future<List<Map<String, dynamic>>> list(
    String resource, {
    String search = '',
  }) async {
    final query = Uri(
      queryParameters: {'per_page': '100', if (search.isNotEmpty) 'q': search},
    ).query;
    final result = await request('GET', '/$resource?$query');
    final rows = result is Map ? result['data'] : result;
    if (rows is! List) {
      throw ApiError('Format daftar $resource tidak dikenal');
    }
    return rows.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<Map<String, dynamic>> page(
    String resource, {
    String search = '',
    int page = 1,
    int perPage = 25,
  }) async {
    final query = Uri(
      queryParameters: {
        'page': '$page',
        'per_page': '${perPage.clamp(1, 100)}',
        if (search.isNotEmpty) 'q': search,
      },
    ).query;
    final response = await request('GET', '/$resource?$query');
    if (response is! Map || response['data'] is! List) {
      throw ApiError('Format pagination tidak sesuai');
    }
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> detail(String resource, Object id) async {
    final response = await request('GET', '/$resource/$id');
    if (response is! Map) throw ApiError('Format detail tidak sesuai');
    return Map<String, dynamic>.from(response);
  }
}

final api = Api();
