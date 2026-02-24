"""新聞 API 路由（使用 DI 服務）"""
from fastapi import APIRouter, Depends

from app.schemas import NewsResponse, NewsListResponse, TagResponse
from app.services.news_service import NewsService
from app.core.dependencies import get_news_service
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
    service: NewsService = Depends(get_news_service),
):
    """獲取新聞列表"""
    items = await service.get_news_list(skip=skip, limit=limit)
    total = await service.get_news_count()
    return NewsListResponse(total=total, items=items)


@router.get("/random-pair")
async def get_random_news_pair(
    service: NewsService = Depends(get_news_service),
):
    """隨機獲取兩則帶標籤的新聞"""
    news_a, news_b = await service.get_random_news_pair()
    return {
        "news_a": NewsResponse.model_validate(news_a),
        "news_b": NewsResponse.model_validate(news_b),
    }


@router.get("/tags")
async def list_tags(
    skip: int = 0,
    limit: int = 50,
    service: NewsService = Depends(get_news_service),
):
    """獲取所有標籤列表"""
    tags = await service.get_tags_list(skip=skip, limit=limit)
    total = await service.get_tags_count()
    return {
        "total": total,
        "items": [TagResponse.model_validate(tag) for tag in tags],
    }


@router.get("/{news_id}", response_model=NewsResponse)
async def get_news(
    news_id: int,
    service: NewsService = Depends(get_news_service),
):
    """獲取單一新聞詳情"""
    news = await service.get_news_by_id(news_id)
    return news
