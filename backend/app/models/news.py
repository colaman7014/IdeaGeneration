"""新聞與標籤資料模型"""
from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Table
from sqlalchemy.orm import relationship

from app.core.database import Base


# 新聞與標籤的多對多關聯表
news_tags = Table(
    "news_tags",
    Base.metadata,
    Column("news_id", Integer, ForeignKey("news.id"), primary_key=True),
    Column("tag_id", Integer, ForeignKey("tags.id"), primary_key=True)
)


class News(Base):
    """新聞資料模型"""
    __tablename__ = "news"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(500), nullable=False)
    link = Column(String(1000), nullable=False, unique=True)
    summary = Column(Text, nullable=True)
    source = Column(String(100), nullable=False)
    published_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # 關聯標籤
    tags = relationship("Tag", secondary=news_tags, back_populates="news_items")


class Tag(Base):
    """標籤資料模型"""
    __tablename__ = "tags"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, unique=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # 關聯新聞
    news_items = relationship("News", secondary=news_tags, back_populates="tags")


class Idea(Base):
    """點子資料模型"""
    __tablename__ = "ideas"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(500), nullable=False)
    content = Column(Text, nullable=False)
    news_source_1 = Column(String(500), nullable=True)
    news_source_2 = Column(String(500), nullable=True)
    devil_audit = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
