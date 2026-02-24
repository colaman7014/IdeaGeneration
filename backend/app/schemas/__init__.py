"""Pydantic 資料結構定義"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class TagBase(BaseModel):
    """標籤基礎結構"""
    name: str


class TagCreate(TagBase):
    """建立標籤請求"""
    pass


class TagResponse(TagBase):
    """標籤回應結構"""
    id: int
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


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


class IdeaBase(BaseModel):
    """點子基礎結構"""
    title: str
    content: str


class IdeaCreate(IdeaBase):
    """建立點子請求"""
    news_source_1: Optional[str] = None
    news_source_2: Optional[str] = None


class IdeaResponse(IdeaBase):
    """點子回應結構"""
    id: int
    news_source_1: Optional[str] = None
    news_source_2: Optional[str] = None
    devil_audit: Optional[str] = None
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


class IdeaListResponse(BaseModel):
    """點子列表回應"""
    total: int
    items: list[IdeaResponse]


class IdeaGenerateRequest(BaseModel):
    """點子生成請求"""
    tag_ids: list[int] = []
    news_ids: list[int] = []


class DevilAuditRequest(BaseModel):
    """魔鬼審計請求"""
    idea_id: int


class DevilAuditResponse(BaseModel):
    """魔鬼審計回應"""
    idea_id: int
    audit_questions: str
    
    model_config = ConfigDict(from_attributes=True)
