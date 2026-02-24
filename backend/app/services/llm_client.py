"""Vercel API 客戶端服務"""
import httpx
from typing import Optional

from app.core.config import get_settings


class VercelLLMClient:
    """Vercel API LLM 客戶端"""
    
    # Vercel AI Gateway 端點（正確端點）
    BASE_URL = "https://ai-gateway.vercel.sh/v1"
    
    def __init__(self):
        self.settings = get_settings()
        self.api_key = self.settings.vercel_api_key
    
    async def complete(
        self,
        prompt: str,
        model: str = "openai/gpt-4o-mini",
        max_tokens: int = 1000,
        temperature: float = 0.7
    ) -> Optional[str]:
        """呼叫 Vercel API 完成文字生成"""
        
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": model,
            "messages": [
                {"role": "user", "content": prompt}
            ],
            "max_tokens": max_tokens,
            "temperature": temperature
        }
        
        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(
                    f"{self.BASE_URL}/chat/completions",
                    headers=headers,
                    json=payload,
                    timeout=30.0
                )
                response.raise_for_status()
                
                data = response.json()
                return data.get("choices", [{}])[0].get("message", {}).get("content", "")
                
            except httpx.HTTPStatusError as e:
                raise Exception(f"Vercel API 錯誤: {e.response.status_code} - {e.response.text}")
            except httpx.RequestError as e:
                raise Exception(f"網路請求錯誤: {str(e)}")
    
    async def extract_tags(self, news_title: str, news_summary: str) -> list[str]:
        """從新聞中提取標籤"""
        
        prompt = TAG_EXTRACTION_PROMPT.format(
            title=news_title,
            summary=news_summary
        )
        
        result = await self.complete(
            prompt=prompt,
            max_tokens=200,
            temperature=0.3
        )
        
        if not result:
            return []
        
        # 解析標籤（預期格式：逗號分隔）
        tags = [tag.strip() for tag in result.split(",") if tag.strip()]
        return tags[:5]  # 最多 5 個標籤


# AI 標籤提取 Prompt
TAG_EXTRACTION_PROMPT = """你是一個專業的新聞分析師。請從以下新聞中提取 3-5 個關鍵標籤。

標籤應該：
1. 反映新聞的核心主題和產業領域
2. 包含可能激發商業靈感的關鍵詞
3. 簡潔明確，每個標籤 2-4 個字

新聞標題：{title}
新聞摘要：{summary}

請直接輸出標籤，用逗號分隔，不要加任何額外說明。
範例輸出：人工智慧, 醫療科技, 數據分析, 創業投資"""


# AI 商業構想合成器 Prompt
IDEA_SYNTHESIS_PROMPT = """你是一位創新商業顧問，專門將看似無關的新聞趨勢結合成獨特的商業構想。

## 你的任務
根據以下兩則新聞的標籤，創造一個結合兩者元素的創新商業點子。

## 新聞 A
標題：{news_a_title}
標籤：{tags_a}

## 新聞 B
標題：{news_b_title}
標籤：{tags_b}

## 輸出格式（請嚴格遵守）
```
點子名稱：[一句話標題，最多 20 字]

概念說明：
[用 2-3 句話說明這個商業構想的核心價值主張]

目標客群：
[明確指出誰會為這個產品/服務付費]

獲利模式：
[說明如何賺錢，包含定價策略]

競爭優勢：
[為什麼這個構想難以被複製]

第一步行動：
[明天就能開始做的具體行動]
```

請確保點子具有可執行性，不是空泛的構想。"""


# AI 魔鬼審計 Prompt（壓力測試）
DEVIL_AUDIT_PROMPT = """你是一位極度挑剔的風險投資人，專門找出商業構想的漏洞。

你的性格：
- 尖酸刻薄但不惡毒
- 直接了當不繞彎子
- 關心的是真實的風險，不是理論上的問題

## 要審計的點子
{idea_content}

## 你的任務
提出 5 個最狠的問題，挑戰這個構想的可行性。

## 輸出格式
每個問題一行，以「🔥」開頭，簡短有力（每個問題最多 50 字）。

範例：
🔥 你打算怎麼獲取第一批用戶？冷啟動問題怎麼解決？
🔥 為什麼大公司不能明天就複製你？
🔥 單位經濟合理嗎？客戶獲取成本 vs 終身價值？"""


def create_llm_client() -> VercelLLMClient:
    """建立 LLM 客戶端實例"""
    return VercelLLMClient()
