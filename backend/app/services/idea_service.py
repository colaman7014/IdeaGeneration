"""點子生成服務"""
import random
from typing import Optional
from sqlalchemy.orm import Session

from app.models.news import News, Tag, Idea
from app.services.llm_client import (
    VercelLLMClient,
    IDEA_SYNTHESIS_PROMPT,
    DEVIL_AUDIT_PROMPT,
    create_llm_client
)


class IdeaService:
    """點子生成服務"""
    
    def __init__(self, db: Session):
        self.db = db
        self.llm_client: VercelLLMClient = create_llm_client()
    
    def get_random_news_pair(self) -> tuple[Optional[News], Optional[News]]:
        """隨機選取兩則新聞"""
        # 獲取所有有標籤的新聞
        news_with_tags = self.db.query(News).filter(News.tags.any()).all()
        
        if len(news_with_tags) < 2:
            return None, None
        
        # 隨機選取兩則不同的新聞
        selected = random.sample(news_with_tags, 2)
        return selected[0], selected[1]
    
    def get_news_by_tag_ids(self, tag_ids: list[int]) -> list[News]:
        """根據標籤 ID 獲取新聞"""
        if not tag_ids:
            return []
        
        return self.db.query(News).filter(
            News.tags.any(Tag.id.in_(tag_ids))
        ).all()
    
    def get_news_by_ids(self, news_ids: list[int]) -> list[News]:
        """根據新聞 ID 獲取新聞"""
        if not news_ids:
            return []
        
        return self.db.query(News).filter(News.id.in_(news_ids)).all()
    
    async def generate_idea(
        self,
        news_a: News,
        news_b: News
    ) -> Optional[Idea]:
        """從兩則新聞生成商業構想"""
        
        # 準備標籤字串
        tags_a = ", ".join([tag.name for tag in news_a.tags])
        tags_b = ", ".join([tag.name for tag in news_b.tags])
        
        # 組合 prompt
        prompt = IDEA_SYNTHESIS_PROMPT.format(
            news_a_title=news_a.title,
            tags_a=tags_a,
            news_b_title=news_b.title,
            tags_b=tags_b
        )
        
        # 呼叫 LLM
        result = await self.llm_client.complete(
            prompt=prompt,
            max_tokens=800,
            temperature=0.8
        )
        
        if not result:
            return None
        
        # 解析結果
        parsed = self._parse_idea_result(result)
        
        # 建立 Idea 記錄
        idea = Idea(
            title=parsed.get("title", "未命名構想"),
            content=result,
            news_source_1=news_a.title,
            news_source_2=news_b.title
        )
        
        self.db.add(idea)
        self.db.commit()
        self.db.refresh(idea)
        
        return idea
    
    async def generate_devil_audit(self, idea_id: int) -> Optional[str]:
        """對點子進行魔鬼審計"""
        
        idea = self.db.query(Idea).filter(Idea.id == idea_id).first()
        if not idea:
            return None
        
        # 組合 prompt
        prompt = DEVIL_AUDIT_PROMPT.format(
            idea_content=idea.content
        )
        
        # 呼叫 LLM
        result = await self.llm_client.complete(
            prompt=prompt,
            max_tokens=500,
            temperature=0.7
        )
        
        if not result:
            return None
        
        # 更新 Idea 記錄
        idea.devil_audit = result
        self.db.commit()
        self.db.refresh(idea)
        
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
    
    def get_idea_by_id(self, idea_id: int) -> Optional[Idea]:
        """根據 ID 獲取點子"""
        return self.db.query(Idea).filter(Idea.id == idea_id).first()
    
    def get_all_ideas(self, skip: int = 0, limit: int = 20) -> list[Idea]:
        """獲取所有點子"""
        return self.db.query(Idea).order_by(Idea.created_at.desc()).offset(skip).limit(limit).all()
    
    def get_ideas_count(self) -> int:
        """獲取點子總數"""
        return self.db.query(Idea).count()
    
    def export_idea_markdown(self, idea_id: int) -> Optional[str]:
        """匯出點子為 Obsidian Markdown 格式"""
        
        idea = self.get_idea_by_id(idea_id)
        if not idea:
            return None
        
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


def create_idea_service(db: Session) -> IdeaService:
    """建立點子服務實例"""
    return IdeaService(db)
