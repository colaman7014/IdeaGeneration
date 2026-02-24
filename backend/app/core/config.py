"""應用程式設定"""
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """應用程式設定類別"""
    
    # Vercel API 設定
    vercel_api_key: str = ""
    
    # 資料庫設定
    database_url: str = "sqlite:///./idea_generation.db"
    
    # RSS 設定
    rss_update_interval: int = 60  # 分鐘
    
    # 應用設定
    app_env: str = "development"
    debug: bool = True
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache()
def get_settings() -> Settings:
    """取得應用程式設定（快取）"""
    return Settings()
