"""RSS 抓取服務"""
import feedparser
from datetime import datetime
from typing import Optional
from sqlalchemy.orm import Session

from app.models.news import News, Tag
from app.services.rss_sources import RSS_SOURCES


class RSSFetcher:
    """RSS 抓取器類別"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def fetch_all_sources(self) -> dict:
        """從所有來源抓取 RSS 資料"""
        results = {
            "total_sources": len(RSS_SOURCES),
            "success": 0,
            "failed": 0,
            "new_articles": 0,
            "errors": []
        }
        
        for source in RSS_SOURCES:
            try:
                count = self._fetch_source(source)
                results["success"] += 1
                results["new_articles"] += count
            except Exception as e:
                results["failed"] += 1
                results["errors"].append({
                    "source": source["name"],
                    "error": str(e)
                })
        
        return results
    
    def _fetch_source(self, source: dict) -> int:
        """從單一來源抓取 RSS 資料"""
        feed = feedparser.parse(source["url"])
        
        if feed.bozo and not feed.entries:
            raise Exception(f"無法解析 RSS: {feed.bozo_exception}")
        
        new_count = 0
        
        for entry in feed.entries:
            # 檢查是否已存在
            existing = self.db.query(News).filter(
                News.link == entry.get("link", "")
            ).first()
            
            if existing:
                continue
            
            # 解析發布時間
            published_at = self._parse_published_date(entry)
            
            # 建立新聞記錄
            news = News(
                title=entry.get("title", "無標題"),
                link=entry.get("link", ""),
                summary=entry.get("summary", entry.get("description", "")),
                source=source["name"],
                published_at=published_at
            )
            
            self.db.add(news)
            new_count += 1
        
        self.db.commit()
        return new_count
    
    def _parse_published_date(self, entry: dict) -> Optional[datetime]:
        """解析 RSS 條目的發布日期"""
        published = entry.get("published_parsed") or entry.get("updated_parsed")
        
        if published:
            try:
                return datetime(*published[:6])
            except (TypeError, ValueError):
                pass
        
        return None
    
    def get_recent_news(self, limit: int = 50) -> list[News]:
        """取得最近的新聞列表"""
        return self.db.query(News).order_by(
            News.created_at.desc()
        ).limit(limit).all()
    
    def get_news_without_tags(self, limit: int = 20) -> list[News]:
        """取得尚未標籤的新聞"""
        return self.db.query(News).filter(
            ~News.tags.any()
        ).order_by(
            News.created_at.desc()
        ).limit(limit).all()


def create_rss_fetcher(db: Session) -> RSSFetcher:
    """建立 RSS 抓取器實例"""
    return RSSFetcher(db)
