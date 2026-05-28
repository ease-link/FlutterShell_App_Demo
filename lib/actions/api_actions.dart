import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiActions {
  static Future<dynamic> call(
    String endpoint, {
    String method                  = 'GET',
    Map<String, dynamic>? body,
    Map<String, dynamic> state     = const {},
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final h   = {'Content-Type': 'application/json', ...?headers};
      http.Response resp;

      switch (method.toUpperCase()) {
        case 'POST':
          resp = await http.post(uri, headers: h, body: jsonEncode(body ?? {}));
          break;
        case 'PUT':
          resp = await http.put(uri, headers: h, body: jsonEncode(body ?? {}));
          break;
        case 'DELETE':
          resp = await http.delete(uri, headers: h);
          break;
        default:
          resp = await http.get(uri, headers: h);
      }

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return jsonDecode(resp.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
