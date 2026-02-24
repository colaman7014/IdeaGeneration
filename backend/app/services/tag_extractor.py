"""標籤提取服務"""
from sqlalchemy.orm import Session

from app.models.news import News, Tag
from app.services.llm_client import create_llm_client


class TagExtractor:
    """標籤提取器類別"""
    
    def __init__(self, db: Session):
        self.db = db
        self.llm_client = create_llm_client()
    
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
            tag = self._get_or_create_tag(tag_name)
            tags.append(tag)
        
        # 關聯標籤到新聞
        news.tags = tags
        self.db.commit()
        
        return tags
    
    def _get_or_create_tag(self, tag_name: str) -> Tag:
        """取得或建立標籤"""
        tag = self.db.query(Tag).filter(Tag.name == tag_name).first()
        
        if not tag:
            tag = Tag(name=tag_name)
            self.db.add(tag)
            self.db.flush()
        
        return tag
    
    async def process_untagged_news(self, limit: int = 10) -> dict:
        """處理尚未標籤的新聞"""
        
        # 取得未標籤的新聞
        untagged_news = self.db.query(News).filter(
            ~News.tags.any()
        ).limit(limit).all()
        
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


def create_tag_extractor(db: Session) -> TagExtractor:
    """建立標籤提取器實例"""
    return TagExtractor(db)
