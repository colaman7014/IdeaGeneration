/// App 狀態管理 - 管理整個 3 分鐘流程
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

enum AppState { idle, loadingNews, generating, generated, auditing, done }

class IdeaProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  AppState _state = AppState.idle;
  NewsPair? _newsPair;
  IdeaItem? _currentIdea;
  String? _errorMessage;

  AppState get state => _state;
  NewsPair? get newsPair => _newsPair;
  IdeaItem? get currentIdea => _currentIdea;
  String? get errorMessage => _errorMessage;
  bool get isLoading =>
      _state == AppState.loadingNews ||
      _state == AppState.generating ||
      _state == AppState.auditing;

  /// 從外部設定新聞對（由 NewsProvider 傳入）
  void setNewsPair(NewsPair pair) {
    _newsPair = pair;
    notifyListeners();
  }

  /// 重新抽取隨機新聞對
  Future<void> fetchRandomPair() async {
    _setState(AppState.loadingNews);
    _clearError();
    try {
      _newsPair = await _api.getRandomNewsPair();
      _setState(AppState.idle);
    } on ApiException catch (e) {
      _setError('無法載入新聞：${e.message}');
    } catch (e) {
      _setError('連線失敗，請確認後端服務已啟動');
    }
  }

  /// 根據目前新聞對生成點子
  Future<void> generateIdea() async {
    if (_newsPair == null) return;
    _setState(AppState.generating);
    _clearError();
    try {
      _currentIdea = await _api.generateIdea(
        newsIds: [_newsPair!.newsA.id, _newsPair!.newsB.id],
      );
      _setState(AppState.generated);
    } on ApiException catch (e) {
      _setError('點子生成失敗：${e.message}');
      _setState(AppState.idle);
    } catch (e) {
      _setError('連線失敗，請稍後再試');
      _setState(AppState.idle);
    }
  }

  /// 對點子執行魔鬼審計
  Future<void> runDevilAudit() async {
    if (_currentIdea == null) return;
    _setState(AppState.auditing);
    _clearError();
    try {
      final auditResult = await _api.devilAudit(_currentIdea!.id);
      // 用 copyWith 更新審計結果
      _currentIdea = _currentIdea!.copyWith(devilAudit: auditResult);
      _setState(AppState.done);
    } on ApiException catch (e) {
      _setError('魔鬼審計失敗：${e.message}');
      _setState(AppState.generated);
    } catch (e) {
      _setError('連線失敗，請稍後再試');
      _setState(AppState.generated);
    }
  }

  /// 匯出 Markdown
  Future<String?> exportMarkdown() async {
    if (_currentIdea == null) return null;
    try {
      return await _api.exportIdeaMarkdown(_currentIdea!.id);
    } catch (_) {
      return null;
    }
  }

  /// 重置流程，回到首頁
  void reset() {
    _state = AppState.idle;
    _newsPair = null;
    _currentIdea = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(AppState s) {
    _state = s;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _state = AppState.idle;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
