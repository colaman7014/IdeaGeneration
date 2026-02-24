"""點子生成服務（非同步版本）"""
import random
from typing import Optional

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.news import News, Tag, Idea
from app.core.exceptions import NotFoundError, InsufficientDataError, LLMError, LLMRateLimitError
from app.services.llm_client import (
    VercelLLMClient,
    IDEA_SYNTHESIS_PROMPT,
    DEVIL_AUDIT_PROMPT,
)


class IdeaService:
    """點子生成服務（非同步 DB + DI）"""

    def __init__(self, db: AsyncSession, llm_client: VercelLLMClient):
        self.db = db
        self.llm_client = llm_client

    async def get_random_news_pair(self) -> tuple[News, News]:
        """隨機選取兩則帶標籤的新聞"""
        stmt = (
            select(News)
            .where(News.tags.any())
            .options(selectinload(News.tags))
        )
        result = await self.db.execute(stmt)
        news_with_tags = list(result.scalars().all())

        if len(news_with_tags) < 2:
            raise InsufficientDataError("資料庫中沒有足夠的新聞（需要至少 2 則帶標籤的新聞）")

        selected = random.sample(news_with_tags, 2)
        return selected[0], selected[1]

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

    async def generate_idea(
        self,
        news_a: News,
        news_b: News,
    ) -> Idea:
        """從兩則新聞生成商業構想"""
        # 準備標籤字串
        tags_a = ", ".join([tag.name for tag in news_a.tags])
        tags_b = ", ".join([tag.name for tag in news_b.tags])

        # 組合 prompt
        prompt = IDEA_SYNTHESIS_PROMPT.format(
            news_a_title=news_a.title,
            tags_a=tags_a,
            news_b_title=news_b.title,
            tags_b=tags_b,
        )

        # 呼叫 LLM
        try:
            result = await self.llm_client.complete(
                prompt=prompt,
                max_tokens=800,
                temperature=0.8,
            )
        except Exception as e:
            error_msg = str(e)
            if "429" in error_msg or "rate_limit" in error_msg:
                raise LLMRateLimitError()
            raise LLMError(f"點子生成失敗: {error_msg}")

        if not result:
            raise LLMError("點子生成失敗，請稍後再試")

        # 解析結果
        parsed = self._parse_idea_result(result)

        # 建立 Idea 記錄
        idea = Idea(
            title=parsed.get("title", "未命名構想"),
            content=result,
            news_source_1=news_a.title,
            news_source_2=news_b.title,
        )

        self.db.add(idea)
        await self.db.commit()
        await self.db.refresh(idea)

        return idea

    async def generate_devil_audit(self, idea_id: int) -> str:
        """對點子進行魔鬼審計"""
        idea = await self.get_idea_by_id(idea_id)

        # 組合 prompt
        prompt = DEVIL_AUDIT_PROMPT.format(idea_content=idea.content)

        # 呼叫 LLM
        try:
            result = await self.llm_client.complete(
                prompt=prompt,
                max_tokens=500,
                temperature=0.7,
            )
        except Exception as e:
            error_msg = str(e)
            if "429" in error_msg or "rate_limit" in error_msg:
                raise LLMRateLimitError()
            raise LLMError(f"魔鬼審計失敗: {error_msg}")

        if not result:
            raise LLMError("魔鬼審計失敗，請稍後再試")

        # 更新 Idea 記錄
        idea.devil_audit = result
        await self.db.commit()
        await self.db.refresh(idea)

        return result

    def _parse_idea_result(self, result: str) -> dict:
        """解析 LLM 回傳的點子結果"""
        parsed = {}

        # 嘗試提取標題
        lines = result.split("\n")
        for line in lines:
            if "點子名稱" in line or "名稱" in line:
                # 取冒號後面的內容
                parts = line.split("：", 1)
                if len(parts) > 1:
                    parsed["title"] = parts[1].strip()
                    break
                parts = line.split(":", 1)
                if len(parts) > 1:
                    parsed["title"] = parts[1].strip()
                    break

        return parsed

    async def get_idea_by_id(self, idea_id: int) -> Idea:
        """根據 ID 獲取點子"""
        stmt = select(Idea).where(Idea.id == idea_id)
        result = await self.db.execute(stmt)
        idea = result.scalar_one_or_none()

        if not idea:
            raise NotFoundError("點子不存在")

        return idea

    async def get_all_ideas(self, skip: int = 0, limit: int = 20) -> list[Idea]:
        """獲取所有點子"""
        stmt = (
            select(Idea)
            .order_by(Idea.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def get_ideas_count(self) -> int:
        """獲取點子總數"""
        stmt = select(func.count(Idea.id))
        result = await self.db.execute(stmt)
        return result.scalar_one()

    async def export_idea_markdown(self, idea_id: int) -> str:
        """匯出點子為 Obsidian Markdown 格式"""
        idea = await self.get_idea_by_id(idea_id)

        # 組合 Markdown
        md_content = f"""# {idea.title}

> 建立時間：{idea.created_at.strftime("%Y-%m-%d %H:%M")}

## 靈感來源

- 新聞 A：{idea.news_source_1 or "無"}
- 新聞 B：{idea.news_source_2 or "無"}

## 構想內容

{idea.content}

"""

        if idea.devil_audit:
            md_content += f"""## 魔鬼審計

{idea.devil_audit}

"""

        md_content += """---
tags: #idea #generated
"""

        return md_content
