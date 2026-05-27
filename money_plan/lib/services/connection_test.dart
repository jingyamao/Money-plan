import '../config/constants.dart';
import 'package:http/http.dart' as http;

class ConnectionTest {
  static Future<Map<String, dynamic>> testSupabaseConnection() async {
    final results = <String, dynamic>{
      'supabase_url': AppConstants.supabaseUrl,
      'tests': <String, dynamic>{},
    };

    // 测试 1: 基本连接
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.supabaseUrl}/rest/v1/'),
        headers: {
          'apikey': AppConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
        },
      ).timeout(const Duration(seconds: 10));

      results['tests']['basic_connection'] = {
        'status': response.statusCode == 200 ? 'success' : 'failed',
        'status_code': response.statusCode,
      };
    } catch (e) {
      results['tests']['basic_connection'] = {
        'status': 'error',
        'message': e.toString(),
      };
    }

    // 测试 2: 查询 transactions 表
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.supabaseUrl}/rest/v1/transactions?select=count'),
        headers: {
          'apikey': AppConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
          'Prefer': 'count=exact',
        },
      ).timeout(const Duration(seconds: 10));

      results['tests']['transactions_table'] = {
        'status': response.statusCode == 200 ? 'success' : 'failed',
        'status_code': response.statusCode,
        'body': response.body.substring(0, response.body.length > 200 ? 200 : response.body.length),
      };
    } catch (e) {
      results['tests']['transactions_table'] = {
        'status': 'error',
        'message': e.toString(),
      };
    }

    // 测试 3: 查询 user_settings 表
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.supabaseUrl}/rest/v1/user_settings?select=count'),
        headers: {
          'apikey': AppConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
          'Prefer': 'count=exact',
        },
      ).timeout(const Duration(seconds: 10));

      results['tests']['user_settings_table'] = {
        'status': response.statusCode == 200 ? 'success' : 'failed',
        'status_code': response.statusCode,
      };
    } catch (e) {
      results['tests']['user_settings_table'] = {
        'status': 'error',
        'message': e.toString(),
      };
    }

    return results;
  }

  static String formatResults(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('=== Supabase 连接测试 ===');
    buffer.writeln('URL: ${results['supabase_url']}');
    buffer.writeln('');

    final tests = results['tests'] as Map<String, dynamic>;
    for (final entry in tests.entries) {
      final test = entry.value as Map<String, dynamic>;
      final status = test['status'];
      final icon = status == 'success' ? '✓' : '✗';
      buffer.writeln('$icon ${entry.key}: $status');

      if (test.containsKey('status_code')) {
        buffer.writeln('  Status Code: ${test['status_code']}');
      }
      if (test.containsKey('message')) {
        buffer.writeln('  Message: ${test['message']}');
      }
      if (test.containsKey('body')) {
        buffer.writeln('  Body: ${test['body']}');
      }
    }

    return buffer.toString();
  }
}
