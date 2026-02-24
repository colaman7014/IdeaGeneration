"""新聞 API 路由"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.news import News, Tag
from app.schemas import NewsResponse, NewsListResponse, TagResponse
from app.services.scheduler import fetch_rss_job, extract_tags_job

router = APIRouter(prefix="/news", tags=["news"])


@router.post("/fetch")
async def trigger_fetch():
    """手動觸發 RSS 抓取與標籤提取（供測試 / 首次初始化）"""
    rss_result = await fetch_rss_job()
    tag_result = await extract_tags_job()
    return {
        "rss": rss_result or {"new_articles": 0},
        "tags": tag_result or {"processed": 0},
    }


@router.get("", response_model=NewsListResponse)
async def list_news(
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """獲取新聞列表"""
    news_items = db.query(News).order_by(News.created_at.desc()).offset(skip).limit(limit).all()
    total = db.query(News).count()
    
    return NewsListResponse(total=total, items=news_items)


@router.get("/random-pair")
async def get_random_news_pair(db: Session = Depends(get_db)):
    """隨機獲取兩則帶標籤的新聞"""
    import random
    
    news_with_tags = db.query(News).filter(News.tags.any()).all()
    
    if len(news_with_tags) < 2:
        raise HTTPException(
            status_code=400,
            detail="資料庫中沒有足夠的新聞（需要至少 2 則帶標籤的新聞）"
        )
    
    selected = random.sample(news_with_tags, 2)
    
    return {
        "news_a": NewsResponse.model_validate(selected[0]),
        "news_b": NewsResponse.model_validate(selected[1])
    }


@router.get("/tags")
async def list_tags(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db)
):
    """獲取所有標籤列表"""
    tags = db.query(Tag).order_by(Tag.name).offset(skip).limit(limit).all()
    total = db.query(Tag).count()
    
    return {
        "total": total,
        "items": [TagResponse.model_validate(tag) for tag in tags]
    }


@router.get("/{news_id}", response_model=NewsResponse)
async def get_news(news_id: int, db: Session = Depends(get_db)):
    """獲取單一新聞詳情"""
    news = db.query(News).filter(News.id == news_id).first()
    
    if not news:
        raise HTTPException(status_code=404, detail="新聞不存在")
    
    return news
