/// 匯出狀態管理 - 管理 Markdown 匯出流程
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ExportProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  String? _markdownContent;
  bool _isLoading = false;
  String? _errorMessage;

  String? get markdownContent => _markdownContent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 載入 Markdown 匯出內容
  Future<void> loadMarkdown(int ideaId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _markdownContent = await _api.exportIdeaMarkdown(ideaId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '\u7121\u6cd5\u7522\u751f\u532f\u51fa\u5167\u5bb9';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 重置匯出狀態
  void reset() {
    _markdownContent = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
