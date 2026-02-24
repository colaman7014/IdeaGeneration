"""統一例外定義"""


class AppException(Exception):
    """應用程式基礎例外"""
    status_code: int = 500
    detail: str = "內部錯誤"
    
    def __init__(self, detail: str | None = None):
        self.detail = detail or self.__class__.detail
        super().__init__(self.detail)


class NotFoundError(AppException):
    """資源不存在"""
    status_code = 404
    detail = "資源不存在"


class InsufficientDataError(AppException):
    """資料不足"""
    status_code = 400
    detail = "資料庫中沒有足夠的資料"


class LLMError(AppException):
    """LLM 服務錯誤"""
    status_code = 500
    detail = "AI 服務錯誤"


class LLMRateLimitError(AppException):
    """LLM 速率限制"""
    status_code = 429
    detail = "AI 服務目前流量限制，請稍後再試"