"""點子生成 API 路由（使用 DI 服務）"""
import random

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_llm_client
from app.schemas import (
    IdeaResponse,
    IdeaListResponse,
    IdeaGenerateRequest,
    DevilAuditRequest,
    DevilAuditResponse,
)
from app.services.idea_service import IdeaService
from app.services.llm_client import VercelLLMClient

router = APIRouter(prefix="/ideas", tags=["ideas"])


def _get_idea_service(
    db: AsyncSession = Depends(get_db),
    llm_client: VercelLLMClient = Depends(get_llm_client),
) -> IdeaService:
    """組裝 IdeaService（DI 入口）"""
    return IdeaService(db=db, llm_client=llm_client)


@router.get("", response_model=IdeaListResponse)
async def list_ideas(
    skip: int = 0,
    limit: int = 20,
    service: IdeaService = Depends(_get_idea_service),
):
    """獲取所有點子列表"""
    ideas = await service.get_all_ideas(skip=skip, limit=limit)
    total = await service.get_ideas_count()
    return IdeaListResponse(total=total, items=ideas)


@router.get("/{idea_id}", response_model=IdeaResponse)
async def get_idea(
    idea_id: int,
    service: IdeaService = Depends(_get_idea_service),
):
    """獲取單一點子詳情"""
    return await service.get_idea_by_id(idea_id)


@router.post("/generate", response_model=IdeaResponse)
async def generate_idea(
    request: IdeaGenerateRequest,
    service: IdeaService = Depends(_get_idea_service),
):
    """生成新的商業構想

    可以指定 tag_ids 或 news_ids，若都不指定則隨機選取兩則新聞
    """
    news_a = None
    news_b = None

    # 根據請求選取新聞
    if request.news_ids and len(request.news_ids) >= 2:
        news_list = await service.get_news_by_ids(request.news_ids[:2])
        if len(news_list) >= 2:
            news_a, news_b = news_list[0], news_list[1]
    elif request.tag_ids:
        news_list = await service.get_news_by_tag_ids(request.tag_ids)
        if len(news_list) >= 2:
            selected = random.sample(news_list, 2)
            news_a, news_b = selected[0], selected[1]

    # 若沒有指定，則隨機選取
    if not news_a or not news_b:
        news_a, news_b = await service.get_random_news_pair()

    # 生成點子
    return await service.generate_idea(news_a, news_b)


@router.post("/devil-audit", response_model=DevilAuditResponse)
async def devil_audit(
    request: DevilAuditRequest,
    service: IdeaService = Depends(_get_idea_service),
):
    """對點子進行魔鬼審計（壓力測試）"""
    audit_result = await service.generate_devil_audit(request.idea_id)
    return DevilAuditResponse(
        idea_id=request.idea_id,
        audit_questions=audit_result,
    )


@router.get("/{idea_id}/export")
async def export_idea(
    idea_id: int,
    service: IdeaService = Depends(_get_idea_service),
):
    """匯出點子為 Obsidian Markdown 格式"""
    markdown = await service.export_idea_markdown(idea_id)
    return {
        "idea_id": idea_id,
        "format": "markdown",
        "content": markdown,
    }
