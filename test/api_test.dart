import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:netraone_mobile/core/network/api.dart';

void main() {
  test(
    'page requests the configured endpoint and parses Laravel pagination',
    () async {
      late Uri requestedUri;
      final api = Api(
        baseUrl: 'https://api.example.test',
        client: MockClient((request) async {
          requestedUri = request.url;
          expect(request.headers['Accept'], 'application/json');
          return http.Response(
            jsonEncode({
              'data': [
                {'id': 1, 'event_type': 'Intrusion'},
              ],
              'total': 1,
              'last_page': 1,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final response = await api.page(
        'events',
        page: 2,
        perPage: 12,
        search: 'intrusion',
      );

      expect(requestedUri.path, '/api/v1/events');
      expect(requestedUri.queryParameters, {
        'page': '2',
        'per_page': '12',
        'q': 'intrusion',
      });
      expect(response['total'], 1);
      expect((response['data'] as List).single['event_type'], 'Intrusion');
    },
  );

  test(
    'preserves API permission errors instead of returning an empty page',
    () async {
      final api = Api(
        baseUrl: 'https://api.example.test',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({'message': 'Akses ditolak'}),
            403,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );

      await expectLater(
        api.page('events'),
        throwsA(
          isA<ApiError>().having(
            (error) => error.message,
            'message',
            'Akses ditolak (403)',
          ),
        ),
      );
    },
  );

  test('supports a base URL that already includes the API path', () async {
    late Uri requestedUri;
    final api = Api(
      baseUrl: 'https://api.example.test/api/v1/',
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(jsonEncode({'data': []}), 200);
      }),
    );

    await api.page('events');

    expect(requestedUri.path, '/api/v1/events');
  });

  test('sends the saved token as a Bearer authorization header', () async {
    final api = Api(
      baseUrl: 'https://api.example.test',
      client: MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer test-token');
        return http.Response('{}', 200);
      }),
    )..token = 'test-token';

    await api.request('GET', '/me');
  });
}
