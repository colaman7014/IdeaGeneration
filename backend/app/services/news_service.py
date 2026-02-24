"""新聞查詢服務（非同步版本）"""
import random
from typing import Optional

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.news import News, Tag
from app.core.exceptions import NotFoundError, InsufficientDataError


class NewsService:
    """新聞查詢服務"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def get_random_news_pair(self) -> tuple[News, News]:
        """隨機選取兩則帶標籤的新聞"""
        stmt = (
            select(News)
            .where(News.tags.any())
            .options(selectinload(News.tags))
        )
        result = await self.db.execute(stmt)
        news_with_tags = result.scalars().all()
        
        if len(news_with_tags) < 2:
            raise InsufficientDataError("資料庫中沒有足夠的新聞（需要至少 2 則帶標籤的新聞）")
        
        selected = random.sample(list(news_with_tags), 2)
        return selected[0], selected[1]
    
    async def get_news_by_ids(self, news_ids: list[int]) -> list[News]:
        """根據新聞 ID 獲取新聞"""
        if not news_ids:
            return []
        
        stmt = (
            select(News)
            .where(News.id.in_(news_ids))
            .options(selectinload(News.tags))
        )
        result = await self.db.execute(stmt)
        return list(result.scalars().all())
    
    async def get_news_by_tag_ids(self, tag_ids: list[int]) -> list[News]:
        """根據標籤 ID 獲取新聞"""
        if not tag_ids:
            return []
        
        stmt = (
            select(News)
            .where(News.tags.any(Tag.id.in_(tag_ids)))
            .options(selectinload(News.tags))
        )
        result = await self.db.execute(stmt)
        return list(result.scalars().all())
    
    async def get_news_list(self, skip: int = 0, limit: int = 20) -> list[News]:
        """獲取新聞列表"""
        stmt = (
            select(News)
            .order_by(News.created_at.desc())
            .offset(skip)
            .limit(limit)
            .options(selectinload(News.tags))
        )
        result = await self.db.execute(stmt)
        return list(result.scalars().all())
    
    async def get_news_count(self) -> int:
        """獲取新聞總數"""
        stmt = select(func.count(News.id))
        result = await self.db.execute(stmt)
        return result.scalar_one()
    
    async def get_news_by_id(self, news_id: int) -> News:
        """獲取單一新聞"""
        stmt = (
            select(News)
            .where(News.id == news_id)
            .options(selectinload(News.tags))
        )
        result = await self.db.execute(stmt)
        news = result.scalar_one_or_none()
        
        if not news:
            raise NotFoundError("新聞不存在")
        
        return news
    
    async def get_tags_list(self, skip: int = 0, limit: int = 50) -> list[Tag]:
        """獲取標籤列表"""
        stmt = select(Tag).order_by(Tag.name).offset(skip).limit(limit)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())
    
    async def get_tags_count(self) -> int:
        """獲取標籤總數"""
        stmt = select(func.count(Tag.id))
        result = await self.db.execute(stmt)
        return result.scalar_one()
