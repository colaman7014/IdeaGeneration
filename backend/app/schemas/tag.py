"""標籤相關 Pydantic 資料結構"""
from datetime import datetime
from pydantic import BaseModel, ConfigDict


class TagBase(BaseModel):
    """標籤基礎結構"""
    name: str


class TagCreate(TagBase):
    """建立標籤請求"""
    pass


class TagResponse(TagBase):
    """標籤回應結構"""
    id: int
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)
