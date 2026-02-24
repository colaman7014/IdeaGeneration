/// API 服務 - 連接 FastAPI 後端
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:8000/api';

  // ── 新聞相關 ────────────────────────────────────────────

  /// 取得隨機兩則新聞
  Future<NewsPair> getRandomNewsPair() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/news/random-pair'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return NewsPair.fromJson(data);
    }
    throw ApiException(response.statusCode, _parseError(response.body));
  }

  /// 取得新聞列表
  Future<List<NewsItem>> getNewsList({int skip = 0, int limit = 20}) async {
    final uri = Uri.parse('$_baseUrl/news').replace(
      queryParameters: {'skip': '$skip', 'limit': '$limit'},
    );
    final response =
        await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['items'] as List<dynamic>)
          .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(response.statusCode, _parseError(response.body));
  }

  // ── 點子相關 ────────────────────────────────────────────

  /// 生成商業構想
  Future<IdeaItem> generateIdea({
    List<int> newsIds = const [],
    List<int> tagIds = const [],
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/ideas/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'news_ids': newsIds, 'tag_ids': tagIds}),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      return IdeaItem.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw ApiException(response.statusCode, _parseError(response.body));
  }

  /// 執行魔鬼審計
  Future<String> devilAudit(int ideaId) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/ideas/devil-audit'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idea_id': ideaId}),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['audit_questions'] as String;
    }
    throw ApiException(response.statusCode, _parseError(response.body));
  }

  /// 匯出點子為 Markdown
  Future<String> exportIdeaMarkdown(int ideaId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/ideas/$ideaId/export'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['content'] as String;
    }
    throw ApiException(response.statusCode, _parseError(response.body));
  }

  /// 取得點子列表
  Future<List<IdeaItem>> getIdeasList({int skip = 0, int limit = 20}) async {
    final uri = Uri.parse('$_baseUrl/ideas').replace(
      queryParameters: {'skip': '$skip', 'limit': '$limit'},
    );
    final response =
        await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['items'] as List<dynamic>)
          .map((e) => IdeaItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(response.statusCode, _parseError(response.body));
  }

  // ── 工具方法 ─────────────────────────────────────────────

  String _parseError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['detail'] as String? ?? '未知錯誤';
    } catch (_) {
      return body;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
