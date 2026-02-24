"""新聞相關 Pydantic 資料結構"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict

from app.schemas.tag import TagResponse


class NewsBase(BaseModel):
    """新聞基礎結構"""
    title: str
    link: str
    summary: Optional[str] = None
    source: str


class NewsCreate(NewsBase):
    """建立新聞請求"""
    published_at: Optional[datetime] = None


class NewsResponse(NewsBase):
    """新聞回應結構"""
    id: int
    published_at: Optional[datetime] = None
    created_at: datetime
    tags: list[TagResponse] = []
    
    model_config = ConfigDict(from_attributes=True)


class NewsListResponse(BaseModel):
    """新聞列表回應"""
    total: int
    items: list[NewsResponse]
