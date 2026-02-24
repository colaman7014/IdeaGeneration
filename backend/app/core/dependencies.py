"""FastAPI 依賴注入定義"""
from functools import lru_cache

from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends

from app.core.database import get_db
from app.services.llm_client import VercelLLMClient
from app.services.news_service import NewsService


@lru_cache(maxsize=1)
def get_llm_client() -> VercelLLMClient:
    """取得 LLM 客戶端（單例）"""
    return VercelLLMClient()


async def get_news_service(
    db: AsyncSession = Depends(get_db),
) -> NewsService:
    """取得新聞服務"""
    return NewsService(db)
