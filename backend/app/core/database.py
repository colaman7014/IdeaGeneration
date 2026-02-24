"""資料庫連線設定（非同步版本）"""
from sqlalchemy import create_engine
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from app.core.config import get_settings

settings = get_settings()

# === 同步引擎（供 metadata.create_all 與排程任務使用） ===
sync_engine = create_engine(
    settings.database_url,
    connect_args={"check_same_thread": False}
)

# 同步 Session 工廠（僅供排程任務等同步場景使用）
SyncSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=sync_engine)

# === 非同步引擎（主要 API 用） ===
async_database_url = settings.database_url.replace("sqlite:///", "sqlite+aiosqlite:///")

async_engine = create_async_engine(
    async_database_url,
    connect_args={"check_same_thread": False}
)

# 非同步 Session 工廠
AsyncSessionLocal = async_sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    expire_on_commit=False
)

# 建立 Base 類別供模型繼承
Base = declarative_base()

# === 向後相容別名 ===
# 讓現有 import 不中斷（逐步遷移期間）
engine = sync_engine
SessionLocal = SyncSessionLocal


async def get_db():
    """取得非同步資料庫 Session（依賴注入用）"""
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()


def get_sync_db():
    """取得同步資料庫 Session（排程任務用）"""
    db = SyncSessionLocal()
    try:
        yield db
    finally:
        db.close()
