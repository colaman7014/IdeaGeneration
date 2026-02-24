"""標籤提取服務（非同步版本）"""
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.news import News, Tag
from app.services.llm_client import VercelLLMClient
from app.core.database import AsyncSessionLocal


class TagExtractor:
    """標籤提取器類別（非同步 DB + DI）"""

    def __init__(self, db: AsyncSession, llm_client: VercelLLMClient):
        self.db = db
        self.llm_client = llm_client

    async def extract_and_save_tags(self, news: News) -> list[Tag]:
        """從新聞中提取標籤並儲存"""
        # 取得新聞標題和摘要（確保為字串類型）
        news_title: str = str(news.title) if news.title else ""
        news_summary: str = str(news.summary) if news.summary else ""
        # 呼叫 LLM 提取標籤
        tag_names = await self.llm_client.extract_tags(
            news_title=news_title,
            news_summary=news_summary
        )

        tags = []
        for tag_name in tag_names:
            # 查找或建立標籤
            tag = await self._get_or_create_tag(tag_name)
            tags.append(tag)

        # 關聯標籤到新聞
        news.tags = tags
        await self.db.commit()

        return tags

    async def _get_or_create_tag(self, tag_name: str) -> Tag:
        """取得或建立標籤（非同步）"""
        stmt = select(Tag).where(Tag.name == tag_name)
        result = await self.db.execute(stmt)
        tag = result.scalar_one_or_none()

        if not tag:
            tag = Tag(name=tag_name)
            self.db.add(tag)
            await self.db.flush()

        return tag

    async def process_untagged_news(self, limit: int = 10) -> dict:
        """處理尚未標籤的新聞"""
        # 取得未標籤的新聞
        stmt = (
            select(News)
            .where(~News.tags.any())
            .limit(limit)
        )
        result = await self.db.execute(stmt)
        untagged_news = list(result.scalars().all())

        results = {
            "processed": 0,
            "failed": 0,
            "errors": []
        }

        for news in untagged_news:
            try:
                await self.extract_and_save_tags(news)
                results["processed"] += 1
            except Exception as e:
                results["failed"] += 1
                results["errors"].append({
                    "news_id": news.id,
                    "error": str(e)
                })

        return results


async def create_tag_extractor() -> TagExtractor:
    """建立標籤提取器實例（使用 AsyncSessionLocal + singleton LLM client）"""
    from app.core.dependencies import get_llm_client
    db = AsyncSessionLocal()
    llm_client = get_llm_client()
    return TagExtractor(db, llm_client)
