import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  Future<String> chat(String prompt, {String? context}) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content':
              '你是 Money Plan 的智能理财助手"小财"。你擅长分析用户的消费习惯，提供理财建议，帮助用户实现存款目标。请用简洁友好的语气回复，适合手机展示。回复控制在200字以内。'
        },
      ];

      if (context != null) {
        messages.add({'role': 'system', 'content': context});
      }

      messages.add({'role': 'user', 'content': prompt});

      final response = await http.post(
        Uri.parse(AppConstants.aiApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.aiApiKey}',
        },
        body: jsonEncode({
          'model': AppConstants.aiModel,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 300,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'];
        }
        return '暂时无法获取分析结果。';
      } else {
        print('AI API Error: ${response.statusCode} - ${response.body}');
        return 'AI 服务暂时不可用，请稍后再试。';
      }
    } catch (e) {
      print('AI Service Error: $e');
      if (e.toString().contains('timeout')) {
        return '请求超时，请检查网络后重试。';
      }
      return '网络连接出现问题，请检查网络后重试。';
    }
  }

  Future<String> analyzeSpending({
    required double monthlyBudget,
    required double monthlySpent,
    required double todaySpent,
    required Map<String, double> categoryBreakdown,
  }) async {
    final context = '''
用户财务数据：
- 月度预算：¥${monthlyBudget.toStringAsFixed(2)}
- 本月已消费：¥${monthlySpent.toStringAsFixed(2)}
- 今日消费：¥${todaySpent.toStringAsFixed(2)}
- 消费分类：${categoryBreakdown.entries.map((e) => '${e.key}: ¥${e.value.toStringAsFixed(2)}').join('，')}
''';

    return chat(
      '请分析我的消费情况，给出简短的理财建议（3句话以内）。',
      context: context,
    );
  }

  Future<String> calculateGoalTimeline({
    required double goalAmount,
    required double currentSavings,
    required double monthlyIncome,
    required double monthlyExpense,
  }) async {
    final monthlySaving = monthlyIncome - monthlyExpense;
    final remaining = goalAmount - currentSavings;

    if (monthlySaving <= 0) {
      return '按照目前的收支情况，每月无法存钱。建议减少支出或增加收入。';
    }

    final monthsNeeded = (remaining / monthlySaving).ceil();
    final years = monthsNeeded ~/ 12;
    final months = monthsNeeded % 12;

    String timeline = '';
    if (years > 0) timeline += '$years年';
    if (months > 0) timeline += '$months个月';

    return '按照每月存¥${monthlySaving.toStringAsFixed(0)}的速度，预计需要$timeline达成目标。';
  }
}
