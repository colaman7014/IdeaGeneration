/// 新聞狀態管理 - 管理新聞抽取流程
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

enum NewsState { idle, loading, loaded, error }

class NewsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  NewsState _state = NewsState.idle;
  NewsPair? _newsPair;
  String? _errorMessage;

  NewsState get state => _state;
  NewsPair? get newsPair => _newsPair;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == NewsState.loading;

  /// 重新抽取隨機新聞對
  Future<void> fetchRandomPair() async {
    _state = NewsState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _newsPair = await _api.getRandomNewsPair();
      _state = NewsState.loaded;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = '\u7121\u6cd5\u8f09\u5165\u65b0\u805e\uff1a${e.message}';
      _state = NewsState.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = '\u9023\u7dda\u5931\u6557\uff0c\u8acb\u78ba\u8a8d\u5f8c\u7aef\u670d\u52d9\u5df2\u555f\u52d5';
      _state = NewsState.error;
      notifyListeners();
    }
  }

  /// 重置新聞狀態
  void reset() {
    _state = NewsState.idle;
    _newsPair = null;
    _errorMessage = null;
    notifyListeners();
  }
}
