"""點子生成 API 路由"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas import (
    IdeaResponse,
    IdeaListResponse,
    IdeaGenerateRequest,
    DevilAuditRequest,
    DevilAuditResponse
)
from app.services.idea_service import create_idea_service

router = APIRouter(prefix="/ideas", tags=["ideas"])


@router.get("", response_model=IdeaListResponse)
async def list_ideas(
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """獲取所有點子列表"""
    service = create_idea_service(db)
    ideas = service.get_all_ideas(skip=skip, limit=limit)
    total = service.get_ideas_count()
    
    return IdeaListResponse(total=total, items=ideas)


@router.get("/{idea_id}", response_model=IdeaResponse)
async def get_idea(idea_id: int, db: Session = Depends(get_db)):
    """獲取單一點子詳情"""
    service = create_idea_service(db)
    idea = service.get_idea_by_id(idea_id)
    
    if not idea:
        raise HTTPException(status_code=404, detail="點子不存在")
    
    return idea


@router.post("/generate", response_model=IdeaResponse)
async def generate_idea(
    request: IdeaGenerateRequest,
    db: Session = Depends(get_db)
):
    """生成新的商業構想
    
    可以指定 tag_ids 或 news_ids，若都不指定則隨機選取兩則新聞
    """
    service = create_idea_service(db)
    
    news_a = None
    news_b = None
    
    # 根據請求選取新聞
    if request.news_ids and len(request.news_ids) >= 2:
        news_list = service.get_news_by_ids(request.news_ids[:2])
        if len(news_list) >= 2:
            news_a, news_b = news_list[0], news_list[1]
    elif request.tag_ids:
        news_list = service.get_news_by_tag_ids(request.tag_ids)
        if len(news_list) >= 2:
            import random
            selected = random.sample(news_list, 2)
            news_a, news_b = selected[0], selected[1]
    
    # 若沒有指定，則隨機選取
    if not news_a or not news_b:
        news_a, news_b = service.get_random_news_pair()
    
    if not news_a or not news_b:
        raise HTTPException(
            status_code=400,
            detail="資料庫中沒有足夠的新聞（需要至少 2 則帶標籤的新聞）"
        )
    
    # 生成點子
    try:
        idea = await service.generate_idea(news_a, news_b)
    except Exception as e:
        error_msg = str(e)
        if "429" in error_msg or "rate_limit" in error_msg:
            raise HTTPException(status_code=429, detail="AI 服務目前流量限制，請稍後再試")
        raise HTTPException(status_code=500, detail=f"點子生成失敗: {error_msg}")
    if not idea:
        raise HTTPException(
            status_code=500,
            detail="點子生成失敗，請稍後再試"
        )
    
    return idea


@router.post("/devil-audit", response_model=DevilAuditResponse)
async def devil_audit(
    request: DevilAuditRequest,
    db: Session = Depends(get_db)
):
    """對點子進行魔鬼審計（壓力測試）"""
    service = create_idea_service(db)
    
    # 確認點子存在
    idea = service.get_idea_by_id(request.idea_id)
    if not idea:
        raise HTTPException(status_code=404, detail="點子不存在")
    
    # 執行審計
    try:
        audit_result = await service.generate_devil_audit(request.idea_id)
    except Exception as e:
        error_msg = str(e)
        if "429" in error_msg or "rate_limit" in error_msg:
            raise HTTPException(status_code=429, detail="AI 服務目前流量限制，請稍後再試")
        raise HTTPException(status_code=500, detail=f"魔鬼審計失敗: {error_msg}")
    if not audit_result:
        raise HTTPException(
            status_code=500,
            detail="魔鬼審計失敗，請稍後再試"
        )
    
    return DevilAuditResponse(
        idea_id=request.idea_id,
        audit_questions=audit_result
    )


@router.get("/{idea_id}/export")
async def export_idea(idea_id: int, db: Session = Depends(get_db)):
    """匯出點子為 Obsidian Markdown 格式"""
    service = create_idea_service(db)
    
    markdown = service.export_idea_markdown(idea_id)
    
    if not markdown:
        raise HTTPException(status_code=404, detail="點子不存在")
    
    return {
        "idea_id": idea_id,
        "format": "markdown",
        "content": markdown
    }
